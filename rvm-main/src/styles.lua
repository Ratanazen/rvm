local Styles = {}

Styles.list = {
    {
        id = "rvm-classic",
        name = "RVM Classic",
        sidebar = true,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "single",
        line_numbers = true,
        header = true,
        padding = 1,
        explorer_width = 24,
        icons = true,
        cursor_style = "block",
        popup_style = "border",
        terminal_position = "hidden",
        desc = "Standard full-featured RVM layout with top tabs and statusline"
    },
    {
        id = "rvm-minimal",
        name = "RVM Minimal",
        sidebar = false,
        statusline = false,
        tabline = false,
        borders = false,
        border_style = "none",
        line_numbers = false,
        header = false,
        padding = 0,
        explorer_width = 0,
        icons = false,
        cursor_style = "bar",
        popup_style = "minimal",
        terminal_position = "hidden",
        desc = "Pure distraction-free writing canvas with zero chrome"
    },
    {
        id = "rvm-vim",
        name = "RVM Vim",
        sidebar = false,
        statusline = true,
        tabline = false,
        borders = false,
        border_style = "none",
        line_numbers = true,
        header = false,
        padding = 0,
        explorer_width = 0,
        icons = false,
        cursor_style = "block",
        popup_style = "minimal",
        terminal_position = "bottom",
        desc = "Authentic Vim-like experience with bottom statusline and line numbers"
    },
    {
        id = "rvm-nano",
        name = "RVM Nano",
        sidebar = false,
        statusline = true,
        tabline = false,
        borders = true,
        border_style = "single",
        line_numbers = true,
        header = true,
        padding = 0,
        explorer_width = 0,
        icons = false,
        cursor_style = "bar",
        popup_style = "border",
        terminal_position = "hidden",
        desc = "Nano style with persistent top header and bottom shortcut legend"
    },
    {
        id = "rvm-ide",
        name = "RVM IDE",
        sidebar = true,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "rounded",
        line_numbers = true,
        header = true,
        padding = 1,
        explorer_width = 28,
        icons = true,
        cursor_style = "block",
        popup_style = "floating",
        terminal_position = "bottom",
        desc = "Full-blown modern IDE layout with wide explorer, tabs, and diagnostics"
    },
    {
        id = "rvm-compact",
        name = "RVM Compact",
        sidebar = false,
        statusline = true,
        tabline = true,
        borders = false,
        border_style = "none",
        line_numbers = true,
        header = false,
        padding = 0,
        explorer_width = 0,
        icons = true,
        cursor_style = "block",
        popup_style = "minimal",
        terminal_position = "hidden",
        desc = "Tightly packed UI maximizing vertical and horizontal editing space"
    },
    {
        id = "rvm-focus",
        name = "RVM Focus",
        sidebar = false,
        statusline = true,
        tabline = false,
        borders = true,
        border_style = "single",
        line_numbers = true,
        header = false,
        padding = 2,
        explorer_width = 0,
        icons = false,
        cursor_style = "block",
        popup_style = "minimal",
        terminal_position = "hidden",
        desc = "Centered zen mode with padded margins for deep focus"
    },
    {
        id = "rvm-split",
        name = "RVM Split",
        sidebar = true,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "single",
        line_numbers = true,
        header = true,
        padding = 1,
        explorer_width = 22,
        icons = true,
        cursor_style = "block",
        popup_style = "border",
        terminal_position = "side",
        desc = "Side-by-side workspace with synchronized split panes"
    },
    {
        id = "rvm-explorer",
        name = "RVM Explorer",
        sidebar = true,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "rounded",
        line_numbers = true,
        header = true,
        padding = 1,
        explorer_width = 34,
        icons = true,
        cursor_style = "block",
        popup_style = "floating",
        terminal_position = "hidden",
        desc = "File-centric view with an expansive project tree and metadata"
    },
    {
        id = "rvm-fullscreen",
        name = "RVM Fullscreen",
        sidebar = false,
        statusline = true,
        tabline = true,
        borders = false,
        border_style = "none",
        line_numbers = true,
        header = true,
        padding = 0,
        explorer_width = 0,
        icons = true,
        cursor_style = "block",
        popup_style = "border",
        terminal_position = "hidden",
        desc = "Edge-to-edge layout utilizing every terminal row and column"
    },
    {
        id = "rvm-terminal",
        name = "RVM Terminal",
        sidebar = false,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "single",
        line_numbers = true,
        header = true,
        padding = 0,
        explorer_width = 0,
        icons = true,
        cursor_style = "block",
        popup_style = "border",
        terminal_position = "bottom",
        desc = "Terminal-integrated layout with quick bash toggle"
    },
    {
        id = "rvm-developer",
        name = "RVM Developer",
        sidebar = true,
        statusline = true,
        tabline = true,
        borders = true,
        border_style = "double",
        line_numbers = true,
        header = true,
        padding = 1,
        explorer_width = 26,
        icons = true,
        cursor_style = "block",
        popup_style = "floating",
        terminal_position = "bottom",
        desc = "Power-user developer suite with LSP diagnostics, git signs, and full status"
    },
    -- 13. RVM LazyVim — new style per spec requirement #15
    {
        id = "rvm-lazyvim",
        name = "RVM LazyVim",
        sidebar = true,             -- explorer on the left
        statusline = true,           -- compact statusline
        tabline = true,              -- bufferline on top
        borders = false,             -- minimal borders
        border_style = "none",
        line_numbers = true,
        header = false,             -- no top header bar
        padding = 0,
        explorer_width = 22,        -- compact sidebar
        icons = true,
        cursor_style = "block",
        popup_style = "minimal",
        terminal_position = "hidden", -- on demand only
        desc = "Compact, keyboard-first LazyVim-inspired layout — minimal borders, information dense, project focused"
    },
}

function Styles.get(name_or_idx)
    if type(name_or_idx) == "number" then
        local idx = ((name_or_idx - 1) % #Styles.list) + 1
        return Styles.list[idx]
    elseif type(name_or_idx) == "string" then
        local q = name_or_idx:lower():gsub("%s+", ""):gsub("-", "")
        for _, s in ipairs(Styles.list) do
            local sn = s.name:lower():gsub("%s+", ""):gsub("-", "")
            local sid = s.id:lower():gsub("%s+", ""):gsub("-", "")
            if sn == q or sid == q or sn:find(q, 1, true) then
                return s
            end
        end
    end
    return Styles.list[1]
end

return Styles
