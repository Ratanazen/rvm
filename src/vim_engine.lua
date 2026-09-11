-- src/vim_engine.lua
-- Full Vim-style editing engine for RVM.
-- Implements: NORMAL / INSERT / VISUAL / V-LINE / V-BLOCK / COMMAND / SEARCH / REPLACE
-- Motions: h j k l w b e 0 $ gg G Ctrl-u Ctrl-d zz zt zb
-- Editing: i I a A o O x dd D cc C yy p P u Ctrl-r
-- Search:  / ? n N
--
-- Architecture (per spec):
--   Input → Mode → Keymap → Command → Editor
--
-- This module is mode/keymap/command logic only — it never touches the screen.
-- The UI layer is responsible for rendering.

local VimEngine = {}
VimEngine.__index = VimEngine

-- ─────────────────────────────────────────────────────────
-- Mode enum
-- ─────────────────────────────────────────────────────────
VimEngine.MODES = {
  NORMAL    = "NORMAL",
  INSERT    = "INSERT",
  VISUAL    = "VISUAL",
  VLINE     = "V-LINE",
  VBLOCK    = "V-BLOCK",
  COMMAND   = "COMMAND",
  SEARCH    = "SEARCH",
  REPLACE   = "REPLACE",
}

-- ─────────────────────────────────────────────────────────
-- Constructor
-- ─────────────────────────────────────────────────────────
function VimEngine.new(buffer)
  local self = setmetatable({}, VimEngine)
  self.buffer      = buffer
  self.mode        = VimEngine.MODES.NORMAL
  self.pending_key = nil        -- for multi-key sequences like gg, dd, yy
  self.register_count = ""
  self.last_search  = nil        -- { query = "...", direction = "fwd"|"bwd" }
  self.visual_start = nil        -- { row = , col = }
  self.visual_end   = nil
  self.replace_buffer = nil      -- accumulator for R mode single-char replacements
  self.command_buffer = ""
  self.search_buffer  = ""
  return self
end

function VimEngine:set_buffer(buf)
  self.buffer = buf
end

function VimEngine:current_mode()
  return self.mode
end

function VimEngine:is_insert_family()
  return self.mode == VimEngine.MODES.INSERT or self.mode == VimEngine.MODES.REPLACE
end

function VimEngine:is_visual_family()
  return self.mode == VimEngine.MODES.VISUAL
      or self.mode == VimEngine.MODES.VLINE
      or self.mode == VimEngine.MODES.VBLOCK
end

-- ─────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────
local function line_len(buf)
  return #(buf.lines[buf.cursor_row] or "")
end

local function clamp(buf)
  if buf.cursor_row < 1 then buf.cursor_row = 1 end
  if buf.cursor_row > #buf.lines then buf.cursor_row = #buf.lines end
  local ml = #(buf.lines[buf.cursor_row] or "")
  -- In NORMAL/VISUAL, vim cursor sits ON a char, max col = line_len
  -- In INSERT, cursor can be one past end (col = line_len + 1)
  if buf.cursor_col < 1 then buf.cursor_col = 1 end
  if buf.cursor_col > ml + 1 then buf.cursor_col = ml + 1 end
end

-- Vim word boundaries (mimics w/b/e motions)
local function is_word_char(c)
  return c and c:match("[%w_]") ~= nil
end

local function at_word_boundary(line, idx, side)
  -- side: "start" or "end"
  if not line or idx < 1 or idx > #line then return false end
  local c = line:sub(idx, idx)
  if not is_word_char(c) then return false end
  if side == "start" then
    if idx == 1 then return true end
    local prev = line:sub(idx - 1, idx - 1)
    return not is_word_char(prev)
  else -- "end"
    if idx == #line then return true end
    local nxt = line:sub(idx + 1, idx + 1)
    return not is_word_char(nxt)
  end
end

-- Find next "w" motion target
local function next_word(buf)
  local line = buf.lines[buf.cursor_row] or ""
  local col  = buf.cursor_col
  -- Skip current word
  while col <= #line and is_word_char(line:sub(col, col)) do
    col = col + 1
  end
  -- Skip whitespace
  while col <= #line and line:sub(col, col):match("%s") do
    col = col + 1
  end
  if col > #line then
    -- Move to next non-empty line's first word
    if buf.cursor_row < #buf.lines then
      buf.cursor_row = buf.cursor_row + 1
      buf.cursor_col = 1
      local nl = buf.lines[buf.cursor_row] or ""
      local c = 1
      while c <= #nl and nl:sub(c, c):match("%s") do c = c + 1 end
      buf.cursor_col = math.max(1, c)
    else
      buf.cursor_col = #line
    end
  else
    buf.cursor_col = col
  end
end

-- Find previous "b" motion target
local function prev_word(buf)
  local line = buf.lines[buf.cursor_row] or ""
  local col  = buf.cursor_col - 1
  -- Skip whitespace backwards
  while col > 0 and line:sub(col, col):match("%s") do
    col = col - 1
  end
  if col < 1 then
    if buf.cursor_row > 1 then
      buf.cursor_row = buf.cursor_row - 1
      local nl = buf.lines[buf.cursor_row] or ""
      -- Jump to last word of previous line
      local c = #nl
      while c > 0 and nl:sub(c, c):match("%s") do c = c - 1 end
      while c > 1 and is_word_char(nl:sub(c - 1, c - 1)) do c = c - 1 end
      buf.cursor_col = math.max(1, c)
    else
      buf.cursor_col = 1
    end
    return
  end
  -- Skip current word backwards
  while col > 1 and is_word_char(line:sub(col - 1, col - 1)) do
    col = col - 1
  end
  buf.cursor_col = col
end

-- Find end-of-word "e" motion target
local function end_word(buf)
  local line = buf.lines[buf.cursor_row] or ""
  local col  = buf.cursor_col + 1
  -- Skip whitespace
  while col <= #line and line:sub(col, col):match("%s") do
    col = col + 1
  end
  if col > #line then
    if buf.cursor_row < #buf.lines then
      buf.cursor_row = buf.cursor_row + 1
      buf.cursor_col = 1
      local nl = buf.lines[buf.cursor_row] or ""
      local c = 1
      while c <= #nl and nl:sub(c, c):match("%s") do c = c + 1 end
      while c < #nl and is_word_char(nl:sub(c + 1, c + 1)) do c = c + 1 end
      buf.cursor_col = math.max(1, c)
    end
    return
  end
  -- Advance to last char of current word
  while col < #line and is_word_char(line:sub(col + 1, col + 1)) do
    col = col + 1
  end
  buf.cursor_col = col
end

-- ─────────────────────────────────────────────────────────
-- Selection helpers (Visual family)
-- ─────────────────────────────────────────────────────────
function VimEngine:_normalize_selection()
  if not self.visual_start then return nil, nil end
  local sr, sc = self.visual_start.row, self.visual_start.col
  local er, ec = self.buffer.cursor_row, self.buffer.cursor_col
  -- Ensure (sr,sc) <= (er,ec)
  if sr > er or (sr == er and sc > ec) then
    sr, sc, er, ec = er, ec, sr, sc
  end
  return sr, sc, er, ec
end

function VimEngine:selection_text()
  local sr, sc, er, ec = self:_normalize_selection()
  if not sr then return "" end
  local buf = self.buffer
  if self.mode == VimEngine.MODES.VISUAL then
    if sr == er then
      local line = buf.lines[sr] or ""
      return line:sub(sc, ec)
    else
      local parts = { (buf.lines[sr] or ""):sub(sc) }
      for r = sr + 1, er - 1 do
        table.insert(parts, buf.lines[r] or "")
      end
      table.insert(parts, (buf.lines[er] or ""):sub(1, ec))
      return table.concat(parts, "\n")
    end
  elseif self.mode == VimEngine.MODES.VLINE then
    local parts = {}
    for r = sr, er do
      table.insert(parts, (buf.lines[r] or ""))
    end
    return table.concat(parts, "\n")
  elseif self.mode == VimEngine.MODES.VBLOCK then
    -- Simplified: extract rectangle
    local parts = {}
    for r = sr, er do
      local line = buf.lines[r] or ""
      table.insert(parts, line:sub(sc, ec))
    end
    return table.concat(parts, "\n")
  end
  return ""
end

function VimEngine:_delete_selection()
  local sr, sc, er, ec = self:_normalize_selection()
  if not sr then return end
  local buf = self.buffer
  buf:snapshot()
  if self.mode == VimEngine.MODES.VISUAL then
    if sr == er then
      local line = buf.lines[sr] or ""
      buf.lines[sr] = line:sub(1, sc - 1) .. line:sub(ec + 1)
    else
      local first = (buf.lines[sr] or ""):sub(1, sc - 1)
      local last  = (buf.lines[er] or ""):sub(ec + 1)
      buf.lines[sr] = first .. last
      for i = er, sr + 1, -1 do
        table.remove(buf.lines, i)
      end
    end
  elseif self.mode == VimEngine.MODES.VLINE then
    for i = er, sr, -1 do
      table.remove(buf.lines, i)
    end
    if #buf.lines == 0 then buf.lines = { "" } end
  elseif self.mode == VimEngine.MODES.VBLOCK then
    for r = sr, er do
      local line = buf.lines[r] or ""
      buf.lines[r] = line:sub(1, sc - 1) .. line:sub(ec + 1)
    end
  end
  buf.cursor_row = sr
  buf.cursor_col = sc
  buf.is_dirty  = true
  clamp(buf)
end

function VimEngine:_yank_selection()
  local text = self:selection_text()
  self.buffer.yank_buffer = text
end

-- ─────────────────────────────────────────────────────────
-- Search (forward / backward)
-- ─────────────────────────────────────────────────────────
local function find_match(buf, query, from_row, from_col, forward)
  if not query or query == "" then return nil end
  local total = #buf.lines
  if forward then
    -- search current line after from_col
    local line = buf.lines[from_row] or ""
    local s = line:find(query, from_col + 1, true)
    if s then return from_row, s end
    -- search subsequent lines
    for r = from_row + 1, total do
      local p = (buf.lines[r] or ""):find(query, 1, true)
      if p then return r, p end
    end
    -- wrap
    for r = 1, from_row - 1 do
      local p = (buf.lines[r] or ""):find(query, 1, true)
      if p then return r, p end
    end
    local p = (buf.lines[from_row] or ""):find(query, 1, true)
    if p then return from_row, p end
  else
    -- backward: search current line before from_col
    local line = buf.lines[from_row] or ""
    local best = nil
    local start = 1
    while true do
      local p = line:find(query, start, true)
      if not p then break end
      if p < from_col then best = p end
      start = p + 1
    end
    if best then return from_row, best end
    -- search previous lines
    for r = from_row - 1, 1, -1 do
      local line_r = buf.lines[r] or ""
      local best_p = nil
      local s = 1
      while true do
        local p = line_r:find(query, s, true)
        if not p then break end
        best_p = p
        s = p + 1
      end
      if best_p then return r, best_p end
    end
    -- wrap
    for r = total, from_row + 1, -1 do
      local line_r = buf.lines[r] or ""
      local best_p = nil
      local s = 1
      while true do
        local p = line_r:find(query, s, true)
        if not p then break end
        best_p = p
        s = p + 1
      end
      if best_p then return r, best_p end
    end
  end
  return nil
end

function VimEngine:do_search(query, forward)
  self.last_search = { query = query, direction = forward and "fwd" or "bwd" }
  local r, c = find_match(self.buffer, query, self.buffer.cursor_row, self.buffer.cursor_col, forward)
  if r then
    self.buffer.cursor_row = r
    self.buffer.cursor_col = c
    return true
  end
  return false
end

function VimEngine:repeat_search(forward)
  if not self.last_search then return false end
  local dir = forward and (self.last_search.direction == "fwd") or (self.last_search.direction == "bwd")
  if forward then dir = true else dir = (self.last_search.direction == "bwd") end
  -- search next position
  local r, c = find_match(self.buffer, self.last_search.query,
    self.buffer.cursor_row, self.buffer.cursor_col + 1, forward)
  if r then
    self.buffer.cursor_row = r
    self.buffer.cursor_col = c
    return true
  end
  return false
end

-- ─────────────────────────────────────────────────────────
-- Scrolling helpers (zz / zt / zb / Ctrl-u / Ctrl-d)
-- ─────────────────────────────────────────────────────────
function VimEngine:scroll_cursor_center(viewport_rows)
  local buf = self.buffer
  buf.row_offset = math.max(0, buf.cursor_row - math.floor(viewport_rows / 2))
end

function VimEngine:scroll_cursor_top(viewport_rows)
  local buf = self.buffer
  buf.row_offset = math.max(0, buf.cursor_row - 1)
end

function VimEngine:scroll_cursor_bottom(viewport_rows)
  local buf = self.buffer
  buf.row_offset = math.max(0, buf.cursor_row - viewport_rows + 1)
end

function VimEngine:scroll_half_page_down(viewport_rows)
  local buf = self.buffer
  buf.cursor_row = math.min(#buf.lines, buf.cursor_row + math.max(1, math.floor(viewport_rows / 2)))
  clamp(buf)
end

function VimEngine:scroll_half_page_up(viewport_rows)
  local buf = self.buffer
  buf.cursor_row = math.max(1, buf.cursor_row - math.max(1, math.floor(viewport_rows / 2)))
  clamp(buf)
end

-- ─────────────────────────────────────────────────────────
-- Core mode transitions
-- ─────────────────────────────────────────────────────────
function VimEngine:enter_normal()
  self.mode = VimEngine.MODES.NORMAL
  self.pending_key = nil
  self.register_count = ""
  self.visual_start = nil
  self.visual_end   = nil
  -- In NORMAL, cursor cannot be past last char
  local ml = line_len(self.buffer)
  if self.buffer.cursor_col > ml and ml > 0 then
    self.buffer.cursor_col = ml
  end
end

function VimEngine:enter_insert(append_mode)
  self.mode = VimEngine.MODES.INSERT
  self.pending_key = nil
  if append_mode then
    self.buffer.cursor_col = self.buffer.cursor_col + 1
  end
  clamp(self.buffer)
end

function VimEngine:enter_replace()
  self.mode = VimEngine.MODES.REPLACE
  self.pending_key = nil
  clamp(self.buffer)
end

function VimEngine:enter_visual()
  self.mode = VimEngine.MODES.VISUAL
  self.visual_start = { row = self.buffer.cursor_row, col = self.buffer.cursor_col }
  self.visual_end   = { row = self.buffer.cursor_row, col = self.buffer.cursor_col }
end

function VimEngine:enter_vline()
  self.mode = VimEngine.MODES.VLINE
  self.visual_start = { row = self.buffer.cursor_row, col = 1 }
end

function VimEngine:enter_vblock()
  self.mode = VimEngine.MODES.VBLOCK
  self.visual_start = { row = self.buffer.cursor_row, col = self.buffer.cursor_col }
end

function VimEngine:enter_command()
  self.mode = VimEngine.MODES.COMMAND
  self.command_buffer = ""
end

function VimEngine:enter_search(forward)
  self.mode = VimEngine.MODES.SEARCH
  self.search_buffer = ""
  self._search_forward = forward
end

-- ─────────────────────────────────────────────────────────
-- Public: handle a single key
-- key is a string. Special keys: "esc" "enter" "backspace" "tab"
-- "up" "down" "left" "right" "home" "end" "pageup" "pagedown" "delete"
-- Ctrl keys: "ctrl_s" "ctrl_q" "ctrl_r" "ctrl_u" "ctrl_d" "ctrl_h" "ctrl_j" "ctrl_k" "ctrl_l" "ctrl_w"
-- ─────────────────────────────────────────────────────────
function VimEngine:handle(key, viewport_rows)
  viewport_rows = viewport_rows or 24
  local buf = self.buffer
  clamp(buf)

  -- Two-key pending state (for gg, dd, yy, cc, etc.)
  if self.pending_key then
    local result = self:_handle_pending(key, viewport_rows)
    if result ~= "continue" then
      self.pending_key = nil
      return result
    end
  end

  -- Count register (digits before command)
  if self.mode == VimEngine.MODES.NORMAL and key:match("^[1-9]$") then
    self.register_count = self.register_count .. key
    return "counting"
  end
  if self.mode == VimEngine.MODES.NORMAL and key == "0" and self.register_count ~= "" then
    self.register_count = self.register_count .. "0"
    return "counting"
  end

  -- Dispatch by mode
  if self.mode == VimEngine.MODES.NORMAL then
    return self:handle_normal(key, viewport_rows)
  elseif self.mode == VimEngine.MODES.INSERT then
    return self:handle_insert(key)
  elseif self.mode == VimEngine.MODES.REPLACE then
    return self:handle_replace(key)
  elseif self:is_visual_family() then
    return self:handle_visual(key, viewport_rows)
  elseif self.mode == VimEngine.MODES.COMMAND then
    return self:handle_command(key)
  elseif self.mode == VimEngine.MODES.SEARCH then
    return self:handle_search(key)
  end
  return nil
end

-- ─────────────────────────────────────────────────────────
-- NORMAL mode
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_normal(key, viewport_rows)
  local buf = self.buffer
  clamp(buf)
  local count = tonumber(self.register_count) or 1
  self.register_count = ""

  -- Mode transitions
  if key == "esc" then
    self.pending_key = nil
    return "stay"
  elseif key == "i" then
    self:enter_insert(false)
    return "insert"
  elseif key == "I" then
    -- Move to first non-blank, insert
    local line = buf.lines[buf.cursor_row] or ""
    local c = 1
    while c <= #line and line:sub(c, c):match("%s") do c = c + 1 end
    buf.cursor_col = math.max(1, c)
    self:enter_insert(false)
    return "insert"
  elseif key == "a" then
    self:enter_insert(true)
    return "insert"
  elseif key == "A" then
    buf.cursor_col = line_len(buf) + 1
    self:enter_insert(false)
    return "insert"
  elseif key == "o" then
    -- Open line below
    buf:snapshot()
    table.insert(buf.lines, buf.cursor_row + 1, "")
    buf.cursor_row = buf.cursor_row + 1
    buf.cursor_col = 1
    buf.is_dirty = true
    self:enter_insert(false)
    return "insert"
  elseif key == "O" then
    -- Open line above
    buf:snapshot()
    table.insert(buf.lines, buf.cursor_row, "")
    buf.cursor_col = 1
    buf.is_dirty = true
    self:enter_insert(false)
    return "insert"
  elseif key == "R" then
    self:enter_replace()
    return "replace"
  elseif key == "v" then
    self:enter_visual()
    return "visual"
  elseif key == "V" then
    self:enter_vline()
    return "vline"
  elseif key == "ctrl_v" then
    self:enter_vblock()
    return "vblock"
  elseif key == ":" then
    self:enter_command()
    return "command"
  elseif key == "/" then
    self:enter_search(true)
    return "search"
  elseif key == "?" then
    self:enter_search(false)
    return "search"
  end

  -- Motions
  if key == "h" or key == "left" then
    buf.cursor_col = math.max(1, buf.cursor_col - count)
    return "moved"
  elseif key == "l" or key == "right" then
    buf.cursor_col = math.min(line_len(buf), buf.cursor_col + count)
    return "moved"
  elseif key == "j" or key == "down" then
    buf.cursor_row = math.min(#buf.lines, buf.cursor_row + count)
    clamp(buf)
    return "moved"
  elseif key == "k" or key == "up" then
    buf.cursor_row = math.max(1, buf.cursor_row - count)
    clamp(buf)
    return "moved"
  elseif key == "w" then
    for _ = 1, count do next_word(buf) end
    return "moved"
  elseif key == "b" then
    for _ = 1, count do prev_word(buf) end
    return "moved"
  elseif key == "e" then
    for _ = 1, count do end_word(buf) end
    return "moved"
  elseif key == "0" or key == "home" then
    buf.cursor_col = 1
    return "moved"
  elseif key == "$" or key == "end" then
    buf.cursor_col = math.max(1, line_len(buf))
    return "moved"
  elseif key == "g" then
    self.pending_key = "g"
    return "pending"
  elseif key == "G" then
    if count > 1 then
      buf.cursor_row = math.min(#buf.lines, count)
    else
      buf.cursor_row = #buf.lines
    end
    buf.cursor_col = 1
    clamp(buf)
    return "moved"
  elseif key == "ctrl_u" then
    self:scroll_half_page_up(viewport_rows)
    return "scrolled"
  elseif key == "ctrl_d" then
    self:scroll_half_page_down(viewport_rows)
    return "scrolled"
  elseif key == "z" then
    self.pending_key = "z"
    return "pending"
  end

  -- Editing
  if key == "x" then
    -- Delete char under cursor
    buf:snapshot()
    local line = buf.lines[buf.cursor_row] or ""
    if buf.cursor_col <= #line then
      buf.yank_buffer = line:sub(buf.cursor_col, buf.cursor_col)
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. line:sub(buf.cursor_col + 1)
      buf.is_dirty = true
      if buf.cursor_col > line_len(buf) and buf.cursor_col > 1 then
        buf.cursor_col = buf.cursor_col - 1
      end
    end
    return "edited"
  elseif key == "d" then
    self.pending_key = "d"
    return "pending"
  elseif key == "D" then
    -- Delete to end of line
    buf:snapshot()
    local line = buf.lines[buf.cursor_row] or ""
    buf.yank_buffer = line:sub(buf.cursor_col)
    buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1)
    buf.is_dirty = true
    return "edited"
  elseif key == "c" then
    self.pending_key = "c"
    return "pending"
  elseif key == "C" then
    -- Change to end of line
    buf:snapshot()
    local line = buf.lines[buf.cursor_row] or ""
    buf.yank_buffer = line:sub(buf.cursor_col)
    buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1)
    buf.is_dirty = true
    self:enter_insert(false)
    return "insert"
  elseif key == "y" then
    self.pending_key = "y"
    return "pending"
  elseif key == "Y" then
    buf.yank_buffer = buf.lines[buf.cursor_row] or ""
    return "yanked"
  elseif key == "p" then
    -- Paste below (line) or after cursor (char)
    buf:snapshot()
    local yank = buf.yank_buffer
    if yank and yank:find("\n") then
      -- Multi-line paste: insert as new lines below
      local new_lines = {}
      for l in (yank .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(new_lines, l)
      end
      for i, l in ipairs(new_lines) do
        table.insert(buf.lines, buf.cursor_row + i, l)
      end
      buf.cursor_row = buf.cursor_row + 1
      buf.cursor_col = 1
    elseif yank then
      -- Single line: insert at cursor + 1
      local line = buf.lines[buf.cursor_row] or ""
      local pos = math.min(buf.cursor_col + 1, #line + 1)
      buf.lines[buf.cursor_row] = line:sub(1, pos - 1) .. yank .. line:sub(pos)
      buf.cursor_col = pos + #yank - 1
    end
    buf.is_dirty = true
    return "edited"
  elseif key == "P" then
    -- Paste above (line) or before cursor (char)
    buf:snapshot()
    local yank = buf.yank_buffer
    if yank and yank:find("\n") then
      local new_lines = {}
      for l in (yank .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(new_lines, l)
      end
      for i, l in ipairs(new_lines) do
        table.insert(buf.lines, buf.cursor_row + i - 1, l)
      end
      buf.cursor_col = 1
    elseif yank then
      local line = buf.lines[buf.cursor_row] or ""
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. yank .. line:sub(buf.cursor_col)
      buf.cursor_col = buf.cursor_col + #yank - 1
    end
    buf.is_dirty = true
    return "edited"
  elseif key == "u" then
    buf:undo()
    return "undo"
  elseif key == "ctrl_r" then
    buf:redo()
    return "redo"
  elseif key == "n" then
    self:repeat_search(true)
    return "searched"
  elseif key == "N" then
    self:repeat_search(false)
    return "searched"
  end

  return nil
end

-- ─────────────────────────────────────────────────────────
-- Two-key pending handler (gg, dd, yy, cc, zz, zt, zb)
-- ─────────────────────────────────────────────────────────
function VimEngine:_handle_pending(key, viewport_rows)
  local buf = self.buffer
  local count = tonumber(self.register_count) or 1
  self.register_count = ""

  if self.pending_key == "g" then
    if key == "g" then
      buf.cursor_row = math.min(#buf.lines, count)
      buf.cursor_col = 1
      clamp(buf)
      return "moved"
    elseif key == "G" then
      -- Go to first non-blank of last line
      buf.cursor_row = #buf.lines
      local line = buf.lines[buf.cursor_row] or ""
      local c = 1
      while c <= #line and line:sub(c, c):match("%s") do c = c + 1 end
      buf.cursor_col = math.max(1, c)
      return "moved"
    end
    return "noop"
  elseif self.pending_key == "d" then
    if key == "d" then
      -- Delete count lines
      buf:snapshot()
      local yanked = {}
      for _ = 1, math.min(count, #buf.lines - buf.cursor_row + 1) do
        local l = table.remove(buf.lines, buf.cursor_row)
        if l then table.insert(yanked, l) end
      end
      if #buf.lines == 0 then buf.lines = { "" } end
      buf.yank_buffer = table.concat(yanked, "\n")
      buf.cursor_col = 1
      buf.is_dirty = true
      clamp(buf)
      return "edited"
    elseif key == "w" then
      -- Delete word
      buf:snapshot()
      local line = buf.lines[buf.cursor_row] or ""
      local end_c = buf.cursor_col
      while end_c <= #line and is_word_char(line:sub(end_c, end_c)) do
        end_c = end_c + 1
      end
      while end_c <= #line and line:sub(end_c, end_c):match("%s") do
        end_c = end_c + 1
      end
      buf.yank_buffer = line:sub(buf.cursor_col, end_c - 1)
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. line:sub(end_c)
      buf.is_dirty = true
      return "edited"
    end
    return "noop"
  elseif self.pending_key == "c" then
    if key == "c" then
      -- Change line: delete line content, enter insert
      buf:snapshot()
      buf.yank_buffer = buf.lines[buf.cursor_row] or ""
      buf.lines[buf.cursor_row] = ""
      buf.cursor_col = 1
      buf.is_dirty = true
      self:enter_insert(false)
      return "insert"
    elseif key == "w" then
      -- Change word
      buf:snapshot()
      local line = buf.lines[buf.cursor_row] or ""
      local end_c = buf.cursor_col
      while end_c <= #line and is_word_char(line:sub(end_c, end_c)) do
        end_c = end_c + 1
      end
      buf.yank_buffer = line:sub(buf.cursor_col, end_c - 1)
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. line:sub(end_c)
      buf.is_dirty = true
      self:enter_insert(false)
      return "insert"
    end
    return "noop"
  elseif self.pending_key == "y" then
    if key == "y" then
      -- Yank line
      buf.yank_buffer = buf.lines[buf.cursor_row] or ""
      return "yanked"
    elseif key == "w" then
      local line = buf.lines[buf.cursor_row] or ""
      local end_c = buf.cursor_col
      while end_c <= #line and is_word_char(line:sub(end_c, end_c)) do
        end_c = end_c + 1
      end
      buf.yank_buffer = line:sub(buf.cursor_col, end_c - 1)
      return "yanked"
    end
    return "noop"
  elseif self.pending_key == "z" then
    if key == "z" then
      self:scroll_cursor_center(viewport_rows)
      return "scrolled"
    elseif key == "t" then
      self:scroll_cursor_top(viewport_rows)
      return "scrolled"
    elseif key == "b" then
      self:scroll_cursor_bottom(viewport_rows)
      return "scrolled"
    end
    return "noop"
  end

  return "noop"
end

-- ─────────────────────────────────────────────────────────
-- INSERT mode
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_insert(key)
  local buf = self.buffer
  if key == "esc" then
    -- Move cursor back one (vim convention)
    if buf.cursor_col > 1 then
      buf.cursor_col = buf.cursor_col - 1
    end
    self:enter_normal()
    return "normal"
  elseif key == "enter" then
    buf:insert_newline()
    return "inserted"
  elseif key == "backspace" then
    buf:delete_char()
    return "deleted"
  elseif key == "tab" then
    buf:insert_char("    ")
    return "inserted"
  elseif key == "up" then
    if buf.cursor_row > 1 then buf.cursor_row = buf.cursor_row - 1 end
    clamp(buf)
    return "moved"
  elseif key == "down" then
    if buf.cursor_row < #buf.lines then buf.cursor_row = buf.cursor_row + 1 end
    clamp(buf)
    return "moved"
  elseif key == "left" then
    if buf.cursor_col > 1 then buf.cursor_col = buf.cursor_col - 1 end
    return "moved"
  elseif key == "right" then
    buf.cursor_col = buf.cursor_col + 1
    clamp(buf)
    return "moved"
  elseif key == "home" then
    buf.cursor_col = 1
    return "moved"
  elseif key == "end" then
    buf.cursor_col = line_len(buf) + 1
    return "moved"
  elseif #key == 1 then
    buf:insert_char(key)
    return "inserted"
  end
  return nil
end

-- ─────────────────────────────────────────────────────────
-- REPLACE mode (single-char r-mode)
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_replace(key)
  local buf = self.buffer
  if key == "esc" then
    self:enter_normal()
    return "normal"
  elseif #key == 1 then
    buf:snapshot()
    local line = buf.lines[buf.cursor_row] or ""
    if buf.cursor_col <= #line then
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. key .. line:sub(buf.cursor_col + 1)
    else
      buf.lines[buf.cursor_row] = line .. key
    end
    buf.cursor_col = buf.cursor_col + 1
    buf.is_dirty = true
    -- Single-char replace then return to NORMAL (R mode would stay; using R = continuous)
    -- For continuous replace, keep mode
    return "replaced"
  elseif key == "backspace" then
    if buf.cursor_col > 1 then buf.cursor_col = buf.cursor_col - 1 end
    return "moved"
  end
  return nil
end

-- ─────────────────────────────────────────────────────────
-- VISUAL / V-LINE / V-BLOCK mode
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_visual(key, viewport_rows)
  local buf = self.buffer
  clamp(buf)
  local count = tonumber(self.register_count) or 1
  self.register_count = ""

  if key == "esc" then
    self:enter_normal()
    return "normal"
  end

  -- Motions (same as normal but update selection end)
  if key == "h" or key == "left" then
    buf.cursor_col = math.max(1, buf.cursor_col - count)
    return "moved"
  elseif key == "l" or key == "right" then
    buf.cursor_col = math.min(line_len(buf) + 1, buf.cursor_col + count)
    return "moved"
  elseif key == "j" or key == "down" then
    buf.cursor_row = math.min(#buf.lines, buf.cursor_row + count)
    clamp(buf)
    return "moved"
  elseif key == "k" or key == "up" then
    buf.cursor_row = math.max(1, buf.cursor_row - count)
    clamp(buf)
    return "moved"
  elseif key == "w" then
    for _ = 1, count do next_word(buf) end
    return "moved"
  elseif key == "b" then
    for _ = 1, count do prev_word(buf) end
    return "moved"
  elseif key == "e" then
    for _ = 1, count do end_word(buf) end
    return "moved"
  elseif key == "0" or key == "home" then
    buf.cursor_col = 1
    return "moved"
  elseif key == "$" or key == "end" then
    buf.cursor_col = math.max(1, line_len(buf))
    return "moved"
  elseif key == "g" then
    self.pending_key = "g"
    return "pending"
  elseif key == "G" then
    buf.cursor_row = #buf.lines
    buf.cursor_col = 1
    clamp(buf)
    return "moved"
  end

  -- Operators
  if key == "x" or key == "d" then
    self:_yank_selection()
    self:_delete_selection()
    self:enter_normal()
    return "edited"
  elseif key == "y" then
    self:_yank_selection()
    self:enter_normal()
    return "yanked"
  elseif key == "c" then
    self:_yank_selection()
    self:_delete_selection()
    self:enter_insert(false)
    return "insert"
  elseif key == "p" then
    -- Overwrite selection with yank
    self:_yank_selection()
    self:_delete_selection()
    if buf.yank_buffer then
      local line = buf.lines[buf.cursor_row] or ""
      buf.lines[buf.cursor_row] = line:sub(1, buf.cursor_col - 1) .. buf.yank_buffer .. line:sub(buf.cursor_col)
      buf.cursor_col = buf.cursor_col + #buf.yank_buffer
    end
    buf.is_dirty = true
    self:enter_normal()
    return "edited"
  elseif key == "r" then
    -- Replace selection char by char (pending next key)
    self.pending_key = "r_visual"
    return "pending"
  end

  return nil
end

-- ─────────────────────────────────────────────────────────
-- COMMAND mode (ex)
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_command(key)
  if key == "esc" then
    self:enter_normal()
    return "normal"
  elseif key == "enter" then
    local cmd = self.command_buffer
    self.command_buffer = ""
    self:enter_normal()
    return "command", cmd
  elseif key == "backspace" then
    if #self.command_buffer > 0 then
      self.command_buffer = self.command_buffer:sub(1, -2)
    else
      self:enter_normal()
    end
    return "command_edit"
  elseif #key == 1 then
    self.command_buffer = self.command_buffer .. key
    return "command_edit"
  end
  return nil
end

function VimEngine:command_text()
  return self.command_buffer
end

-- ─────────────────────────────────────────────────────────
-- SEARCH mode
-- ─────────────────────────────────────────────────────────
function VimEngine:handle_search(key)
  if key == "esc" then
    self:enter_normal()
    return "normal"
  elseif key == "enter" then
    local q = self.search_buffer
    self.search_buffer = ""
    self:enter_normal()
    if q ~= "" then
      self:do_search(q, self._search_forward)
      return "searched"
    end
    return "normal"
  elseif key == "backspace" then
    if #self.search_buffer > 0 then
      self.search_buffer = self.search_buffer:sub(1, -2)
    else
      self:enter_normal()
    end
    return "search_edit"
  elseif #key == 1 then
    self.search_buffer = self.search_buffer .. key
    return "search_edit"
  end
  return nil
end

function VimEngine:search_text()
  return self.search_buffer
end

-- ─────────────────────────────────────────────────────────
-- Status helpers
-- ─────────────────────────────────────────────────────────
function VimEngine:mode_label()
  return self.mode
end

function VimEngine:status_message()
  if self.mode == VimEngine.MODES.COMMAND then
    return ":" .. self.command_buffer
  elseif self.mode == VimEngine.MODES.SEARCH then
    return (self._search_forward and "/" or "?") .. self.search_buffer
  elseif self.pending_key then
    return "pending: " .. self.pending_key
  elseif self.register_count ~= "" then
    return "count: " .. self.register_count
  end
  return nil
end

return VimEngine
