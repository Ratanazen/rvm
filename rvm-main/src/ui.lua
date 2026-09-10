local Terminal         = require("src.terminal")
local Syntax           = require("src.syntax")
local Cursor           = require("src.cursor")
local Languages        = require("src.config.languages")
local LSP              = require("src.lsp")
local Icons            = require("src.config.icons")
local TerminalGraphics = require("src.terminal_graphics")

local UI = {}

-- Safely fit a string with ANSI escape codes and UTF-8 characters to target terminal column width
local function fit_to_width(str, target_width)
    if not str or target_width <= 0 then return string.rep(" ", math.max(0, target_width or 0)) end
    local cur_w = 0
    local result = {}
    local p = 1
    local len = #str

    while p <= len do
        local esc_s, esc_e = str:find("^\27%[[%d;]*[a-zA-Z]", p)
        if esc_s then
            table.insert(result, str:sub(esc_s, esc_e))
            p = esc_e + 1
        else
            local b1 = string.byte(str, p)
            local char_len = 1
            local ch_w = 1

            if b1 >= 240 then
                char_len = 4
                ch_w = 2
            elseif b1 >= 224 then
                char_len = 3
                local b2 = string.byte(str, p + 1) or 0
                if b2 == 154 or b2 == 155 or b2 == 156 then
                    ch_w = 2
                else
                    ch_w = 1
                end
            elseif b1 >= 192 then
                char_len = 2
                ch_w = 1
            else
                char_len = 1
                ch_w = 1
            end

            if cur_w + ch_w > target_width then
                break
            end

            table.insert(result, str:sub(p, p + char_len - 1))
            cur_w = cur_w + ch_w
            p = p + char_len
        end
    end

    local pad = target_width - cur_w
    if pad > 0 then
        table.insert(result, string.rep(" ", pad))
    end

    table.insert(result, "\27[0m")
    return table.concat(result)
end

-- VS Code style file & folder icons (Image-based with automatic fallback to glyphs)
local function get_file_icon(entry, theme)
    local icon_def = Icons.get(entry)

    if TerminalGraphics.is_image_enabled() and icon_def and icon_def.image then
        return "   ", icon_def.image
    end

    if entry.is_dir then
        local arrow = entry.is_expanded and "v " or "> "
        return Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3]) .. arrow, nil
    end

    if not icon_def then
        return Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3]) .. " ", nil
    end

    local c = icon_def.fallback_color or theme.foreground
    local g = icon_def.fallback_glyph or ""
    local badge = string.format("%-2s ", g)
    return Terminal.fg_rgb(c[1], c[2], c[3]) .. badge .. Terminal.reset_color(), nil
end

function UI.render(app)
    local rows, cols = Terminal.get_size()
    rows = math.max(6, rows)
    cols = math.max(20, cols)

    local theme = app.theme
    local style = app.style or {
        sidebar = true, statusline = true, tabline = true,
        borders = true, border_style = "single", line_numbers = true,
        header = true, explorer_width = 28
    }

    local reset  = Terminal.reset_color()

    -- Per spec requirement #13: if the theme has `terminal_native = true`,
    -- we do NOT paint an explicit background/foreground. The terminal emulator
    -- controls those colors. We still use syntax colors for highlighting.
    local native = theme.terminal_native == true
    local e_bg   = native and "" or Terminal.bg_rgb(theme.background[1], theme.background[2], theme.background[3])
    local e_fg   = native and "" or Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local h_bg   = native and "" or Terminal.bg_rgb(theme.tabs[1], theme.tabs[2], theme.tabs[3])
    local h_fg   = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])
    local s_bg   = native and "" or Terminal.bg_rgb(theme.statusline[1], theme.statusline[2], theme.statusline[3])
    local s_fg   = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local sb_bg  = native and "" or Terminal.bg_rgb(theme.sidebar[1], theme.sidebar[2], theme.sidebar[3])
    local mut_fg = Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3])
    local b_fg   = Terminal.fg_rgb(theme.borders[1], theme.borders[2], theme.borders[3])
    local sel_bg = Terminal.bg_rgb(theme.selection[1], theme.selection[2], theme.selection[3])
    local act_fg = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])

    local border_char = "│"
    if style.border_style == "double" then border_char = "║" end

    -- ────────────────────────────────────────────────────────
    -- 1. Top Header & Tabs Bar (VS Code style menu bar + tabs)
    -- ────────────────────────────────────────────────────────
    local header_rows = style.header and 1 or 0
    if style.header then
        Terminal.move_cursor(1, 1)

        local tab_parts = {}
        if app.show_dashboard then
            table.insert(tab_parts, string.format("%s%s  Welcome ✕ %s%s", s_bg, s_fg, h_bg, h_fg))
        end
        for i, b in ipairs(app.buffers) do
            local name = b.file_path and b.file_path:match("([^/\\]+)$") or (app.show_dashboard and "" or "Untitled")
            if name ~= "" then
                local dirty = b.is_dirty and " ●" or ""
                local is_active = (not app.show_dashboard and i == app.buf_index)
                local icon = get_file_icon({ name = name, is_dir = false }, theme)
                if is_active then
                    table.insert(tab_parts, string.format("%s%s %s%s%s ✕ %s%s", s_bg, s_fg, icon, name, dirty, h_bg, h_fg))
                else
                    table.insert(tab_parts, string.format(" %s%s%s ", icon, name, dirty))
                end
            end
        end
        local tabs_str = table.concat(tab_parts, "│")

        local proj_name = app.project and app.project.name or "my-web-app"
        local menu_str = cols >= 80 and "File  Edit  Selection  View  Go  Run  Terminal  Help │ " or ""
        local header_line = string.format(" %s%s │ %s", menu_str, proj_name, tabs_str)
        local fitted_header = fit_to_width(header_line, cols - 1)
        io.write(h_bg .. h_fg .. fitted_header .. "\27[K" .. reset)
    end

    -- ────────────────────────────────────────────────────────
    -- 2. Layout Dimensions (Activity Bar + Explorer Sidebar)
    -- ────────────────────────────────────────────────────────
    local status_rows = style.statusline and 2 or 1
    local body_rows = math.max(1, rows - header_rows - status_rows)

    local actbar_width = (style.sidebar and app.filesystem and app.filesystem.is_visible and cols >= 70) and 4 or 0
    local raw_explorer_w = 0
    if style.sidebar and app.filesystem and app.filesystem.is_visible and cols >= 50 then
        raw_explorer_w = math.min(style.explorer_width or 26, math.floor(cols * 0.35))
    end
    local sidebar_width = actbar_width + raw_explorer_w

    local editor_cols = math.max(10, cols - sidebar_width)
    local gutter_width = style.line_numbers and (#tostring(#app.buffer.lines) + 4) or 0
    local content_cols = math.max(1, editor_cols - gutter_width)

    Cursor.clamp(app.buffer, math.max(1, body_rows - 2), content_cols - 2)

    -- ────────────────────────────────────────────────────────
    -- 3A. VS Code Activity Bar (Far-Left Icon Strip)
    -- ────────────────────────────────────────────────────────
    if actbar_width > 0 then
        local act_icons = { " ", " ", " ", " ▷ ", " ⊞ " }
        local act_bg = Terminal.bg_rgb(math.max(0, theme.background[1] - 8), math.max(0, theme.background[2] - 8), math.max(0, theme.background[3] - 8))
        for r = 1, body_rows do
            Terminal.move_cursor(r + header_rows, 1)
            local icon_str = "   "
            if r <= #act_icons then
                if r == 1 then
                    icon_str = act_fg .. Terminal.bold() .. act_icons[r] .. reset .. act_bg
                else
                    icon_str = mut_fg .. act_icons[r] .. reset .. act_bg
                end
            elseif r == body_rows - 1 then
                icon_str = mut_fg .. " " .. reset .. act_bg
            elseif r == body_rows then
                icon_str = mut_fg .. "  " .. reset .. act_bg
            end
            io.write(act_bg .. icon_str .. b_fg .. "│" .. reset)
        end
    end

    -- ────────────────────────────────────────────────────────
    -- 3B. VS Code Explorer Sidebar (Tree + Git status + Outline)
    -- ────────────────────────────────────────────────────────
    if raw_explorer_w > 0 then
        local exp_start_col = actbar_width + 1

        -- Explorer Header
        Terminal.move_cursor(1 + header_rows, exp_start_col)
        local proj_title = app.project and app.project.name:upper() or "MY-WEB-APP"
        local expl_hdr = string.format(" v %s", proj_title)
        expl_hdr = fit_to_width(expl_hdr, raw_explorer_w - 1)
        io.write(sb_bg .. mut_fg .. Terminal.bold() .. expl_hdr .. b_fg .. border_char .. reset)

        -- Explorer Tree Items with Git Status (M, U, A, D)
        local total_entries = #app.filesystem.entries
        for r = 2, body_rows do
            local entry_idx = r - 1
            local screen_row = r + header_rows
            Terminal.move_cursor(screen_row, exp_start_col)

            local line_text = ""
            local image_to_draw = nil
            if entry_idx <= total_entries then
                local entry = app.filesystem.entries[entry_idx]
                if entry then
                    local indent = string.rep("  ", entry.depth or 0)
                    local icon_col = exp_start_col + 1 + (entry.depth or 0) * 2
                    local icon, img_path = get_file_icon(entry, theme)
                    if img_path and icon_col + 2 <= exp_start_col + raw_explorer_w - 1 then
                        image_to_draw = { path = img_path, row = screen_row, col = icon_col }
                    end
                    local base_label = " " .. indent .. icon .. entry.name

                    -- Git status badge (e.g. M, U)
                    local git_badge = ""
                    if entry.git_status then
                        if entry.git_status == "M" then
                            git_badge = Terminal.fg_rgb(theme.git_modified[1], theme.git_modified[2], theme.git_modified[3]) .. " M "
                        elseif entry.git_status == "U" or entry.git_status == "A" then
                            git_badge = Terminal.fg_rgb(theme.git_added[1], theme.git_added[2], theme.git_added[3]) .. " " .. entry.git_status .. " "
                        elseif entry.git_status == "D" then
                            git_badge = Terminal.fg_rgb(theme.git_deleted[1], theme.git_deleted[2], theme.git_deleted[3]) .. " D "
                        end
                    end

                    if entry_idx == app.filesystem.selected_index then
                        line_text = sel_bg .. Terminal.bold() .. fit_to_width(base_label .. git_badge, raw_explorer_w - 1)
                    else
                        local fg = entry.is_dir and h_fg or e_fg
                        line_text = fg .. fit_to_width(base_label .. git_badge, raw_explorer_w - 1)
                    end
                end
            elseif r == body_rows - 1 and body_rows >= 14 then
                line_text = mut_fg .. fit_to_width(" > OUTLINE", raw_explorer_w - 1)
            elseif r == body_rows and body_rows >= 14 then
                line_text = mut_fg .. fit_to_width(" > TIMELINE", raw_explorer_w - 1)
            else
                line_text = fit_to_width("", raw_explorer_w - 1)
            end
            io.write(sb_bg .. line_text .. b_fg .. border_char .. reset)
            if image_to_draw then
                TerminalGraphics.draw_image(image_to_draw.path, image_to_draw.row, image_to_draw.col, 2, 1)
            end
        end
    end

    -- ────────────────────────────────────────────────────────
    -- 4. Main Canvas (Dashboard vs Editor)
    -- ────────────────────────────────────────────────────────
    local start_col = sidebar_width + 1

    if app.show_dashboard and (#app.buffer.lines <= 1 and app.buffer.lines[1] == "") then
        UI.render_dashboard(body_rows, editor_cols, start_col, theme, header_rows, app)
    else
        UI.render_editor(app, body_rows, editor_cols, start_col, theme, header_rows, gutter_width, content_cols, style)
    end

    -- ────────────────────────────────────────────────────────
    -- 5. VS Code Style Statusline (Git branch, Line/Col, Spaces, Encoding, Language)
    -- ────────────────────────────────────────────────────────
    if style.statusline then
        Terminal.move_cursor(rows - 1, 1)

        local mode_badge = app.easy_mode
            and (Terminal.bg_rgb(theme.functions[1], theme.functions[2], theme.functions[3]) .. Terminal.fg_rgb(theme.background[1], theme.background[2], theme.background[3]) .. Terminal.bold() .. " RVM ")
            or  (Terminal.bg_rgb(theme.keywords[1], theme.keywords[2], theme.keywords[3]) .. Terminal.fg_rgb(theme.background[1], theme.background[2], theme.background[3]) .. Terminal.bold() .. " " .. app.vim_mode .. " ")

        local cur_file = app.buffer.file_path and app.buffer.file_path:match("([^/\\]+)$") or "Welcome"
        local lang = Languages.detect(app.buffer.file_path)

        local git_branch_str = ""
        if app.project and app.project.git_branch then
            git_branch_str = "  " .. app.project.git_branch .. "*  "
        else
            git_branch_str = "  main*  "
        end

        local status_str = string.format(
            "%s%s%s ⓧ 0   0 │ %s %s │ Ln %d, Col %d │ Spaces: 4 │ UTF-8 │ LF │ { } %s │ ",
            mode_badge,
            s_bg .. s_fg,
            git_branch_str,
            lang.icon,
            cur_file,
            app.buffer.cursor_row,
            app.buffer.cursor_col,
            lang.name
        )

        local fitted_status = fit_to_width(status_str, cols - 1)
        io.write(s_bg .. s_fg .. fitted_status .. "\27[K" .. reset)
    end

    -- ────────────────────────────────────────────────────────
    -- 6. Legend / Notification Bar
    -- ────────────────────────────────────────────────────────
    Terminal.move_cursor(rows, 1)
    local legend_str = app.status_msg or ""
    if legend_str == "" then
        legend_str = " [Tab] Open/Expand  [Space] Leader  [Ctrl+S] Save  [Ctrl+P] Palette  [Ctrl+B] Explorer  [Ctrl+Q] Quit"
    end
    local fitted_legend = fit_to_width(" " .. legend_str, cols - 1)
    io.write(h_bg .. Terminal.fg_rgb(250, 204, 21) .. Terminal.bold() .. fitted_legend .. "\27[K" .. reset)

    -- ────────────────────────────────────────────────────────
    -- 7. Overlays: Command Palette (Ctrl+P)
    -- ────────────────────────────────────────────────────────
    if app.show_palette then
        UI.render_palette_popup(app, rows, cols, theme)
    end

    -- ────────────────────────────────────────────────────────
    -- 8. Overlays: Which-Key (<Space>)
    -- ────────────────────────────────────────────────────────
    if app.show_whichkey then
        UI.render_whichkey_popup(app, rows, cols, theme)
    end

    -- ────────────────────────────────────────────────────────
    -- 9. Overlays: Floating Hover Tooltip (<Space> h)
    -- ────────────────────────────────────────────────────────
    if app.show_hover and app.hover_data then
        UI.render_hover_popup(app, rows, cols, theme)
    end

    -- ────────────────────────────────────────────────────────
    -- 10. Modern overlays (per spec requirements #7, #12, #15, #16)
    -- ────────────────────────────────────────────────────────
    local UIOverlays = require("src.ui_overlays")
    if app.whichkey and app.whichkey:is_open() then
        UIOverlays.whichkey(app, rows, cols, theme)
    end
    if app.finder and app.finder:is_open() then
        UIOverlays.finder(app, rows, cols, theme)
    end
    if app.terminal and app.terminal:is_open() and not app.terminal_focus then
        -- Render in background even when not focused
        -- (for split layout — skipped when focus is on it; keybindings handle it)
    end
    if app.terminal and app.terminal:is_open() then
        -- Bottom panel
        local h = math.min(app.terminal.height, math.floor(rows / 3))
        UIOverlays.terminal_panel(app, { x = 1, y = rows - h - 1, w = cols, h = h }, theme)
    end

    -- ────────────────────────────────────────────────────────
    -- 11. Command-line / Search status (vim_engine state)
    -- ────────────────────────────────────────────────────────
    if app.vim and app.vim:status_message() then
        local msg = app.vim:status_message()
        Terminal.move_cursor(rows, 1)
        io.write("\27[K" .. Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3]) .. msg .. reset)
    end

    io.flush()
end

function UI.render_editor(app, body_rows, editor_cols, start_col, theme, header_rows, gutter_width, content_cols, style)
    local e_bg   = Terminal.bg_rgb(theme.background[1], theme.background[2], theme.background[3])
    local e_fg   = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local mut_fg = Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3])
    local cur_ln = Terminal.bg_rgb(theme.current_line[1], theme.current_line[2], theme.current_line[3])
    local cur_bg = Terminal.bg_rgb(theme.cursor[1], theme.cursor[2], theme.cursor[3])
    local cur_fg = Terminal.fg_rgb(theme.background[1], theme.background[2], theme.background[3])
    local ln_fg  = Terminal.fg_rgb(theme.line_numbers[1], theme.line_numbers[2], theme.line_numbers[3])
    local act_fg = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])

    -- 1. VS Code-Style Breadcrumbs (e.g. Site 1 > web-pages > Home > <> index.html)
    Terminal.move_cursor(1 + header_rows, start_col)
    local breadcrumb = ""
    local bc_img_to_draw = nil
    if app.buffer.file_path then
        local parts = {}
        for seg in app.buffer.file_path:gmatch("[^/\\]+") do
            table.insert(parts, seg)
        end
        if #parts > 0 then
            local fname = parts[#parts]
            parts[#parts] = nil
            local icon, img_path = get_file_icon({ name = fname, is_dir = false }, theme)
            local prefix = #parts > 0 and (table.concat(parts, " > ") .. " > ") or ""
            breadcrumb = " " .. prefix .. icon .. fname
            if img_path then
                local icon_col = start_col + 1 + #prefix
                if icon_col + 2 <= start_col + editor_cols - 1 then
                    bc_img_to_draw = { path = img_path, row = 1 + header_rows, col = icon_col }
                end
            end
        end
    else
        breadcrumb = " Untitled"
    end
    local fitted_bc = fit_to_width(breadcrumb, editor_cols - 1)
    io.write(e_bg .. mut_fg .. fitted_bc .. "\27[K" .. Terminal.reset_color())
    if bc_img_to_draw then
        TerminalGraphics.draw_image(bc_img_to_draw.path, bc_img_to_draw.row, bc_img_to_draw.col, 2, 1)
    end

    -- 2. Editor Code Lines (starting at row 2)
    local code_rows = math.max(1, body_rows - 1)
    for r = 1, code_rows do
        Terminal.move_cursor(r + 1 + header_rows, start_col)
        local line_idx = app.buffer.row_offset + r
        local line_str = app.buffer.lines[line_idx]

        if line_str then
            local is_cursor_row = (line_idx == app.buffer.cursor_row)
            local row_bg = is_cursor_row and cur_ln or e_bg

            local gutter = ""
            if style.line_numbers then
                local g_color = is_cursor_row and (act_fg .. Terminal.bold()) or ln_fg
                local fmt = string.format("%%%dd │ ", gutter_width - 3)
                gutter = row_bg .. g_color .. string.format(fmt, line_idx) .. Terminal.reset_color()
            end

            local highlighted = Syntax.highlight_line(line_str, app.buffer.file_path, theme)

            if is_cursor_row then
                local col = app.buffer.cursor_col
                local before = line_str:sub(1, col - 1)
                local cur_char = line_str:sub(col, col)
                if cur_char == "" then cur_char = " " end
                local after = line_str:sub(col + 1)

                local hl_before = before ~= "" and Syntax.highlight_line(before, app.buffer.file_path, theme) or ""
                local hl_after  = after ~= "" and Syntax.highlight_line(after, app.buffer.file_path, theme) or ""
                local cur_block = cur_bg .. cur_fg .. cur_char .. Terminal.reset_color() .. row_bg

                local rendered = hl_before .. cur_block .. hl_after
                rendered = fit_to_width(rendered, content_cols)
                io.write(row_bg .. gutter .. rendered .. "\27[K" .. Terminal.reset_color())
            else
                highlighted = fit_to_width(highlighted, content_cols)
                io.write(row_bg .. gutter .. highlighted .. "\27[K" .. Terminal.reset_color())
            end
        else
            local gutter = ""
            if style.line_numbers then
                gutter = mut_fg .. "~" .. string.rep(" ", gutter_width - 1) .. Terminal.reset_color()
            end
            local filler = fit_to_width("", content_cols)
            io.write(e_bg .. gutter .. filler .. "\27[K" .. Terminal.reset_color())
        end
    end
end

function UI.render_dashboard(body_rows, editor_cols, start_col, theme, header_rows, app)
    local e_bg   = Terminal.bg_rgb(theme.background[1], theme.background[2], theme.background[3])
    local e_fg   = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local accent = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])
    local blue   = Terminal.fg_rgb(56, 189, 248)
    local orange = Terminal.fg_rgb(theme.keywords[1], theme.keywords[2], theme.keywords[3])
    local green  = Terminal.fg_rgb(theme.git_added[1], theme.git_added[2], theme.git_added[3])
    local mut_fg = Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3])
    local b_fg   = Terminal.fg_rgb(theme.borders[1], theme.borders[2], theme.borders[3])
    local s_bg   = Terminal.bg_rgb(theme.statusline[1], theme.statusline[2], theme.statusline[3])
    local s_fg   = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local card_bg= Terminal.bg_rgb(theme.popup[1], theme.popup[2], theme.popup[3])
    local reset  = Terminal.reset_color()

    local proj_name = app.project and app.project.name or "my-web-app"

    local left_w = math.min(36, math.floor(editor_cols * 0.42))
    local right_w = math.max(10, editor_cols - left_w - 4)
    local card_w = math.min(46, right_w - 2)

    local left_lines = {
        { type = "hdr", text = "Start" },
        { type = "item", icon = "", img = "icons/default_file.png", label = "New File...", key = "Ctrl+N" },
        { type = "item", icon = "", img = "icons/folder_closed.png", label = "Open File...", key = "Ctrl+O" },
        { type = "item", icon = "", img = "icons/explorer.png", label = "Open Folder...", key = "rvm <path>" },
        { type = "item", icon = "", img = "icons/save.png", label = "Clone Git Repo...", key = "git clone" },
        { type = "blank" },
        { type = "hdr", text = "Recent" },
        { type = "rec", icon = "", img = "icons/theme.png", name = proj_name, path = "~/Projects/" .. proj_name },
        { type = "rec", icon = "", img = "icons/folder_closed.png", name = "backend-api", path = "~/Documents/API" },
        { type = "rec", icon = "", img = "icons/py.png", name = "python-script", path = "~/Desktop" },
        { type = "more", text = "more..." },
    }

    local right_cards = {
        { title = " Get Started with RVM", desc = "Get started tutorials to Get Started with RVM." },
        { title = " Learn the Basics", desc = "Learn how to start and master keybindings." },
        { title = " Setup for Python / Web", desc = "LSP, syntax highlighting, and auto diagnostics." },
    }

    local right_lines = {
        { type = "hdr", text = "Walkthroughs" },
    }
    for _, c in ipairs(right_cards) do
        table.insert(right_lines, { type = "card_top", title = c.title })
        table.insert(right_lines, { type = "card_mid", desc = c.desc })
        table.insert(right_lines, { type = "card_bot" })
    end
    table.insert(right_lines, { type = "blank" })
    table.insert(right_lines, { type = "hdr", text = "Customize" })
    table.insert(right_lines, { type = "item", icon = "", img = "icons/theme.png", label = "Color Theme", key = "Space+t" })
    table.insert(right_lines, { type = "item", icon = "", img = "icons/explorer.png", label = "Editor Style", key = "Space+s" })
    table.insert(right_lines, { type = "item", icon = " ", img = "icons/default_file.png", label = "Shortcuts", key = "Space" })
    table.insert(right_lines, { type = "blank" })
    table.insert(right_lines, { type = "hdr", text = "Help" })
    table.insert(right_lines, { type = "help", text = "Documentation │ Release Notes │ Community" })

    for r = 1, body_rows do
        Terminal.move_cursor(r + header_rows, start_col)
        local line_str = ""
        local l_img_to_draw = nil
        local r_img_to_draw = nil
        local cur_row = r + header_rows

        if r == 1 then
            line_str = " " .. accent .. Terminal.bold() .. " Welcome" .. reset .. e_bg .. mut_fg .. " - " .. proj_name
        elseif r == body_rows and body_rows >= 8 then
            -- Integrated Terminal Panel Tab Bar at bottom
            line_str = string.format(
                " %sPROBLEMS 0%s    %sOUTPUT%s    %sDEBUG CONSOLE%s    %s%s TERMINAL %s%s    │  +  v  ✕",
                mut_fg, reset .. e_bg,
                mut_fg, reset .. e_bg,
                mut_fg, reset .. e_bg,
                s_bg, s_fg .. Terminal.bold(), reset .. e_bg, mut_fg
            )
        else
            local l_idx = r - 1
            local l_data = left_lines[l_idx]
            local r_data = right_lines[l_idx]

            local l_text = ""
            if l_data then
                local l_icon = l_data.icon or ""
                if TerminalGraphics.is_image_enabled() and l_data.img then
                    l_icon = "  "
                    l_img_to_draw = { path = l_data.img, row = cur_row, col = start_col + 3 }
                end
                if l_data.type == "hdr" then
                    l_text = " " .. Terminal.bold() .. blue .. l_data.text .. reset .. e_bg
                elseif l_data.type == "item" then
                    l_text = string.format("   %s %s%-18s%s %s", l_icon, accent, l_data.label, reset .. e_bg, mut_fg .. l_data.key)
                elseif l_data.type == "rec" then
                    l_text = string.format("   %s %s%-13s%s %s", l_icon, orange, l_data.name, reset .. e_bg, mut_fg .. l_data.path)
                elseif l_data.type == "more" then
                    l_text = "   " .. blue .. l_data.text
                end
            end

            local r_text = ""
            if r_data and editor_cols >= 65 then
                local r_icon = r_data.icon or ""
                if TerminalGraphics.is_image_enabled() and r_data.img then
                    r_icon = "  "
                    r_img_to_draw = { path = r_data.img, row = cur_row, col = start_col + left_w + 2 + 3 }
                end
                if r_data.type == "hdr" then
                    r_text = " " .. Terminal.bold() .. blue .. r_data.text .. reset .. e_bg
                elseif r_data.type == "card_top" then
                    local bar = string.rep("─", math.max(0, card_w - 6 - #r_data.title))
                    r_text = card_bg .. b_fg .. "╭── " .. blue .. Terminal.bold() .. r_data.title .. reset .. card_bg .. b_fg .. " " .. bar .. "╮"
                elseif r_data.type == "card_mid" then
                    local d = r_data.desc:sub(1, card_w - 6)
                    local pad = string.rep(" ", math.max(0, card_w - 6 - #d))
                    r_text = card_bg .. b_fg .. "│   " .. mut_fg .. d .. pad .. b_fg .. "│"
                elseif r_data.type == "card_bot" then
                    r_text = card_bg .. b_fg .. "╰" .. string.rep("─", card_w - 2) .. "╯"
                elseif r_data.type == "item" then
                    r_text = string.format("   %s %s%-16s%s %s", r_icon, accent, r_data.label, reset .. e_bg, orange .. r_data.key)
                elseif r_data.type == "help" then
                    r_text = "   " .. blue .. r_data.text
                end
            end

            if editor_cols >= 65 then
                l_text = fit_to_width(l_text, left_w)
                line_str = l_text .. "  " .. r_text
            else
                line_str = l_text ~= "" and l_text or r_text
            end
        end

        local rendered = fit_to_width(line_str, editor_cols - 1)
        io.write(e_bg .. rendered .. "\27[K" .. Terminal.reset_color())
        if l_img_to_draw then
            TerminalGraphics.draw_image(l_img_to_draw.path, l_img_to_draw.row, l_img_to_draw.col, 2, 1)
        end
        if r_img_to_draw then
            TerminalGraphics.draw_image(r_img_to_draw.path, r_img_to_draw.row, r_img_to_draw.col, 2, 1)
        end
    end
end

function UI.render_palette_popup(app, rows, cols, theme)
    local p_width = math.min(60, cols - 4)
    local p_height = math.min(15, rows - 4)
    local start_row = math.floor((rows - p_height) / 2)
    local start_col = math.floor((cols - p_width) / 2)

    local pop_bg = Terminal.bg_rgb(theme.popup[1], theme.popup[2], theme.popup[3])
    local pop_fg = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local b_fg   = Terminal.fg_rgb(theme.borders[1], theme.borders[2], theme.borders[3])
    local act_fg = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])
    local sel_bg = Terminal.bg_rgb(theme.selection[1], theme.selection[2], theme.selection[3])

    Terminal.move_cursor(start_row, start_col)
    io.write(pop_bg .. b_fg .. "┌" .. string.rep("─", p_width - 2) .. "┐" .. Terminal.reset_color())

    Terminal.move_cursor(start_row + 1, start_col)
    local prompt_line = " > " .. app.palette_input .. "█"
    prompt_line = fit_to_width(prompt_line, p_width - 2)
    io.write(pop_bg .. act_fg .. Terminal.bold() .. "│" .. prompt_line .. b_fg .. "│" .. Terminal.reset_color())

    Terminal.move_cursor(start_row + 2, start_col)
    io.write(pop_bg .. b_fg .. "├" .. string.rep("─", p_width - 2) .. "┤" .. Terminal.reset_color())

    local Keybindings = require("src.keybindings")
    local filtered = {}
    local q = app.palette_input:lower()
    for _, e in ipairs(Keybindings.palette_entries) do
        if q == "" or e.label:lower():find(q, 1, true) then
            table.insert(filtered, e)
        end
    end

    for i = 1, p_height - 4 do
        Terminal.move_cursor(start_row + 2 + i, start_col)
        local item = filtered[i]
        local item_text = ""
        if item then
            if i == app.palette_sel then
                item_text = sel_bg .. act_fg .. Terminal.bold() .. " ▶ " .. fit_to_width(item.label, p_width - 6) .. " "
            else
                item_text = pop_bg .. pop_fg .. "   " .. fit_to_width(item.label, p_width - 6) .. " "
            end
        else
            item_text = pop_bg .. string.rep(" ", p_width - 2)
        end
        io.write(b_fg .. "│" .. item_text .. b_fg .. "│" .. Terminal.reset_color())
    end

    Terminal.move_cursor(start_row + p_height - 1, start_col)
    io.write(pop_bg .. b_fg .. "└" .. string.rep("─", p_width - 2) .. "┘" .. Terminal.reset_color())
end

function UI.render_whichkey_popup(app, rows, cols, theme)
    local p_height = 5
    local start_row = rows - p_height
    local pop_bg = Terminal.bg_rgb(theme.popup[1], theme.popup[2], theme.popup[3])
    local b_fg   = Terminal.fg_rgb(theme.borders[1], theme.borders[2], theme.borders[3])
    local key_fg = Terminal.fg_rgb(theme.keywords[1], theme.keywords[2], theme.keywords[3])
    local lbl_fg = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])

    Terminal.move_cursor(start_row, 1)
    io.write(pop_bg .. b_fg .. "┌─ which-key: Space Leader ────────────────────────────────────────────────────────┐" .. Terminal.reset_color())

    local chords = {
        { "w", "Save file" }, { "q", "Quit" }, { "e", "Explorer" }, { "f", "Find in file" },
        { "t", "40 Themes" }, { "s", "12 Styles" }, { "m", "LSP Format" }, { "x", "LSP Diags" },
        { "h", "LSP Hover" }, { "g", "LSP Definition" }, { "l", "Lazy plugins" }, { "p", "Palette" },
        { "[", "Prev buffer" }, { "]", "Next buffer" }, { "n", "New buffer" }, { "d", "Close buffer" },
    }

    for line = 1, 3 do
        Terminal.move_cursor(start_row + line, 1)
        local parts = {}
        local start_idx = (line - 1) * 5 + 1
        for i = start_idx, math.min(#chords, start_idx + 4) do
            local c = chords[i]
            table.insert(parts, string.format(" %s%s%s %s", key_fg .. Terminal.bold(), c[1], Terminal.reset_color() .. pop_bg, lbl_fg .. c[2]))
        end
        local content = table.concat(parts, "  │")
        local fitted_line = fit_to_width(content, cols - 2)
        io.write(pop_bg .. b_fg .. "│" .. fitted_line .. b_fg .. "│" .. "\27[K" .. Terminal.reset_color())
    end

    Terminal.move_cursor(rows, 1)
    io.write(pop_bg .. b_fg .. "└─────────────────────────────────────────────────────────────────────────────────┘" .. "\27[K" .. Terminal.reset_color())
end

function UI.render_hover_popup(app, rows, cols, theme)
    if not app.show_hover or not app.hover_data then return end

    local data = app.hover_data
    local title = data.title or "Hover Info"
    local subtitle = data.subtitle or ""
    local details = data.details or {}
    local category = data.category or "Hover Inspector"

    -- Calculate box width & height
    local max_len = math.max(#title, #subtitle)
    for _, l in ipairs(details) do
        if #l > max_len then max_len = #l end
    end
    local box_w = math.min(cols - 4, math.max(42, max_len + 8))
    local content_w = box_w - 2

    local box_h = 2 + #details + (subtitle ~= "" and 2 or 0) + 1

    -- Placement relative to cursor
    local header_rows = (app.style and app.style.header) and 1 or 0
    local cur_screen_row = app.buffer.cursor_row - app.buffer.row_offset + 1 + header_rows
    local sb_w = (app.filesystem and app.filesystem.is_visible) and (app.style and app.style.explorer_width or 28) or 0
    local gt_w = (app.style and app.style.line_numbers) and 6 or 0
    local cur_screen_col = sb_w + gt_w + app.buffer.cursor_col

    local start_row = cur_screen_row - box_h
    if start_row < 2 then
        start_row = cur_screen_row + 1
    end
    start_row = math.max(2, math.min(rows - box_h - 1, start_row))
    local start_col = math.max(sb_w + 2, math.min(cols - box_w - 1, cur_screen_col - 2))

    local pop_bg = Terminal.bg_rgb(theme.popup[1], theme.popup[2], theme.popup[3])
    local pop_fg = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local b_fg   = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])
    local act_fg = Terminal.fg_rgb(theme.keywords[1], theme.keywords[2], theme.keywords[3])
    local mut_fg = Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3])
    local reset  = Terminal.reset_color()

    -- Swatch prefix if hex color
    local swatch_str = ""
    if data.swatch then
        local sw = data.swatch
        swatch_str = Terminal.fg_rgb(sw.r, sw.g, sw.b) .. "■ " .. reset .. pop_bg
    end

    -- Top header border: ╭── 󰋼 Category ────────────╮
    Terminal.move_cursor(start_row, start_col)
    local cat_tag = " 󰋼 " .. category .. " "
    local bar_len = math.max(0, box_w - 4 - #cat_tag)
    local top_str = "╭──" .. cat_tag .. string.rep("─", bar_len) .. "╮"
    io.write(pop_bg .. b_fg .. Terminal.bold() .. fit_to_width(top_str, box_w) .. reset)

    local cur_r = start_row + 1

    -- Title line (e.g. <element class="glassmorphic-illustration"> or ■ #9C83FF)
    Terminal.move_cursor(cur_r, start_col)
    local t_line = " " .. swatch_str .. Terminal.bold() .. act_fg .. title
    local fitted_t = fit_to_width(t_line, content_w)
    io.write(pop_bg .. b_fg .. "│" .. pop_bg .. fitted_t .. b_fg .. "│" .. reset)
    cur_r = cur_r + 1

    -- Subtitle (e.g. Selector Specificity: (0, 1, 0) or rgb/hsl values)
    if subtitle ~= "" then
        Terminal.move_cursor(cur_r, start_col)
        io.write(pop_bg .. b_fg .. "├" .. string.rep("─", content_w) .. "┤" .. reset)
        cur_r = cur_r + 1

        Terminal.move_cursor(cur_r, start_col)
        local s_line = " " .. mut_fg .. subtitle
        local fitted_s = fit_to_width(s_line, content_w)
        io.write(pop_bg .. b_fg .. "│" .. pop_bg .. fitted_s .. b_fg .. "│" .. reset)
        cur_r = cur_r + 1
    end

    -- Detail description lines
    for _, d in ipairs(details) do
        Terminal.move_cursor(cur_r, start_col)
        local d_line = " " .. pop_fg .. d
        local fitted_d = fit_to_width(d_line, content_w)
        io.write(pop_bg .. b_fg .. "│" .. pop_bg .. fitted_d .. b_fg .. "│" .. reset)
        cur_r = cur_r + 1
    end

    -- Bottom border: ╰──────────────────────────────╯
    Terminal.move_cursor(cur_r, start_col)
    local bot_str = "╰" .. string.rep("─", content_w) .. "╯"
    io.write(pop_bg .. b_fg .. bot_str .. reset)
end

return UI
