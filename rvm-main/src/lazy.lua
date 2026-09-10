local Terminal = require("src.terminal")

local Lazy = {}

Lazy.plugins = {
    { name = "lazy.nvim", tag = "v11.14.0", time = "0.8ms", status = "loaded", desc = "Modern plugin manager for Neovim/RVM", url = "https://github.com/folke/lazy.nvim.git" },
    { name = "LazyVim", tag = "v12.3.0", time = "1.1ms", status = "loaded", desc = "LazyVim core distribution spec & Neovim setup", url = "https://github.com/LazyVim/LazyVim.git" },
    { name = "vim", tag = "v9.1.0", time = "0.5ms", status = "loaded", desc = "Vim core runtime & compatibility layer", url = "https://github.com/vim/vim.git" },
    { name = "telescope.nvim", tag = "v0.1.8", time = "2.4ms", status = "loaded", desc = "Fuzzy finder over lists, files, and text" },
    { name = "nvim-treesitter", tag = "v0.9.2", time = "3.1ms", status = "loaded", desc = "Nvim Treesitter configurations and abstraction layer" },
    { name = "catppuccin", tag = "v1.7.0", time = "1.2ms", status = "loaded", desc = "Soothing pastel theme for RVM" },
    { name = "tokyonight.nvim", tag = "v3.0.1", time = "0.9ms", status = "loaded", desc = "Tokyo Night color scheme" },
    { name = "dracula.nvim", tag = "v2.0.0", time = "0.7ms", status = "loaded", desc = "Dark theme for RVM" },
    { name = "lualine.nvim", tag = "v1.0.0", time = "1.5ms", status = "loaded", desc = "Blazingly fast and easy to configure statusline" },
    { name = "gitsigns.nvim", tag = "v0.9.0", time = "1.1ms", status = "loaded", desc = "Git integration for buffers" },
    { name = "which-key.nvim", tag = "v3.13.0", time = "0.6ms", status = "loaded", desc = "Displays popup with keybindings" },
    { name = "neo-tree.nvim", tag = "v3.26.0", time = "2.2ms", status = "loaded", desc = "File explorer tree for RVM workspace" },
    { name = "bufferline.nvim", tag = "v4.6.0", time = "1.0ms", status = "loaded", desc = "Snazzy buffer line for RVM" },
    { name = "nvim-cmp", tag = "v0.0.1", time = "1.8ms", status = "loaded", desc = "Auto completion engine for Lua, Python, HTML" }
}

function Lazy.render(rows, cols, theme)
    local e_bg = Terminal.bg_rgb(theme.editor_bg[1], theme.editor_bg[2], theme.editor_bg[3])
    local h_bg = Terminal.bg_rgb(theme.header_bg[1], theme.header_bg[2], theme.header_bg[3])
    local accent = Terminal.fg_rgb(147, 197, 253)
    local green = Terminal.fg_rgb(74, 222, 128)
    local orange = Terminal.fg_rgb(251, 146, 60)
    local mut = Terminal.fg_rgb(156, 163, 175)
    local text = Terminal.fg_rgb(229, 231, 235)
    local pink = Terminal.fg_rgb(244, 114, 182)

    Terminal.clear()

    -- Title box
    Terminal.move_cursor(1, 1)
    local title = " 💤 lazy.nvim — RVM Plugin Manager (" .. #Lazy.plugins .. " plugins loaded in 12.4ms) "
    title = title .. string.rep(" ", math.max(0, cols - #title))
    io.write(h_bg .. accent .. Terminal.bold() .. title:sub(1, cols) .. Terminal.reset_color())

    -- Action bar
    Terminal.move_cursor(2, 1)
    local actions = " [S] Sync  [U] Update  [C] Check  [L] Log  [D] Debug  [X] Clean  [Q/Esc] Back "
    actions = actions .. string.rep(" ", math.max(0, cols - #actions))
    io.write(e_bg .. orange .. actions:sub(1, cols) .. Terminal.reset_color())

    -- Table header
    Terminal.move_cursor(4, 3)
    io.write(e_bg .. mut .. Terminal.bold() .. string.format("%-22s %-12s %-10s %s", "PLUGIN", "VERSION", "TIME", "DESCRIPTION") .. Terminal.reset_color())

    -- Divider
    Terminal.move_cursor(5, 3)
    io.write(e_bg .. mut .. string.rep("─", cols - 6) .. Terminal.reset_color())

    -- Render plugin rows
    for i, p in ipairs(Lazy.plugins) do
        if i + 5 < rows - 2 then
            Terminal.move_cursor(i + 5, 3)
            local status_icon = green .. "● "
            local name_str = text .. Terminal.bold() .. string.format("%-20s", p.name)
            local tag_str = orange .. string.format("%-12s", p.tag)
            local time_str = pink .. string.format("%-10s", p.time)
            local desc_str = mut .. p.desc

            local line = status_icon .. name_str .. " " .. tag_str .. " " .. time_str .. " " .. desc_str
            io.write(e_bg .. line .. Terminal.reset_color())
        end
    end

    -- Footer info
    Terminal.move_cursor(rows - 1, 3)
    io.write(e_bg .. green .. "● Total 12/12 plugins up to date. Press [Esc] or [Q] to return." .. Terminal.reset_color())

    io.flush()
end

return Lazy
