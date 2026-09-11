-- src/config/keymaps.lua
-- Leader chord registry. Per spec requirement #3:
--   <leader>ff = Find Files
--   <leader>fg = Live Grep
--   <leader>fb = Buffers
--   <leader>fr = Recent Files
--   <leader>e  = Explorer
--   <leader>pp = Projects
--   <leader>gg = Git
--   <leader>xx = Diagnostics
--   <leader>ca = Code Action
--   <leader>rn = Rename
--   <leader>tt = Terminal
--
-- This is a static registry for documentation and lookup. The actual dispatch
-- happens in `src/keybindings.lua` via `src/whichkey.lua`.

local Keymaps = {
    leader = " ", -- Space is the default leader (per spec requirement #3)

    defaults = {
        -- File finders (Telescope-like per spec requirement #7)
        ["<leader>ff"] = { action = "finder_files",     desc = "Find Files" },
        ["<leader>fg"] = { action = "finder_grep",      desc = "Live Grep" },
        ["<leader>fb"] = { action = "finder_buffers",   desc = "Buffers" },
        ["<leader>fr"] = { action = "finder_recent",    desc = "Recent Files" },
        ["<leader>fc"] = { action = "finder_commands",  desc = "Commands" },
        ["<leader>fh"] = { action = "finder_help",      desc = "Help" },
        ["<leader>fk"] = { action = "finder_keymaps",   desc = "Key Maps" },

        -- Git (per spec requirement #9)
        ["<leader>gg"] = { action = "git_status",       desc = "Git Status" },
        ["<leader>gd"] = { action = "git_diff",         desc = "Git Diff" },
        ["<leader>gc"] = { action = "git_commit",       desc = "Git Commit" },
        ["<leader>gp"] = { action = "git_push",         desc = "Git Push" },
        ["<leader>gl"] = { action = "git_log",          desc = "Git Log" },
        ["<leader>gb"] = { action = "git_branch",       desc = "Git Branch" },
        ["<leader>ga"] = { action = "git_stage_all",    desc = "Git Stage All" },
        ["<leader>gu"] = { action = "git_unstage_all",  desc = "Git Unstage All" },

        -- Buffers (per spec requirement #10)
        ["<leader>bd"] = { action = "buffer_delete",    desc = "Delete Buffer" },
        ["<leader>bo"] = { action = "buffer_close_others", desc = "Close Other Buffers" },
        ["<leader>bn"] = { action = "buffer_next",      desc = "Next Buffer" },
        ["<leader>bp"] = { action = "buffer_prev",      desc = "Previous Buffer" },
        ["<leader>bl"] = { action = "buffer_list",      desc = "Buffer List" },

        -- Projects (per spec requirement #5)
        ["<leader>pp"] = { action = "project_switch",   desc = "Project Switcher" },
        ["<leader>pf"] = { action = "project_files",    desc = "Project Files" },
        ["<leader>pg"] = { action = "project_grep",     desc = "Project Grep" },
        ["<leader>pr"] = { action = "project_recent",   desc = "Recent Projects" },
        ["<leader>pd"] = { action = "project_dashboard", desc = "Project Dashboard" },

        -- LSP (per spec requirement #8)
        ["<leader>la"] = { action = "lsp_code_action",  desc = "Code Action" },
        ["<leader>lr"] = { action = "lsp_rename",       desc = "Rename Symbol" },
        ["<leader>lf"] = { action = "lsp_format",       desc = "Format Buffer" },
        ["<leader>lh"] = { action = "lsp_hover",        desc = "LSP Hover" },
        ["<leader>ld"] = { action = "lsp_definition",   desc = "LSP Definition" },
        ["<leader>ll"] = { action = "lsp_references",   desc = "LSP References" },
        ["<leader>ls"] = { action = "lsp_signature",    desc = "Signature Help" },
        ["<leader>lw"] = { action = "lsp_workspace_syms", desc = "Workspace Symbols" },

        -- Diagnostics (per spec requirement #8)
        ["<leader>xx"] = { action = "diagnostics_panel", desc = "Diagnostics Panel" },
        ["<leader>xn"] = { action = "diagnostics_next",  desc = "Next Diagnostic" },
        ["<leader>xp"] = { action = "diagnostics_prev",  desc = "Prev Diagnostic" },
        ["<leader>xo"] = { action = "diagnostics_open", desc = "Open Diagnostics" },

        -- Terminal (per spec requirement #12)
        ["<leader>tt"] = { action = "terminal_toggle",  desc = "Toggle Terminal" },
        ["<leader>tf"] = { action = "terminal_float",   desc = "Terminal Float" },
        ["<leader>to"] = { action = "terminal_new",     desc = "Open New Terminal" },

        -- Window (per spec requirement #11)
        ["<leader>ws"] = { action = "window_split",     desc = "Split Horizontal" },
        ["<leader>wv"] = { action = "window_vsplit",    desc = "Split Vertical" },
        ["<leader>wc"] = { action = "window_close",     desc = "Close Window" },
        ["<leader>wo"] = { action = "window_close_others", desc = "Close Other Windows" },
        ["<leader>wh"] = { action = "window_focus_left",  desc = "Focus Left" },
        ["<leader>wj"] = { action = "window_focus_down",  desc = "Focus Down" },
        ["<leader>wk"] = { action = "window_focus_up",    desc = "Focus Up" },
        ["<leader>wl"] = { action = "window_focus_right", desc = "Focus Right" },
        ["<leader>w="] = { action = "window_equalize",   desc = "Equalize Windows" },
        ["<leader>w-"] = { action = "window_dec_h",      desc = "Decrease Height" },
        ["<leader>w+"] = { action = "window_inc_h",      desc = "Increase Height" },
        ["<leader>w<"] = { action = "window_dec_w",      desc = "Decrease Width" },
        ["<leader>w>"] = { action = "window_inc_w",      desc = "Increase Width" },

        -- Single-key shortcuts
        ["<leader>e"]  = { action = "explorer_toggle",  desc = "Toggle Explorer" },
        ["<leader>w"]  = { action = "file_save",        desc = "Save File" },
        ["<leader>q"]  = { action = "app_quit",         desc = "Quit" },
        ["<leader>Q"]  = { action = "app_force_quit",   desc = "Force Quit" },
        ["<leader>n"]  = { action = "buffer_new",       desc = "New Buffer" },
        ["<leader>t"]  = { action = "theme_cycle",      desc = "Cycle Themes" },
        ["<leader>s"]  = { action = "style_cycle",      desc = "Cycle Styles" },
        ["<leader>i"]  = { action = "icons_toggle",     desc = "Toggle Icons Mode" },
        ["<leader>u"]  = { action = "edit_undo",        desc = "Undo" },
        ["<leader>r"]  = { action = "edit_redo",        desc = "Redo" },

        -- Backward-compatible aliases (preserve original mapping names)
        ["<leader>d"]  = { action = "buffer_delete",    desc = "Close buffer (alias for bd)" },
        ["<leader>b"]  = { action = "finder_buffers",   desc = "Buffers (alias for fb)" },
        ["<leader>f"]  = { action = "lsp_format",       desc = "LSP format (alias for lf)" },
        ["<leader>p"]  = { action = "project_switch",   desc = "Project switcher (alias for pp)" },
        ["<leader>l"]  = { action = "lsp_hover",        desc = "LSP hover (alias for lh)" },
        ["<leader>["]  = { action = "buffer_prev",      desc = "Previous buffer (alias for bp)" },
        ["<leader>]"]  = { action = "buffer_next",      desc = "Next buffer (alias for bn)" },
    },

    -- Custom keymaps merged in by Config.merge(user_config.keymaps)
    custom = {}
}

function Keymaps.get(key)
    return Keymaps.custom[key] or Keymaps.defaults[key]
end

return Keymaps
