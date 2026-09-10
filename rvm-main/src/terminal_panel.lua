-- src/terminal_panel.lua
-- Integrated terminal panel for RVM.
-- This module does NOT hardcode font, font size, background, or transparency.
-- It defers to the user's terminal emulator for all visual rendering.
--
-- Implementation approach: spawn a PTY-backed shell process and stream its
-- output to a buffer; send keystrokes from the editor to the shell stdin.
-- For pure-Lua environment without a PTY library, we use a pipe-based
-- sub-process model that works on most POSIX systems.

local Terminal = require("src.terminal")

local TerminalPanel = {}
TerminalPanel.__index = TerminalPanel

-- ─────────────────────────────────────────────────────────
-- State
-- ─────────────────────────────────────────────────────────
function TerminalPanel.new()
  local self = setmetatable({}, TerminalPanel)
  self.visible        = false
  self.position       = "bottom"     -- "bottom" | "right" | "float" | "hidden"
  self.height         = 10            -- bottom panel rows
  self.width          = 60            -- right panel cols
  self.scrollback     = {}            -- list of lines
  self.scrollback_max = 5000
  self.input_buffer   = ""
  self.cursor         = 1
  self.history        = {}            -- list of past commands
  self.history_idx    = 0
  self.cmd_running    = false
  self.current_cmd    = nil
  self.process_pid    = nil
  self.shell          = os.getenv("SHELL") or "bash"
  self.cwd            = os.getenv("PWD") or "."
  return self
end

function TerminalPanel:toggle()
  if self.position == "hidden" then
    self.position = "bottom"
    self.visible  = true
  else
    self.visible = not self.visible
  end
end

function TerminalPanel:open(position)
  self.position = position or "bottom"
  self.visible  = true
end

function TerminalPanel:close()
  self.visible = false
end

function TerminalPanel:is_open()
  return self.visible
end

-- ─────────────────────────────────────────────────────────
-- Run a command synchronously, capture output
-- ─────────────────────────────────────────────────────────
function TerminalPanel:run(cmd, cwd)
  -- Pre-write the prompt line
  local prompt = "$ " .. cmd
  table.insert(self.scrollback, prompt)
  self:_trim_scrollback()

  local full_cmd = cwd and string.format("cd %s && %s", "'" .. cwd:gsub("'", "'\\''") .. "'", cmd) or cmd
  local handle = io.popen(full_cmd .. " 2>&1", "r")
  if not handle then
    table.insert(self.scrollback, "[error] failed to spawn process")
    return
  end
  self.cmd_running = true
  self.current_cmd = cmd
  for line in handle:lines() do
    table.insert(self.scrollback, line)
    self:_trim_scrollback()
  end
  handle:close()
  self.cmd_running = false
  self.current_cmd = nil
  table.insert(self.history, cmd)
  self.history_idx = #self.history + 1
  self.cursor = 1
end

function TerminalPanel:_trim_scrollback()
  if #self.scrollback > self.scrollback_max then
    local overflow = #self.scrollback - self.scrollback_max
    for _ = 1, overflow do
      table.remove(self.scrollback, 1)
    end
  end
end

-- ─────────────────────────────────────────────────────────
-- Input handling (called when panel is focused)
-- ─────────────────────────────────────────────────────────
function TerminalPanel:handle(key, app)
  if key == "esc" then
    -- Esc leaves terminal focus back to editor
    if app then app.terminal_focus = false end
    return true
  elseif key == "ctrl_c" then
    if self.input_buffer ~= "" then
      self.input_buffer = ""
    else
      table.insert(self.scrollback, "^C")
    end
    self.cmd_running = false
    return true
  elseif key == "ctrl_l" then
    self.scrollback = {}
    return true
  elseif key == "up" then
    -- Recall previous command from history
    if self.history_idx > 1 then
      self.history_idx = self.history_idx - 1
      self.input_buffer = self.history[self.history_idx] or ""
    end
    return true
  elseif key == "down" then
    if self.history_idx < #self.history then
      self.history_idx = self.history_idx + 1
      self.input_buffer = self.history[self.history_idx] or ""
    else
      self.input_buffer = ""
    end
    return true
  elseif key == "left" then
    if self.cursor > 1 then self.cursor = self.cursor - 1 end
    return true
  elseif key == "right" then
    if self.cursor <= #self.input_buffer then self.cursor = self.cursor + 1 end
    return true
  elseif key == "home" then
    self.cursor = 1
    return true
  elseif key == "end" then
    self.cursor = #self.input_buffer + 1
    return true
  elseif key == "enter" then
    local cmd = self.input_buffer
    self.input_buffer = ""
    self.cursor = 1
    if cmd:match("^exit%s*$") or cmd:match("^quit%s*$") then
      self:close()
      if app then app.terminal_focus = false end
      return true
    end
    self:run(cmd, self.cwd)
    return true
  elseif key == "backspace" then
    if self.cursor > 1 then
      self.input_buffer = self.input_buffer:sub(1, self.cursor - 2) .. self.input_buffer:sub(self.cursor)
      self.cursor = self.cursor - 1
    end
    return true
  elseif #key == 1 then
    self.input_buffer = self.input_buffer:sub(1, self.cursor - 1) .. key .. self.input_buffer:sub(self.cursor)
    self.cursor = self.cursor + 1
    return true
  end
  return false
end

-- ─────────────────────────────────────────────────────────
-- Render data for UI layer
-- ─────────────────────────────────────────────────────────
function TerminalPanel:visible_lines(max_rows)
  max_rows = max_rows or self.height
  if #self.scrollback <= max_rows - 1 then
    return self.scrollback
  else
    local start = #self.scrollback - (max_rows - 1) + 1
    local out = {}
    for i = start, #self.scrollback do
      table.insert(out, self.scrollback[i])
    end
    return out
  end
end

function TerminalPanel:input_line()
  return "$ " .. self.input_buffer
end

function TerminalPanel:set_cwd(cwd)
  self.cwd = cwd or "."
end

return TerminalPanel
