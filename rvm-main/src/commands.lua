local Theme  = require("src.theme")
local Styles = require("src.styles")
local LSP    = require("src.lsp")
local Git    = require("src.git")
local Project = require("src.project")

local Commands = {}

function Commands.execute(cmd_str, app)
    cmd_str = cmd_str:gsub("^%s*(.-)%s*$", "%1")
    if cmd_str == "" then return end
    local cmd_lower = cmd_str:lower()

    -- Check custom plugin commands first
    if app.custom_commands and app.custom_commands[cmd_str] then
        local ok, res = pcall(app.custom_commands[cmd_str], app)
        if ok and res then app.status_msg = tostring(res) end
        return
    end

    -- 1. :RVMStyle / :style
    if cmd_str:match("^[Rr][Vv][Mm][Ss]tyle$") or cmd_lower == "style" then
        local names = {}
        for _, s in ipairs(Styles.list) do
            local mark = (app.style and app.style.id == s.id) and "*" or ""
            table.insert(names, mark .. s.name)
        end
        app.status_msg = "Available Styles: " .. table.concat(names, ", ")
        return
    elseif cmd_str:match("^[Rr][Vv][Mm][Ss]tyle%s+(.+)$") or cmd_lower:match("^style%s+(.+)$") then
        local s_query = cmd_str:match("^[Rr][Vv][Mm][Ss]tyle%s+(.+)$") or cmd_str:match("^style%s+(.+)$")
        local new_style = Styles.get(s_query)
        if new_style then
            app.style = new_style
            if app.filesystem then
                app.filesystem.is_visible = new_style.sidebar
            end
            app.status_msg = "Applied Style: " .. new_style.name .. " (" .. new_style.desc .. ")"
        else
            app.status_msg = "Style not found: " .. s_query
        end
        return
    end

    -- 2. :theme
    if cmd_lower == "theme" or cmd_lower == "themes" or cmd_lower == "colorscheme" then
        app.theme_index = (app.theme_index % #Theme.list) + 1
        app.theme = Theme.list[app.theme_index]
        app.status_msg = "Theme: " .. app.theme.name .. " (" .. app.theme_index .. "/" .. #Theme.list .. ")"
        return
    elseif cmd_lower:match("^theme%s+(.+)$") or cmd_lower:match("^colorscheme%s+(.+)$") then
        local t_query = cmd_str:match("^%S+%s+(.+)$")
        local new_theme = Theme.get(t_query)
        if new_theme then
            app.theme = new_theme
            app.status_msg = "Applied theme: " .. new_theme.name
        else
            app.status_msg = "Theme not found: " .. t_query
        end
        return
    end

    -- 3. :w / :write
    if cmd_lower == "w" or cmd_lower == "write" then
        -- Honor format-on-save via App:save_buffer() (per spec #18)
        if app.save_buffer then
            local ok, err = app:save_buffer()
            if not ok then
                app.status_msg = "Error writing: " .. tostring(err)
            end
        else
            local ok, err = app.buffer:save()
            if ok then
                app.status_msg = "Written to " .. (app.buffer.file_path or "untitled")
            else
                app.status_msg = "Error writing: " .. tostring(err)
            end
        end
        return
    elseif cmd_lower:match("^w%s+(.+)$") or cmd_lower:match("^write%s+(.+)$") then
        local path = cmd_str:match("^%S+%s+(.+)$")
        local ok, err = app.buffer:save(path)
        app.status_msg = ok and ("Saved as " .. path) or ("Error: " .. tostring(err))
        return
    end

    -- 4. :q / :quit
    if cmd_lower == "q" or cmd_lower == "quit" then
        if app.buffer.is_dirty then
            app.status_msg = "No write since last change (add ! to override)"
        else
            app.should_quit = true
        end
        return
    elseif cmd_lower == "wq" or cmd_lower == "x" then
        app.buffer:save()
        app.should_quit = true
        return
    elseif cmd_lower == "q!" or cmd_lower == "quit!" then
        app.should_quit = true
        return
    end

    -- 5. :e <file>
    if cmd_lower:match("^e%s+(.+)$") or cmd_lower:match("^edit%s+(.+)$") then
        local path = cmd_str:match("^%S+%s+(.+)$")
        app:open_buffer(path)
        app.status_msg = "Opened: " .. path
        return
    end

    -- 6. :format / :fmt
    if cmd_lower == "format" or cmd_lower == "fmt" then
        LSP.format(app.buffer)
        app.status_msg = "Formatted document using LSP / Indenter"
        return
    end

    -- :reveal — reveal current buffer file in the explorer
    if cmd_lower == "reveal" or cmd_lower == "revalcurrent" then
        if app.reveal_current_in_explorer then
            local ok = app:reveal_current_in_explorer()
            app.status_msg = ok and "Revealed in explorer" or "Could not reveal (no file or no explorer)"
        else
            app.status_msg = "Reveal not supported in this build"
        end
        return
    end

    -- :save / :write with format — explicit save with format
    if cmd_lower == "save" then
        if app.save_buffer then
            app:save_buffer(true)
        else
            local ok, err = app.buffer:save()
            app.status_msg = ok and "Saved" or ("Error: " .. tostring(err))
        end
        return
    end

    -- 7. :lsp
    if cmd_lower == "lsp" or cmd_lower == "lspinfo" then
        local srv, lang = LSP.detect_server(app.buffer)
        local diags = LSP.diagnostics(app.buffer)
        if srv then
            app.status_msg = string.format("LSP: %s | Server: %s | Diags: %d issues", lang.name, srv.binary, #diags)
        else
            app.status_msg = string.format("LSP: Generic indenter active | Diags: %d issues", #diags)
        end
        return
    end

    -- 8. :buffers / :ls
    if cmd_lower == "buffers" or cmd_lower == "ls" then
        local names = {}
        for i, b in ipairs(app.buffers) do
            local mark = (i == app.buf_index) and "%" or " "
            local dirty = b.is_dirty and "+" or " "
            local name = b.file_path and b.file_path:match("[^/]+$") or "Untitled"
            table.insert(names, string.format("%d%s%s %s", i, mark, dirty, name))
        end
        app.status_msg = "Buffers: " .. table.concat(names, " | ")
        return
    elseif cmd_lower:match("^b%s+(%d+)$") or cmd_lower:match("^buffer%s+(%d+)$") then
        local idx = tonumber(cmd_str:match("%d+"))
        if idx and app.buffers[idx] then
            app.buf_index = idx
            app.buffer = app.buffers[idx]
            app.status_msg = "Switched to buffer " .. idx
        else
            app.status_msg = "Invalid buffer index"
        end
        return
    elseif cmd_lower == "bd" or cmd_lower == "bdelete" then
        app:close_buffer()
        app.status_msg = "Buffer closed"
        return
    end

    -- 9. :lazy / :plugins
    if cmd_lower == "lazy" or cmd_lower == "plugins" then
        app.show_lazy = true
        return
    end

    -- 10. :RVMIcons / :icons [auto|image|glyph]
    if cmd_lower == "rvmicons" or cmd_lower == "icons" then
        local TerminalGraphics = require("src.terminal_graphics")
        app.status_msg = "Icons Mode: " .. TerminalGraphics.mode .. " (Terminal Supported: " .. tostring(TerminalGraphics.supported) .. ")"
        return
    elseif cmd_lower:match("^rvmicons%s+(.+)$") or cmd_lower:match("^icons%s+(.+)$") then
        local TerminalGraphics = require("src.terminal_graphics")
        local arg = (cmd_str:match("^%S+%s+(.+)$") or ""):lower()
        if arg == "auto" or arg == "image" or arg == "glyph" then
            TerminalGraphics.set_mode(arg)
            if arg == "glyph" then
                TerminalGraphics.clear_all()
            end
            app.status_msg = "Icons Mode set to: " .. arg
        else
            app.status_msg = "Usage: :RVMIcons <auto|image|glyph>"
        end
        return
    end

    -- 11. :help
    if cmd_lower == "h" or cmd_lower == "help" then
        app.status_msg = "Commands: :w, :q, :wq, :RVMStyle <name>, :theme <name>, :RVMIcons <mode>, :format, :lsp, :lazy, :buffers, :GitCommit <msg>, :GitPush, :GitLog, :ProjectSwitch, :GitDiff"
        return
    end

    -- ─────────────────────────────────────────────────────────
    -- New commands: Git / Project / Window / Terminal / Find
    -- (per spec requirements #5, #9, #11, #12)
    -- ─────────────────────────────────────────────────────────

    -- Git commands
    if cmd_lower:match("^gitcommit%s+(.+)$") then
        local msg = cmd_str:match("^%S+%s+(.+)$")
        local out = Git.commit(app.project and app.project.root or ".", msg)
        app.status_msg = "Commit: " .. tostring(out):sub(1, 80)
        return
    elseif cmd_lower == "gitstatus" then
        local entries = Git.status(app.project and app.project.root or ".")
        local counts = Git.status_summary(app.project and app.project.root or ".")
        app.git_state.last_status = entries
        app.status_msg = string.format("Git: M=%d A=%d D=%d ??=%d",
            counts.modified, counts.added, counts.deleted, counts.untracked)
        return
    elseif cmd_lower == "gitdiff" then
        local diff = Git.diff(app.project and app.project.root or ".")
        app.git_state.last_diff = diff
        app.status_msg = "Git diff (" .. #diff .. " chars)"
        return
    elseif cmd_lower == "gitpush" then
        local out = Git.push(app.project and app.project.root or ".")
        app.status_msg = "Git push: " .. tostring(out):sub(1, 80)
        return
    elseif cmd_lower == "gitpull" then
        local out = Git.pull(app.project and app.project.root or ".")
        app.status_msg = "Git pull: " .. tostring(out):sub(1, 80)
        return
    elseif cmd_lower == "gitlog" then
        local log = Git.log(app.project and app.project.root or ".", 30)
        app.git_state.last_log = log
        app.status_msg = "Git log: " .. #log .. " entries"
        return
    elseif cmd_lower:match("^gitcheckout%s+(.+)$") then
        local branch = cmd_str:match("^%S+%s+(.+)$")
        local out = Git.checkout(app.project and app.project.root or ".", branch)
        app.status_msg = "Git checkout: " .. tostring(out):sub(1, 80)
        return
    elseif cmd_lower:match("^gitbranch%s+(.+)$") then
        local name = cmd_str:match("^%S+%s+(.+)$")
        local out = Git.create_branch(app.project and app.project.root or ".", name)
        app.status_msg = "Git branch: " .. tostring(out):sub(1, 80)
        return
    elseif cmd_lower == "lazygit" then
        if Git.has_lazygit() then
            local Terminal = require("src.terminal")
            Terminal.disable_raw_mode()
            Git.launch_lazygit(app.project and app.project.root or ".")
            Terminal.enable_raw_mode()
            app.status_msg = "lazygit session ended"
        else
            app.status_msg = "lazygit not installed"
        end
        return
    end

    -- Project commands
    if cmd_lower == "project" or cmd_lower == "projectinfo" then
        local p = app.project or Project.detect(".")
        app.status_msg = string.format("Project: %s | Root: %s | Lang: %s | Git: %s",
            p.name, p.root or "?", p.lang or "plain", p.git_branch or "none")
        return
    elseif cmd_lower == "projectswitch" then
        app.finder:open("files", {
            cwd = app.project and app.project.root or ".",
            on_select = function(sel)
                if sel and sel.path and app.filesystem then
                    app.filesystem.root = sel.path
                    app.filesystem:scan_initial()
                    app.project = Project.detect(sel.path)
                    app.status_msg = "Project: " .. app.project.name
                    Project.recent_add(sel.path)
                end
            end,
        })
        return
    elseif cmd_lower == "projectroot" then
        local root = Project.find_root(app.project and app.project.root or ".")
        app.status_msg = "Project root: " .. root
        return
    elseif cmd_lower == "projectdashboard" then
        app.show_dashboard = true
        return
    end

    -- Window commands
    if cmd_lower == "split" then
        if app.workspace then app.workspace:split("h") end
        app.status_msg = "Window split"
        return
    elseif cmd_lower == "vsplit" then
        if app.workspace then app.workspace:split("v") end
        app.status_msg = "Window vsplit"
        return
    elseif cmd_lower == "close" or cmd_lower == "q" then
        -- Already handled :q above; this is for window close
    end

    -- Terminal commands
    if cmd_lower == "terminal" or cmd_lower == "term" then
        if not app.terminal then app.terminal = require("src.terminal_panel").new() end
        app.terminal:toggle()
        app.terminal_focus = app.terminal:is_open()
        return
    end

    -- Find / Grep commands
    if cmd_lower == "find" or cmd_lower == "files" then
        app.finder:open("files", { cwd = app.project and app.project.root or "." })
        return
    elseif cmd_lower == "grep" then
        app.finder:open("grep", { cwd = app.project and app.project.root or "." })
        return
    elseif cmd_lower:match("^grep%s+(.+)$") then
        local q = cmd_str:match("^%S+%s+(.+)$")
        app.finder.query = q
        app.finder:open("grep", { cwd = app.project and app.project.root or "." })
        app.finder.query = q
        app.finder:_refresh()
        return
    elseif cmd_lower == "buffers" or cmd_lower == "ls" then
        app.finder.app_ref = app
        app.finder:open("buffers")
        return
    elseif cmd_lower == "recent" then
        app.finder:open("recent", { cwd = app.project and app.project.root or "." })
        return
    elseif cmd_lower == "explorer" then
        if app.filesystem then
            app.filesystem.is_visible = not app.filesystem.is_visible
            app.status_msg = app.filesystem.is_visible and "Explorer opened" or "Explorer closed"
        end
        return
    end

    app.status_msg = "Not an editor command: :" .. cmd_str
end

return Commands
