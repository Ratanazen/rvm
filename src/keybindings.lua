-- src/keybindings.lua
-- RVM keybinding dispatcher (LazyVim-style with <leader>-space chords).
-- Architecture: Input → Mode → Keymap → Command → Editor
-- (per spec requirement #2)
--
-- This module wires together:
--   - VimEngine     (NORMAL/INSERT/VISUAL/V-LINE/V-BLOCK/COMMAND/SEARCH/REPLACE)
--   - WhichKey      (grouped leader popup)
--   - Finder        (fuzzy file/grep/buffer finder)
--   - Git           (status/diff/commit/push/pull/log/blame)
--   - TerminalPanel (integrated shell panel)
--   - Window        (split/vsplit/resize/close)

local Commands     = require("src.commands")
local Search       = require("src.search")
local Theme        = require("src.theme")
local Styles       = require("src.styles")
local LSP          = require("src.lsp")
local Buffer       = require("src.buffer")
local VimEngine    = require("src.vim_engine")
local WhichKey     = require("src.whichkey")
local Finder       = require("src.finder")
local Git          = require("src.git")
local TerminalPanel= require("src.terminal_panel")
local Project      = require("src.project")

local Keybindings = {}

-- ─────────────────────────────────────────────────────────
-- Initialize per-app sub-systems
-- ─────────────────────────────────────────────────────────
function Keybindings.init(app)
  app.vim          = VimEngine.new(app.buffer)
  app.whichkey     = WhichKey.new()
  app.finder       = Finder.new()
  app.terminal     = TerminalPanel.new()
  app.git_state    = { last_diff = "", last_log = {}, last_status = {} }
  app.terminal_focus = false
  app.explorer_focus = false
end

-- ─────────────────────────────────────────────────────────
-- Dispatch a chord action name (called from which-key completion)
-- ─────────────────────────────────────────────────────────
function Keybindings.dispatch_action(app, action)
  if not action then return end

  local handler = Keybindings.actions[action]
  if handler then
    handler(app)
  else
    app.status_msg = "Unknown action: " .. tostring(action)
  end
end

-- Expose on app for finder commands mode
function App_dispatch_action_stub(app, action)
  Keybindings.dispatch_action(app, action)
end

-- ─────────────────────────────────────────────────────────
-- Action handlers
-- ─────────────────────────────────────────────────────────
Keybindings.actions = {}

-- File ops
Keybindings.actions.file_save = function(app)
  -- Use App:save_buffer() to honor format-on-save config (per spec #18)
  if app.save_buffer then
    app:save_buffer()
  else
    local ok, err = app.buffer:save()
    app.status_msg = ok and ("Saved " .. (app.buffer.file_path or "untitled")) or ("Save error: " .. tostring(err))
  end
end
Keybindings.actions.app_quit = function(app)
  if app.buffer.is_dirty then
    app.status_msg = "Unsaved changes! Use Space+Q to force quit"
  else
    app.should_quit = true
  end
end
Keybindings.actions.app_force_quit = function(app)
  app.should_quit = true
end

-- Finders (Telescope-like)
Keybindings.actions.finder_files = function(app)
  app.finder:open("files", { cwd = app.project and app.project.root or "." })
end
Keybindings.actions.finder_grep = function(app)
  app.finder:open("grep", { cwd = app.project and app.project.root or "." })
end
Keybindings.actions.finder_buffers = function(app)
  app.finder.app_ref = app
  app.finder:open("buffers")
end
Keybindings.actions.finder_recent = function(app)
  app.finder:open("recent", { cwd = app.project and app.project.root or "." })
end
Keybindings.actions.finder_commands = function(app)
  app.finder.app_ref = app
  app.finder:open("commands")
end
Keybindings.actions.finder_help = function(app)
  app.status_msg = "Help: <leader>ff find, <leader>fg grep, <leader>fb buffers, :w save, :q quit"
end
Keybindings.actions.finder_keymaps = function(app)
  app.status_msg = "Keymaps: see README.md / which-key popup (press Space)"
end

-- Git
Keybindings.actions.git_status = function(app)
  if not Git.is_repo(app.project and app.project.root or ".") then
    app.status_msg = "Not a git repository"
    return
  end
  if Git.has_lazygit() then
    -- Suspend raw mode, run lazygit, resume
    local Terminal = require("src.terminal")
    Terminal.disable_raw_mode()
    Git.launch_lazygit(app.project and app.project.root or ".")
    Terminal.enable_raw_mode()
    app.status_msg = "lazygit session ended"
  else
    local entries = Git.status(app.project and app.project.root or ".")
    app.git_state.last_status = entries
    local counts = Git.status_summary(app.project and app.project.root or ".")
    app.status_msg = string.format("Git: %d modified, %d added, %d untracked",
      counts.modified, counts.added, counts.untracked)
  end
end
Keybindings.actions.git_diff = function(app)
  local diff = Git.diff(app.project and app.project.root or ".")
  app.git_state.last_diff = diff
  app.status_msg = "Git diff: " .. #diff .. " chars (use :gitdiff to view)"
end
Keybindings.actions.git_commit = function(app)
  -- Enter command mode with :GitCommit pre-filled
  app.vim:enter_command()
  app.vim.command_buffer = "GitCommit "
end
Keybindings.actions.git_push = function(app)
  local out = Git.push(app.project and app.project.root or ".")
  app.status_msg = "Git push: " .. out:sub(1, 80)
end
Keybindings.actions.git_log = function(app)
  app.git_state.last_log = Git.log(app.project and app.project.root or ".", 30)
  app.status_msg = "Git log: " .. #app.git_state.last_log .. " entries"
end
Keybindings.actions.git_branch = function(app)
  app.vim:enter_command()
  app.vim.command_buffer = "GitCheckout "
end
Keybindings.actions.git_stage_all = function(app)
  Git.stage_all(app.project and app.project.root or ".")
  app.status_msg = "All changes staged"
end
Keybindings.actions.git_unstage_all = function(app)
  Git.unstage_all(app.project and app.project.root or ".")
  app.status_msg = "All changes unstaged"
end

-- Buffers
Keybindings.actions.buffer_delete = function(app)
  app:close_buffer()
  app.status_msg = "Buffer closed"
end
Keybindings.actions.buffer_close_others = function(app)
  if #app.buffers <= 1 then return end
  local keep_idx = app.buf_index
  local keep = app.buffers[keep_idx]
  app.buffers = { keep }
  app.buf_index = 1
  app.buffer = keep
  app.status_msg = "Closed other buffers"
end
Keybindings.actions.buffer_next = function(app)
  app:next_buffer()
end
Keybindings.actions.buffer_prev = function(app)
  app:prev_buffer()
end
Keybindings.actions.buffer_new = function(app)
  app:open_buffer(nil)
  app.status_msg = "New empty buffer"
end
Keybindings.actions.buffer_list = function(app)
  app.finder.app_ref = app
  app.finder:open("buffers")
end

-- Projects
Keybindings.actions.project_switch = function(app)
  -- Use finder in "files" mode but with project list as candidates
  app.finder:open("files", {
    cwd = app.project and app.project.root or ".",
    on_select = function(sel)
      -- Switch project root
      if sel and sel.path and app.filesystem then
        app.filesystem.root = sel.path
        app.filesystem:scan_initial()
        app.project = Project.detect(sel.path)
        app.status_msg = "Project: " .. (app.project.name or sel.path)
        Project.recent_add(sel.path)
      end
    end,
  })
end
Keybindings.actions.project_files = function(app)
  app.finder:open("files", { cwd = app.project and app.project.root or "." })
end
Keybindings.actions.project_grep = function(app)
  app.finder:open("grep", { cwd = app.project and app.project.root or "." })
end
Keybindings.actions.project_recent = function(app)
  -- Recent projects as a finder (use files mode but pre-seed with project list)
  app.finder:open("files", {
    cwd = app.project and app.project.root or ".",
    on_select = function(sel)
      if sel and sel.path then
        if app.filesystem then
          app.filesystem.root = sel.path
          app.filesystem:scan_initial()
        end
        app.project = Project.detect(sel.path)
        Project.recent_add(sel.path)
        app.status_msg = "Switched to " .. sel.path
      end
    end,
  })
end
Keybindings.actions.project_dashboard = function(app)
  app.show_dashboard = true
  app.status_msg = "Project Dashboard"
end

-- LSP
Keybindings.actions.lsp_hover = function(app)
  local details = LSP.hover_details(app.buffer)
  app.hover_data = details
  app.show_hover = true
  app.status_msg = details.title .. (details.subtitle and (" | " .. details.subtitle) or "")
end
Keybindings.actions.lsp_definition = function(app)
  local row, col = LSP.goto_definition(app.buffer)
  if row then
    app.buffer.cursor_row = row
    app.buffer.cursor_col = col
    app.status_msg = "Jumped to definition at line " .. row
  else
    app.status_msg = "No definition found"
  end
end
Keybindings.actions.lsp_references = function(app)
  local refs = LSP.goto_references(app.buffer)
  app.status_msg = string.format("Found %d references", #refs)
end
Keybindings.actions.lsp_code_action = function(app)
  local actions = LSP.code_actions(app.buffer)
  app.status_msg = "Code actions: " .. table.concat({ actions[1] and actions[1].title or "none" }, ", ")
end
Keybindings.actions.lsp_rename = function(app)
  app.vim:enter_command()
  app.vim.command_buffer = "Rename "
end
Keybindings.actions.lsp_format = function(app)
  LSP.format(app.buffer)
  app.status_msg = "Buffer formatted"
end
Keybindings.actions.lsp_signature = function(app)
  app.status_msg = "Signature help (placeholder)"
end
Keybindings.actions.lsp_workspace_syms = function(app)
  app.finder:open("grep", { cwd = app.project and app.project.root or "." })
end

-- Diagnostics
Keybindings.actions.diagnostics_panel = function(app)
  local diags = LSP.diagnostics(app.buffer)
  app.git_state.last_status = diags  -- reuse field for diagnostics list
  if #diags > 0 then
    local d = diags[1]
    app.status_msg = string.format("Diagnostics: %d issues. First: [%s] L%d %s",
      #diags, d.level, d.line, d.message)
  else
    app.status_msg = "Diagnostics: 0 issues (clean)"
  end
end
Keybindings.actions.diagnostics_next = function(app)
  local diags = LSP.diagnostics(app.buffer)
  local cur = app.buffer.cursor_row
  for _, d in ipairs(diags) do
    if d.line > cur then
      app.buffer.cursor_row = d.line
      app.status_msg = string.format("[%s] L%d: %s", d.level, d.line, d.message)
      return
    end
  end
  app.status_msg = "No more diagnostics"
end
Keybindings.actions.diagnostics_prev = function(app)
  local diags = LSP.diagnostics(app.buffer)
  local cur = app.buffer.cursor_row
  for i = #diags, 1, -1 do
    if diags[i].line < cur then
      app.buffer.cursor_row = diags[i].line
      app.status_msg = string.format("[%s] L%d: %s", diags[i].level, diags[i].line, diags[i].message)
      return
    end
  end
  app.status_msg = "No previous diagnostic"
end
Keybindings.actions.diagnostics_open = function(app)
  Keybindings.actions.diagnostics_panel(app)
end

-- Terminal
Keybindings.actions.terminal_toggle = function(app)
  if not app.terminal then
    app.terminal = TerminalPanel.new()
  end
  if app.project and app.project.root then
    app.terminal:set_cwd(app.project.root)
  end
  app.terminal:toggle()
  app.terminal_focus = app.terminal:is_open()
  app.status_msg = app.terminal:is_open() and "Terminal opened" or "Terminal closed"
end
Keybindings.actions.terminal_float = function(app)
  if not app.terminal then app.terminal = TerminalPanel.new() end
  app.terminal:open("float")
  app.terminal_focus = true
end
Keybindings.actions.terminal_new = function(app)
  if not app.terminal then app.terminal = TerminalPanel.new() end
  app.terminal:open("bottom")
  app.terminal_focus = true
  app.status_msg = "Terminal opened"
end

-- Explorer
Keybindings.actions.explorer_toggle = function(app)
  if app.filesystem then
    app.filesystem.is_visible = not app.filesystem.is_visible
    app.explorer_focus = app.filesystem.is_visible
    app.status_msg = app.filesystem.is_visible and "Explorer opened" or "Explorer closed"
  else
    app.status_msg = "No workspace open (use: rvm .)"
  end
end

Keybindings.actions.explorer_reveal = function(app)
  if app.reveal_current_in_explorer then
    local ok = app:reveal_current_in_explorer()
    app.status_msg = ok and "Revealed current file in explorer" or "No file open to reveal"
  else
    app.status_msg = "Reveal not supported in this build"
  end
end

-- Theme / style / icons / undo / redo
Keybindings.actions.theme_cycle = function(app)
  app.theme_index = (app.theme_index % #Theme.list) + 1
  app.theme = Theme.list[app.theme_index]
  app.status_msg = "Theme: " .. app.theme.name
end
Keybindings.actions.style_cycle = function(app)
  local cur_id = app.style and app.style.id or "rvm-classic"
  local next_idx = 1
  for i, st in ipairs(Styles.list) do
    if st.id == cur_id then next_idx = (i % #Styles.list) + 1; break end
  end
  app.style = Styles.list[next_idx]
  if app.filesystem then app.filesystem.is_visible = app.style.sidebar end
  app.status_msg = "Style: " .. app.style.name
end
Keybindings.actions.icons_toggle = function(app)
  local TerminalGraphics = require("src.terminal_graphics")
  local next_mode = { auto = "image", image = "glyph", glyph = "auto" }
  local cur = TerminalGraphics.mode
  local m = next_mode[cur] or "auto"
  TerminalGraphics.set_mode(m)
  if m == "glyph" then TerminalGraphics.clear_all() end
  app.status_msg = "Icons Mode: " .. m
end
Keybindings.actions.edit_undo = function(app)
  app.buffer:undo()
  app.status_msg = "Undo"
end
Keybindings.actions.edit_redo = function(app)
  app.buffer:redo()
  app.status_msg = "Redo"
end

-- Window (split/vsplit/resize/navigation)
Keybindings.actions.window_split = function(app)
  if app.workspace then app.workspace:split("h") end
  app.status_msg = "Window split horizontal"
end
Keybindings.actions.window_vsplit = function(app)
  if app.workspace then app.workspace:split("v") end
  app.status_msg = "Window split vertical"
end
Keybindings.actions.window_close = function(app)
  if app.workspace then app.workspace:close_active() end
  app.status_msg = "Window closed"
end
Keybindings.actions.window_close_others = function(app)
  if app.workspace then app.workspace:close_others() end
  app.status_msg = "Closed other windows"
end
Keybindings.actions.window_focus_left = function(app) if app.workspace then app.workspace:focus_left() end end
Keybindings.actions.window_focus_down = function(app) if app.workspace then app.workspace:focus_down() end end
Keybindings.actions.window_focus_up   = function(app) if app.workspace then app.workspace:focus_up() end end
Keybindings.actions.window_focus_right= function(app) if app.workspace then app.workspace:focus_right() end end
Keybindings.actions.window_equalize = function(app)
  if app.workspace then app.workspace:equalize() end
  app.status_msg = "Windows equalized"
end
Keybindings.actions.window_inc_h = function(app) if app.workspace then app.workspace:inc_height() end end
Keybindings.actions.window_dec_h = function(app) if app.workspace then app.workspace:dec_height() end end
Keybindings.actions.window_inc_w = function(app) if app.workspace then app.workspace:inc_width() end end
Keybindings.actions.window_dec_w = function(app) if app.workspace then app.workspace:dec_width() end end

-- ─────────────────────────────────────────────────────────
-- Main dispatcher: per-frame key handling
-- ─────────────────────────────────────────────────────────
function Keybindings.handle(key, app)
  -- Ensure sub-systems are initialized
  if not app.vim then Keybindings.init(app) end

  -- Hover popover dismiss on any non-h/Space key
  if app.show_hover then
    if key == "esc" then
      app.show_hover = false
      app.hover_data = nil
      return
    elseif key ~= "h" and key ~= " " then
      app.show_hover = false
      app.hover_data = nil
    end
  end

  -- Terminal panel takes precedence if focused
  if app.terminal_focus and app.terminal and app.terminal:is_open() then
    if app.terminal:handle(key, app) then return end
  end

  -- Finder overlay takes precedence when open
  if app.finder:is_open() then
    if app.finder:handle(key, app) then return end
  end

  -- Lazy plugin panel
  if app.show_lazy then
    if key == "esc" or key == "q" then app.show_lazy = false end
    return
  end

  -- Which-key overlay
  if app.whichkey:is_open() then
    local kind, payload = app.whichkey:feed(key)
    if kind == "chord" then
      Keybindings.dispatch_action(app, payload)
    elseif kind == "cancel" then
      app.status_msg = "Leader cancelled"
    elseif kind == "prefix" then
      app.status_msg = "Which-key: " .. payload
    end
    return
  end

  -- Universal control keys & VS Code shortcuts
  if key == "ctrl_s" then
    Keybindings.actions.file_save(app)
    return
  elseif key == "ctrl_q" then
    app.should_quit = true
    return
  elseif key == "ctrl_p" or key == "ctrl_shift_p" then
    Keybindings.actions.finder_files(app)
    return
  elseif key == "ctrl_b" then
    Keybindings.actions.explorer_toggle(app)
    return
  elseif key == "ctrl_shift_f" then
    Keybindings.actions.finder_grep(app)
    return
  elseif key == "ctrl_w" then
    Keybindings.actions.buffer_delete(app)
    return
  elseif key == "ctrl_n" then
    Keybindings.actions.buffer_new(app)
    return
  elseif key == "ctrl_t" or key == "ctrl_backtick" then
    Keybindings.actions.terminal_toggle(app)
    return
  elseif key == "ctrl_tab" then
    Keybindings.actions.buffer_next(app)
    return
  elseif key == "ctrl_shift_tab" then
    Keybindings.actions.buffer_prev(app)
    return
  elseif key == "ctrl_z" then
    Keybindings.actions.edit_undo(app)
    return
  elseif key == "ctrl_y" or key == "ctrl_shift_z" then
    Keybindings.actions.edit_redo(app)
    return
  elseif key == "ctrl_h" then Keybindings.actions.window_focus_left(app); return
  elseif key == "ctrl_j" then Keybindings.actions.window_focus_down(app); return
  elseif key == "ctrl_k" then Keybindings.actions.window_focus_up(app); return
  elseif key == "ctrl_l" then Keybindings.actions.window_focus_right(app); return
  end

  -- Leader key (default: Space)
  local leader = (app.config and app.config.leader) or " "
  if key == leader and not app.vim:is_insert_family() then
    -- Don't trigger leader from INSERT mode
    if app.show_dashboard then app.show_dashboard = false end
    app.whichkey:open()
    app.status_msg = "Leader (Space) — press a key..."
    return
  end

  -- Buffer search via Ctrl+F (universal)
  if key == "ctrl_f" then
    app.vim:enter_search(true)
    return
  end

  -- Vim engine handles everything else
  -- Sync buffer reference
  app.vim:set_buffer(app.buffer)

  -- Get viewport rows for scrolling commands
  local Terminal = require("src.terminal")
  local rows, _ = Terminal.get_size()
  local viewport_rows = math.max(6, rows - 4)

  local result, payload = app.vim:handle(key, viewport_rows)

  -- Update app state based on vim engine mode
  app.vim_mode = app.vim:mode_label()

  -- Handle command completion
  if result == "command" and payload then
    Commands.execute(payload, app)
  end

  -- Auto-dismiss dashboard when entering insert/replace/visual
  if result == "insert" or result == "replace" or result == "visual" or result == "vline" or result == "vblock" then
    app.show_dashboard = false
  end

  -- Status update
  if result == "edited" then
    if app.config and app.config.format_on_save == false then
      -- skip
    end
  end
end

-- ─────────────────────────────────────────────────────────
-- Backward compatibility: old palette entries still work
-- ─────────────────────────────────────────────────────────
Keybindings.palette_entries = {
  { label = "Save File",                 action = "file_save" },
  { label = "Toggle Explorer",           action = "explorer_toggle" },
  { label = "Reveal Current in Explorer", action = "explorer_reveal" },
  { label = "Find Files (Telescope)",    action = "finder_files" },
  { label = "Live Grep (Telescope)",     action = "finder_grep" },
  { label = "Buffers (Telescope)",       action = "finder_buffers" },
  { label = "Recent Files (Telescope)",  action = "finder_recent" },
  { label = "Commands (Telescope)",      action = "finder_commands" },
  { label = "Cycle Themes",              action = "theme_cycle" },
  { label = "Cycle Styles",              action = "style_cycle" },
  { label = "Toggle Icons Mode",         action = "icons_toggle" },
  { label = "LSP Format Document",       action = "lsp_format" },
  { label = "LSP Diagnostics",           action = "diagnostics_panel" },
  { label = "LSP Hover Info",            action = "lsp_hover" },
  { label = "LSP Definition",            action = "lsp_definition" },
  { label = "LSP References",            action = "lsp_references" },
  { label = "LSP Code Action",           action = "lsp_code_action" },
  { label = "LSP Rename",                action = "lsp_rename" },
  { label = "Next Buffer",               action = "buffer_next" },
  { label = "Previous Buffer",           action = "buffer_prev" },
  { label = "Close Buffer",              action = "buffer_delete" },
  { label = "Close Other Buffers",       action = "buffer_close_others" },
  { label = "New Buffer",                action = "buffer_new" },
  { label = "Git Status",                action = "git_status" },
  { label = "Git Diff",                  action = "git_diff" },
  { label = "Git Commit",               action = "git_commit" },
  { label = "Git Push",                  action = "git_push" },
  { label = "Git Log",                   action = "git_log" },
  { label = "Toggle Terminal",           action = "terminal_toggle" },
  { label = "Window Split",              action = "window_split" },
  { label = "Window VSplit",             action = "window_vsplit" },
  { label = "Close Window",              action = "window_close" },
  { label = "Project Switcher",          action = "project_switch" },
  { label = "Project Dashboard",         action = "project_dashboard" },
  { label = "Quit RVM",                  action = "app_quit" },
  { label = "Force Quit",                action = "app_force_quit" },
}

return Keybindings
