-- src/finder.lua
-- Telescope-like fuzzy finder for RVM.
-- Supports modes: files / grep / buffers / recent / commands
--
-- The UI layer (src/ui.lua) is responsible for rendering this overlay;
-- this module is pure state + matching logic.

local Filesystem = require("src.filesystem")
local Config     = require("src.config.init")

local Finder = {}
Finder.__index = Finder

-- ─────────────────────────────────────────────────────────
-- Fuzzy match scoring (subsequence match + proximity bonus)
-- ─────────────────────────────────────────────────────────
local function fuzzy_score(query, text)
  if not query or query == "" then return 1, text end
  local t = text:lower()
  local q = query:lower()
  local score = 0
  local ti = 1
  local last_match = -1
  local highlighted = {}

  for qi = 1, #q do
    local qc = q:sub(qi, qi)
    local found = false
    while ti <= #t do
      if t:sub(ti, ti) == qc then
        score = score + 1
        if last_match == ti - 1 then
          score = score + 2  -- bonus for contiguous matches
        end
        last_match = ti
        table.insert(highlighted, ti)
        ti = ti + 1
        found = true
        break
      end
      ti = ti + 1
    end
    if not found then return -1, nil end
  end

  -- Bonus for matching at start of word boundaries
  for _, idx in ipairs(highlighted) do
    if idx == 1 or t:sub(idx - 1, idx - 1):match("[/_.%-]") then
      score = score + 3
    end
  end

  -- Penalty: longer text relative to query
  local length_penalty = #text / (#query + 1)
  return score / length_penalty, highlighted
end

-- ─────────────────────────────────────────────────────────
-- State
-- ─────────────────────────────────────────────────────────
function Finder.new()
  local self = setmetatable({}, Finder)
  self.visible      = false
  self.mode         = "files"     -- "files" | "grep" | "buffers" | "recent" | "commands"
  self.query        = ""
  self.results      = {}          -- list of { display=, path=, score=, highlights=, data= }
  self.selected     = 1
  self.scroll       = 1
  self.preview_text = ""
  self.cwd          = "."
  self.on_select    = nil         -- function(selected_entry, app)
  return self
end

-- ─────────────────────────────────────────────────────────
-- Modes
-- ─────────────────────────────────────────────────────────
function Finder:open(mode, opts)
  opts = opts or {}
  self.visible = true
  self.mode    = mode
  self.query   = ""
  self.results = {}
  self.selected = 1
  self.scroll  = 1
  self.preview_text = ""
  self.cwd     = opts.cwd or "."
  self.on_select = opts.on_select
  self:_refresh()
end

function Finder:close()
  self.visible = false
  self.results = {}
  self.query = ""
  self.preview_text = ""
end

function Finder:is_open()
  return self.visible
end

function Finder:get_mode()
  return self.mode
end

-- ─────────────────────────────────────────────────────────
-- Refresh candidate list based on mode
-- ─────────────────────────────────────────────────────────
function Finder:_refresh()
  self.results = {}
  local mode = self.mode

  if mode == "files" or mode == "recent" then
    self:_scan_files(mode == "recent")
  elseif mode == "grep" then
    -- For grep, query drives everything (we'll scan on each keystroke)
    if self.query ~= "" then
      self:_grep_workspace(self.query)
    end
  elseif mode == "buffers" then
    self:_collect_buffers()
  elseif mode == "commands" then
    self:_collect_commands()
  end

  -- Sort by score descending
  table.sort(self.results, function(a, b)
    return (a.score or 0) > (b.score or 0)
  end)

  self.selected = 1
  self.scroll = 1
  self:_update_preview()
end

-- ─────────────────────────────────────────────────────────
-- File scanning (files / recent modes)
-- ─────────────────────────────────────────────────────────
function Finder:_scan_files(recent_only)
  local max_depth = 6
  local max_results = 400
  local count = 0
  local visited = {}

  local function walk(dir, depth)
    if depth > max_depth or count >= max_results then return end
    if visited[dir] then return end
    visited[dir] = true
    local cmd = "ls -1Ap '" .. dir:gsub("'", "'\\''") .. "' 2>/dev/null"
    local h = io.popen(cmd)
    if not h then return end
    for line in h:lines() do
      if count >= max_results then break end
      local name = line:gsub("/$", "")
      if name ~= "." and name ~= ".." and not name:match("^%.git$") and not name:match("^node_modules$") and not name:match("^target$") and not name:match("^%.DS_Store$") then
        local full = dir
        if full:sub(-1) ~= "/" then full = full .. "/" end
        full = full .. name
        if line:sub(-1) == "/" then
          walk(full, depth + 1)
        else
          local score, hl = fuzzy_score(self.query, name)
          if score >= 0 then
            table.insert(self.results, {
              display = full:gsub("^%./", ""),
              path = full,
              name = name,
              score = score,
              highlights = hl,
            })
            count = count + 1
          end
        end
      end
    end
    h:close()
  end

  if recent_only then
    -- Look at recently modified files via find command
    local cmd = "find '" .. self.cwd:gsub("'", "'\\''") .. "' -type f -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/target/*' -printf '%T@ %p\\n' 2>/dev/null | sort -rn | head -50"
    local h = io.popen(cmd)
    if h then
      for line in h:lines() do
        local ts, path = line:match("^(%S+)%s+(.+)$")
        if path then
          local name = path:match("([^/\\]+)$") or path
          local score, hl = fuzzy_score(self.query, name)
          if score >= 0 then
            table.insert(self.results, {
              display = path,
              path = path,
              name = name,
              score = score,
              highlights = hl,
            })
          end
        end
      end
      h:close()
    end
  else
    walk(self.cwd, 0)
  end
end

-- ─────────────────────────────────────────────────────────
-- Workspace grep
-- ─────────────────────────────────────────────────────────
function Finder:_grep_workspace(query)
  if query == "" then return end
  -- Use ripgrep if available, else fall back to grep -r
  local cmd
  local rg_check = io.popen("command -v rg >/dev/null 2>&1 && echo ok")
  local has_rg = false
  if rg_check then
    local r = rg_check:read("*a")
    rg_check:close()
    has_rg = (r and r:find("ok")) and true or false
  end

  if has_rg then
    cmd = "rg --vimgrep --no-heading --max-count=50 --color=never -- " .. shell_quote(query) .. " '" .. self.cwd:gsub("'", "'\\''") .. "' 2>/dev/null | head -100"
  else
    cmd = "grep -rn --color=never --include='*.rs' --include='*.lua' --include='*.py' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.go' --include='*.java' --include='*.c' --include='*.cpp' --include='*.h' --include='*.hpp' --include='*.dart' --include='*.rb' --include='*.php' --include='*.vue' --include='*.svelte' --include='*.html' --include='*.css' --include='*.json' --include='*.md' -- " .. shell_quote(query) .. " '" .. self.cwd:gsub("'", "'\\''") .. "' 2>/dev/null | head -100"
  end

  local h = io.popen(cmd)
  if not h then return end
  for line in h:lines() do
    local path, row, col, text
    if has_rg then
      path, row, col, text = line:match("^([^:]+):(%d+):(%d*):(.*)$")
      if not path then
        path, row, text = line:match("^([^:]+):(%d+):(.*)$")
        col = "1"
      end
    else
      path, row, text = line:match("^([^:]+):(%d+):(.*)$")
      col = "1"
    end
    if path and text then
      local display = string.format("%s:%s  %s", path, row, truncate(text, 80))
      local score, hl = fuzzy_score(self.query, path .. " " .. text)
      if score >= 0 then
        table.insert(self.results, {
          display = display,
          path = path,
          row = tonumber(row) or 1,
          col = tonumber(col) or 1,
          text = text,
          score = score,
          highlights = hl,
        })
      end
    end
  end
  h:close()
end

-- ─────────────────────────────────────────────────────────
-- Buffer mode
-- ─────────────────────────────────────────────────────────
function Finder:_collect_buffers()
  if not self.app_ref or not self.app_ref.buffers then return end
  for i, b in ipairs(self.app_ref.buffers) do
    local name = b.file_path and b.file_path:match("([^/\\]+)$") or "Untitled"
    local full = b.file_path or "Untitled"
    local dirty = b.is_dirty and " [+]" or ""
    local score, hl = fuzzy_score(self.query, name)
    if score >= 0 then
      table.insert(self.results, {
        display = full .. dirty,
        path = full,
        buf_index = i,
        name = name,
        score = score,
        highlights = hl,
      })
    end
  end
end

-- ─────────────────────────────────────────────────────────
-- Commands mode
-- ─────────────────────────────────────────────────────────
function Finder:_collect_commands()
  local cmds = {
    { display = "Save File",      action = "file_save" },
    { display = "Quit Editor",    action = "app_quit" },
    { display = "Toggle Explorer", action = "explorer_toggle" },
    { display = "Reveal Current in Explorer", action = "explorer_reveal" },
    { display = "Cycle Themes",   action = "theme_cycle" },
    { display = "Cycle Styles",   action = "style_cycle" },
    { display = "Format Buffer",  action = "lsp_format" },
    { display = "LSP Diagnostics", action = "diagnostics_panel" },
    { display = "LSP Hover",      action = "lsp_hover" },
    { display = "LSP Definition", action = "lsp_definition" },
    { display = "LSP References", action = "lsp_references" },
    { display = "LSP Code Action", action = "lsp_code_action" },
    { display = "LSP Rename",     action = "lsp_rename" },
    { display = "Next Buffer",    action = "buffer_next" },
    { display = "Prev Buffer",    action = "buffer_prev" },
    { display = "Close Buffer",   action = "buffer_delete" },
    { display = "Close Other Buffers", action = "buffer_close_others" },
    { display = "New Buffer",     action = "buffer_new" },
    { display = "Git Status",     action = "git_status" },
    { display = "Git Diff",       action = "git_diff" },
    { display = "Git Commit",    action = "git_commit" },
    { display = "Git Push",       action = "git_push" },
    { display = "Git Log",        action = "git_log" },
    { display = "Git Stage All",  action = "git_stage_all" },
    { display = "Git Unstage All", action = "git_unstage_all" },
    { display = "Toggle Terminal", action = "terminal_toggle" },
    { display = "New Terminal",    action = "terminal_new" },
    { display = "Window Split",   action = "window_split" },
    { display = "Window VSplit",  action = "window_vsplit" },
    { display = "Close Window",   action = "window_close" },
    { display = "Focus Left",     action = "window_focus_left" },
    { display = "Focus Down",     action = "window_focus_down" },
    { display = "Focus Up",       action = "window_focus_up" },
    { display = "Focus Right",    action = "window_focus_right" },
    { display = "Project Switcher", action = "project_switch" },
    { display = "Project Dashboard", action = "project_dashboard" },
    { display = "Project Files",   action = "project_files" },
    { display = "Project Grep",    action = "project_grep" },
    { display = "Recent Projects", action = "project_recent" },
    { display = "Undo",            action = "edit_undo" },
    { display = "Redo",            action = "edit_redo" },
    { display = "Toggle Icons Mode", action = "icons_toggle" },
    { display = "Find Files",      action = "finder_files" },
    { display = "Live Grep",       action = "finder_grep" },
    { display = "Buffers",         action = "finder_buffers" },
    { display = "Recent Files",   action = "finder_recent" },
  }
  for _, c in ipairs(cmds) do
    local score, hl = fuzzy_score(self.query, c.display)
    if score >= 0 then
      table.insert(self.results, {
        display = c.display,
        action = c.action,
        score = score,
        highlights = hl,
      })
    end
  end
end

-- ─────────────────────────────────────────────────────────
-- Preview
-- ─────────────────────────────────────────────────────────
function Finder:_update_preview()
  self.preview_text = ""
  local sel = self.results[self.selected]
  if not sel then return end
  if self.mode == "files" or self.mode == "recent" then
    if sel.path then
      local h = io.open(sel.path, "r")
      if h then
        local lines = {}
        for i = 1, 30 do
          local l = h:read("*l")
          if not l then break end
          table.insert(lines, l)
        end
        h:close()
        self.preview_text = table.concat(lines, "\n")
      end
  elseif self.mode == "grep" then
      self.preview_text = sel.text or ""
    end
  end
end

-- ─────────────────────────────────────────────────────────
-- Input handling
-- ─────────────────────────────────────────────────────────
function Finder:handle(key, app)
  if not self.visible then return false end
  self.app_ref = app

  if key == "esc" then
    self:close()
    return true
  elseif key == "enter" then
    local sel = self.results[self.selected]
    if sel then
      self:_select(sel, app)
    end
    self:close()
    return true
  elseif key == "up" or key == "ctrl_p" then
    if self.selected > 1 then self.selected = self.selected - 1 end
    self:_update_preview()
    return true
  elseif key == "down" or key == "ctrl_n" then
    if self.selected < #self.results then self.selected = self.selected + 1 end
    self:_update_preview()
    return true
  elseif key == "pageup" then
    self.selected = math.max(1, self.selected - 10)
    self:_update_preview()
    return true
  elseif key == "pagedown" then
    self.selected = math.min(#self.results, self.selected + 10)
    self:_update_preview()
    return true
  elseif key == "backspace" then
    if #self.query > 0 then
      self.query = self.query:sub(1, -2)
      self:_refresh()
    else
      self:close()
    end
    return true
  elseif #key == 1 then
    self.query = self.query .. key
    self:_refresh()
    return true
  end

  return false
end

-- ─────────────────────────────────────────────────────────
-- Selection dispatch
-- ─────────────────────────────────────────────────────────
function Finder:_select(sel, app)
  if not app then return end

  if self.mode == "files" or self.mode == "recent" then
    if sel.path then
      app:open_buffer(sel.path)
      app.status_msg = "Opened " .. sel.path
    end
  elseif self.mode == "grep" then
    if sel.path then
      app:open_buffer(sel.path)
      if app.buffer and sel.row then
        app.buffer.cursor_row = sel.row
        app.buffer.cursor_col  = sel.col or 1
      end
      app.status_msg = "Jumped to " .. sel.path .. ":" .. (sel.row or 1)
    end
  elseif self.mode == "buffers" then
    if sel.buf_index and app.buffers[sel.buf_index] then
      app.buf_index = sel.buf_index
      app.buffer = app.buffers[sel.buf_index]
      app.show_dashboard = false
    end
  elseif self.mode == "commands" then
    if sel.action and app.dispatch_action then
      app:dispatch_action(sel.action)
    end
  end

  if self.on_select then self.on_select(sel, app) end
end

-- ─────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────
function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function truncate(s, max_w)
  if #s <= max_w then return s end
  return s:sub(1, max_w - 1) .. "…"
end

return Finder
