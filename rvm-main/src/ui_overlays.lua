-- src/ui_overlays.lua
-- Modern overlay renderers for RVM (LazyVim-style):
--   - Bufferline
--   - Statusline (mode, file, language, LSP, Git, diagnostics, position)
--   - Which-Key popup
--   - Finder overlay (Telescope-like)
--   - Terminal panel
--   - Window splits
--
-- This module renders ANSI strings; it does NOT touch the terminal directly
-- except through the existing `Terminal` helpers. It is consumed by `ui.lua`.

local Terminal = require("src.terminal")
local Languages = require("src.config.languages")
local LSP        = require("src.lsp")
local Git        = require("src.git")
local Icons      = require("src.config.icons")

local UIOverlays = {}

-- ─────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────
local function fg(r, g, b) return Terminal.fg_rgb(r, g, b) end
local function bg(r, g, b) return Terminal.bg_rgb(r, g, b) end
local function reset()   return Terminal.reset_color() end
local function bold()     return Terminal.bold() end

local function fit(str, width)
  if not str then return string.rep(" ", width) end
  if #str <= width then return str .. string.rep(" ", width - #str) end
  return str:sub(1, math.max(0, width - 1)) .. "…"
end

-- ─────────────────────────────────────────────────────────
-- Bufferline (top tabs bar)
-- ─────────────────────────────────────────────────────────
function UIOverlays.bufferline(app, cols, theme)
  local parts = {}
  for i, b in ipairs(app.buffers) do
    local name = (b.file_path and b.file_path:match("([^/\\]+)$")) or "Untitled"
    local dirty = b.is_dirty and " ●" or ""
    local is_active = (i == app.buf_index) and not app.show_dashboard
    local icon_def = Icons.get({ name = name, is_dir = false })
    local glyph = icon_def and (icon_def.fallback_glyph or "📄") or "📄"
    local ic_color = icon_def and icon_def.fallback_color or theme.foreground

    if is_active then
      local mode_bg = theme.statusline
      local mode_fg = theme.background
      table.insert(parts, bg(mode_bg[1], mode_bg[2], mode_bg[3]) .. fg(mode_fg[1], mode_fg[2], mode_fg[3]) .. bold() .. " " .. glyph .. " " .. name .. dirty .. " " .. reset())
    else
      local accent = theme.comments
      table.insert(parts, fg(accent[1], accent[2], accent[3]) .. " " .. glyph .. " " .. name .. dirty .. " " .. reset())
    end
  end
  if #parts == 0 then
    return fg(theme.comments[1], theme.comments[2], theme.comments[3]) .. " [no buffers]" .. string.rep(" ", cols - 12) .. reset()
  end
  local line = table.concat(parts, fg(theme.borders[1], theme.borders[2], theme.borders[3]) .. "│" .. reset())
  return line .. string.rep(" ", math.max(0, cols - #line))
end

-- ─────────────────────────────────────────────────────────
-- Statusline
-- Format: NORMAL  main.dart  Dart  LSP ✓  Git:main  42:18
-- ─────────────────────────────────────────────────────────
function UIOverlays.statusline(app, cols, theme)
  local buf = app.buffer
  local file_name = (buf.file_path and buf.file_path:match("([^/\\]+)$")) or "Untitled"
  local file_lang = "Plain"
  local lang_info = Languages.detect(buf.file_path)
  if lang_info and lang_info.name then file_lang = lang_info.name end

  -- Git info
  local git_str = ""
  if app.project and app.project.git_branch then
    git_str = "  Git:" .. app.project.git_branch
  end

  -- LSP indicator
  local srv, _ = LSP.detect_server(buf)
  local lsp_str = "  LSP " .. (srv and "✓" or "○")

  -- Diagnostics summary
  local diags = LSP.diagnostics(buf)
  local diag_str = ""
  if #diags > 0 then
    local errors = 0
    local warns = 0
    for _, d in ipairs(diags) do
      if d.level == "ERROR" then errors = errors + 1
      elseif d.level == "WARN" then warns = warns + 1
      end
    end
    if errors > 0 then
      diag_str = "  ⨉ " .. errors
    elseif warns > 0 then
      diag_str = "  ⚠ " .. warns
    end
  end

  -- Position
  local pos_str = string.format("  %d:%d", buf.cursor_row, buf.cursor_col)

  -- Mode badge (color-coded)
  local mode = app.vim_mode or (app.easy_mode and "EASY" or "NORMAL")
  local mode_color
  if mode == "INSERT" or mode == "APPEND" then mode_color = theme.git_added or {78, 201, 176}
  elseif mode == "VISUAL" or mode == "V-LINE" or mode == "V-BLOCK" then mode_color = theme.info or {96, 165, 250}
  elseif mode == "COMMAND" or mode == "SEARCH" then mode_color = theme.warnings or {251, 191, 36}
  elseif mode == "REPLACE" then mode_color = theme.errors or {248, 113, 113}
  else mode_color = theme.functions or {56, 189, 248} end

  local mode_bg = bg(mode_color[1], mode_color[2], mode_color[3])
  local mode_fg = fg(theme.background[1], theme.background[2], theme.background[3])
  local mode_span = mode_bg .. mode_fg .. bold() .. " " .. mode .. " " .. reset()

  -- Compose
  local accent = theme.functions or theme.foreground
  local muted  = theme.comments or theme.foreground
  local info_span = fg(accent[1], accent[2], accent[3]) .. "  " .. file_name ..
                    fg(muted[1], muted[2], muted[3]) .. "  " .. file_lang ..
                    fg(muted[1], muted[2], muted[3]) .. lsp_str ..
                    fg(muted[1], muted[2], muted[3]) .. git_str ..
                    (diag_str ~= "" and (fg(theme.errors[1], theme.errors[2], theme.errors[3]) .. diag_str) or "") ..
                    fg(muted[1], muted[2], muted[3]) .. pos_str .. reset()

  local line = mode_span .. info_span
  -- Right-pad with statusline bg
  if #line < cols then
    line = line .. bg(theme.statusline[1], theme.statusline[2], theme.statusline[3]) .. string.rep(" ", cols - #line) .. reset()
  end
  return line
end

-- ─────────────────────────────────────────────────────────
-- Which-key popup (centered bottom overlay)
-- ─────────────────────────────────────────────────────────
function UIOverlays.whichkey(app, rows, cols, theme)
  if not app.whichkey or not app.whichkey:is_open() then return end
  local rows_data = app.whichkey:hint_rows()
  if #rows_data == 0 then return end

  local title = app.whichkey.prefix == "" and "Which-Key" or ("Which-Key — " .. app.whichkey.prefix)
  local max_label_len = 0
  for _, r in ipairs(rows_data) do
    if #r.label > max_label_len then max_label_len = #r.label end
  end

  -- Layout: 2 columns if wide enough, else single column
  local col_w = max_label_len + 12
  local n_cols = math.max(1, math.floor((cols - 4) / col_w))
  local n_rows = math.ceil(#rows_data / n_cols)

  local popup_h = n_rows + 2  -- border + title
  local popup_w = math.min(cols - 4, n_cols * col_w + 2)
  local popup_x = math.floor((cols - popup_w) / 2)
  local popup_y = rows - popup_h - 2

  -- Background fill
  local popup_bg = theme.popup or {30, 30, 30}
  local border_c = theme.borders or {80, 80, 80}
  local accent_c = theme.functions or {56, 189, 248}
  local key_c = theme.keywords or {99, 102, 241}

  -- Top border with title
  Terminal.move_cursor(popup_y, popup_x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "┌─ " .. fg(accent_c[1], accent_c[2], accent_c[3]) .. title .. fg(border_c[1], border_c[2], border_c[3]) .. string.rep("─", popup_w - #title - 4) .. "┐" .. reset())

  -- Rows
  for r = 1, n_rows do
    Terminal.move_cursor(popup_y + r, popup_x)
    local line = fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset()
    for c = 1, n_cols do
      local idx = (c - 1) * n_rows + r
      local row = rows_data[idx]
      if row then
        local key_str = string.format("%-2s", row.key or "?")
        local label_str = (row.label or ""):sub(1, max_label_len)
        local icon = row.icon or ""
        line = line .. " " .. fg(key_c[1], key_c[2], key_c[3]) .. bold() .. key_str .. reset() .. " " .. icon .. " " .. label_str .. string.rep(" ", col_w - #key_str - 5 - #label_str - #icon)
      else
        line = line .. string.rep(" ", col_w - 1)
      end
    end
    line = line .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset()
    io.write(line)
  end

  -- Bottom border
  Terminal.move_cursor(popup_y + n_rows + 1, popup_x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "└" .. string.rep("─", popup_w - 2) .. "┘" .. reset())
end

-- ─────────────────────────────────────────────────────────
-- Finder overlay (Telescope-like, centered)
-- ─────────────────────────────────────────────────────────
function UIOverlays.finder(app, rows, cols, theme)
  if not app.finder or not app.finder:is_open() then return end

  local prompt = app.finder.query or ""
  local results = app.finder.results or {}
  local sel = app.finder.selected or 1
  local mode = app.finder.mode or "files"

  local title_map = {
    files = "Find Files",
    grep = "Live Grep",
    buffers = "Buffers",
    recent = "Recent Files",
    commands = "Commands",
    help = "Help",
    keymaps = "Key Maps",
  }
  local title = title_map[mode] or "Finder"

  -- Layout: prompt at top, results list, preview on right if width > 100
  local popup_w = math.min(cols - 4, 100)
  local popup_h = math.min(rows - 4, 20)
  local popup_x = math.floor((cols - popup_w) / 2)
  local popup_y = math.floor((rows - popup_h) / 2)

  local border_c = theme.borders or {80, 80, 80}
  local accent_c = theme.functions or {56, 189, 248}
  local muted_c = theme.comments or {120, 120, 120}
  local sel_c   = theme.selection or {40, 40, 40}
  local popup_bg = theme.popup or {30, 30, 30}

  -- Title
  Terminal.move_cursor(popup_y, popup_x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "┌─ " .. fg(accent_c[1], accent_c[2], accent_c[3]) .. title .. fg(border_c[1], border_c[2], border_c[3]) .. string.rep("─", popup_w - #title - 4) .. "┐" .. reset())

  -- Prompt line
  Terminal.move_cursor(popup_y + 1, popup_x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset() .. fg(accent_c[1], accent_c[2], accent_c[3]) .. " " .. (mode == "grep" and "Grep> " or "> ") .. prompt .. string.rep(" ", popup_w - #prompt - 6) .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset())

  -- Result lines
  local result_rows = math.min(popup_h - 4, #results)
  for i = 1, result_rows do
    local idx = i + (app.finder.scroll or 1) - 1
    local entry = results[idx]
    if not entry then break end
    Terminal.move_cursor(popup_y + 1 + i, popup_x)
    local prefix = (idx == sel) and bg(sel_c[1], sel_c[2], sel_c[3]) .. " " or " "
    local display = entry.display or ""
    if #display > popup_w - 6 then display = display:sub(1, popup_w - 7) .. "…" end
    local line = fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset() .. prefix .. display
    if idx == sel then
      line = line .. string.rep(" ", popup_w - #display - 4) .. reset() .. bg(sel_c[1], sel_c[2], sel_c[3]) .. " " .. reset()
    else
      line = line .. string.rep(" ", popup_w - #display - 4)
    end
    line = line .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset()
    io.write(line)
  end
  -- Fill empty rows
  for i = result_rows + 1, popup_h - 3 do
    Terminal.move_cursor(popup_y + 1 + i, popup_x)
    io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. string.rep(" ", popup_w - 2) .. "│" .. reset())
  end

  -- Status line at bottom of popup
  Terminal.move_cursor(popup_y + popup_h - 1, popup_x)
  local stat = string.format(" %d/%d results ", sel, #results)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. fg(muted_c[1], muted_c[2], muted_c[3]) .. stat .. string.rep(" ", popup_w - #stat - 2) .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset())

  -- Bottom border
  Terminal.move_cursor(popup_y + popup_h, popup_x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "└" .. string.rep("─", popup_w - 2) .. "┘" .. reset())
end

-- ─────────────────────────────────────────────────────────
-- Terminal panel (bottom or right)
-- ─────────────────────────────────────────────────────────
function UIOverlays.terminal_panel(app, area_rect, theme)
  if not app.terminal or not app.terminal:is_open() then return end

  local x, y, w, h = area_rect.x, area_rect.y, area_rect.w, area_rect.h
  if w < 6 or h < 3 then return end

  local border_c = theme.borders or {80, 80, 80}
  local accent_c = theme.functions or {56, 189, 248}
  local muted_c  = theme.comments or {120, 120, 120}

  -- Top border with title
  Terminal.move_cursor(y, x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "┌─ " .. fg(accent_c[1], accent_c[2], accent_c[3]) .. "Terminal" .. fg(border_c[1], border_c[2], border_c[3]) .. string.rep("─", math.max(0, w - 11)) .. "┐" .. reset())

  -- Visible lines
  local lines = app.terminal:visible_lines(h - 2)
  for i, l in ipairs(lines) do
    if i > h - 2 then break end
    Terminal.move_cursor(y + i, x)
    local content = l:sub(1, w - 4)
    io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset() .. " " .. content .. string.rep(" ", math.max(0, w - #content - 3)) .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset())
  end
  -- Fill remaining rows
  for i = #lines + 1, h - 2 do
    Terminal.move_cursor(y + i, x)
    io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. string.rep(" ", w - 2) .. "│" .. reset())
  end

  -- Input line
  Terminal.move_cursor(y + h - 1, x)
  local input = app.terminal:input_line()
  if #input > w - 4 then input = input:sub(1, w - 5) .. "…" end
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset() .. fg(accent_c[1], accent_c[2], accent_c[3]) .. " " .. input .. string.rep(" ", math.max(0, w - #input - 3)) .. fg(border_c[1], border_c[2], border_c[3]) .. "│" .. reset())

  -- Bottom border
  Terminal.move_cursor(y + h, x)
  io.write(fg(border_c[1], border_c[2], border_c[3]) .. "└" .. string.rep("─", w - 2) .. "┘" .. reset())
end

-- ─────────────────────────────────────────────────────────
-- Project dashboard (modern LazyVim-style)
-- ─────────────────────────────────────────────────────────
function UIOverlays.dashboard(app, rows, cols, theme)
  local proj = app.project or { name = "Workspace", icon = "📁", root = "." }
  local accent_c = theme.functions or {56, 189, 248}
  local muted_c  = theme.comments or {120, 120, 120}
  local text_c   = theme.foreground or {220, 220, 220}

  local left_col_w = math.min(50, math.floor(cols / 2))
  local cx = math.floor(cols / 4)
  local cy = math.floor(rows / 4)

  -- Logo
  local logo = {
    "█████╗  ██╗   ██╗ ███╗   ███╗",
    "╚══██╗ ██║   ██║ ████╗ ████║",
    "█████╔╝ ██║   ██║ ██╔████╔██║",
    "╚══██╗ ██║   ██║ ██║╚██╔╝██║",
    "█████╔╝ ╚██████╔╝ ██║ ╚═╝ ██║",
    "╚═══╝   ╚═════╝  ╚═╝     ╚═╝",
  }

  for i, line in ipairs(logo) do
    Terminal.move_cursor(cy + i - 1, cx)
    io.write(fg(accent_c[1], accent_c[2], accent_c[3]) .. bold() .. line .. reset())
  end

  -- Project info block
  local info_y = cy + #logo + 2
  Terminal.move_cursor(info_y, cx)
  io.write(fg(muted_c[1], muted_c[2], muted_c[3]) .. "Project: " .. reset() .. fg(text_c[1], text_c[2], text_c[3]) .. bold() .. (proj.icon or "📁") .. " " .. (proj.name or "Workspace") .. reset())

  Terminal.move_cursor(info_y + 1, cx)
  io.write(fg(muted_c[1], muted_c[2], muted_c[3]) .. "Root:   " .. reset() .. (proj.root or "."))

  Terminal.move_cursor(info_y + 2, cx)
  local branch = proj.git_branch and ("  Git: " .. proj.git_branch) or "  No git"
  io.write(fg(muted_c[1], muted_c[2], muted_c[3]) .. "VCS:   " .. reset() .. branch)

  -- Quick actions
  local actions_y = info_y + 5
  local actions = {
    { key = "<leader>ff", desc = "Find Files" },
    { key = "<leader>fg", desc = "Live Grep" },
    { key = "<leader>fb", desc = "Buffers" },
    { key = "<leader>fr", desc = "Recent Files" },
    { key = "<leader>e",  desc = "Toggle Explorer" },
    { key = "<leader>pp", desc = "Project Switcher" },
    { key = "<leader>gg", desc = "Git Status" },
    { key = "<leader>tt", desc = "Toggle Terminal" },
    { key = ":w",          desc = "Save File" },
    { key = ":q",          desc = "Quit" },
  }
  for i, a in ipairs(actions) do
    Terminal.move_cursor(actions_y + i - 1, cx)
    io.write(fg(accent_c[1], accent_c[2], accent_c[3]) .. string.format("%-15s", a.key) .. reset() .. fg(muted_c[1], muted_c[2], muted_c[3]) .. "  " .. a.desc .. reset())
  end
end

return UIOverlays
