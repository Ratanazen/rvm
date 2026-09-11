local EditorConfig    = require("src.config.editor")
local LanguagesConfig = require("src.config.languages")
local KeymapsConfig   = require("src.config.keymaps")
local ThemesConfig    = require("src.config.themes")
local StylesConfig    = require("src.config.styles")
local PluginsConfig   = require("src.config.plugins")
local LSPConfig       = require("src.config.lsp")

local Config = {
    -- Per spec requirement #13/#18: default theme is "terminal" (terminal-native)
    -- and default style is "lazyvim" (LazyVim-inspired compact layout).
    theme = "RVM Terminal",
    style = "RVM LazyVim",

    editor = EditorConfig,
    languages = LanguagesConfig,
    keymaps = KeymapsConfig,
    themes = ThemesConfig,
    styles = StylesConfig,
    plugins = PluginsConfig.list,
    lsp = LSPConfig,

    explorer = {
        enabled = true,
        width = 26,
    },

    completion = {
        enabled = true,
    },

    format_on_save = true,

    -- Requirement 9: Filetype-specific styles & themes
    filetypes = {
        html = {
            theme = "RVM Ocean",
            tab_width = 2,
        },
        python = {
            theme = "RVM Forest",
            tab_width = 4,
        },
        rust = {
            theme = "RVM Midnight",
            tab_width = 4,
        },
        dart = {
            theme = "RVM Purple",
            tab_width = 2,
        },
        javascript = {
            theme = "RVM Dark",
            tab_width = 2,
        },
        typescript = {
            theme = "RVM Deep Ocean",
            tab_width = 2,
        },
        go = {
            theme = "RVM Cyan",
            tab_width = 4,
        },
        lua = {
            theme = "RVM Midnight",
            tab_width = 4,
        },
        markdown = {
            theme = "RVM Sepia",
            tab_width = 2,
        }
    }
}

function Config.merge(user_config)
    if not user_config then return Config end

    if user_config.theme then Config.theme = user_config.theme end
    if user_config.style then Config.style = user_config.style end

    if user_config.editor then
        for k, v in pairs(user_config.editor) do
            Config.editor[k] = v
        end
    end

    if user_config.explorer then
        for k, v in pairs(user_config.explorer) do
            Config.explorer[k] = v
        end
    end

    if user_config.languages then
        for k, v in pairs(user_config.languages) do
            Config.languages[k] = v
        end
    end

    if user_config.keymaps then
        for k, v in pairs(user_config.keymaps) do
            Config.keymaps.custom[k] = v
        end
    end

    if user_config.plugins then
        Config.plugins = user_config.plugins
    end

    if user_config.lsp then
        for k, v in pairs(user_config.lsp) do
            Config.lsp[k] = v
        end
    end

    if user_config.filetypes then
        for k, v in pairs(user_config.filetypes) do
            Config.filetypes[k] = v
        end
    end

    if user_config.format_on_save ~= nil then
        Config.format_on_save = user_config.format_on_save
    end

    return Config
end

-- Try loading user configuration from ~/.config/rvm/init.lua
function Config.load_user_config()
    local home = os.getenv("HOME") or ""
    local user_cfg_path = home .. "/.config/rvm/init.lua"
    local f = io.open(user_cfg_path, "r")
    if f then
        f:close()
        local ok, user_mod = pcall(dofile, user_cfg_path)
        if ok and type(user_mod) == "table" then
            Config.merge(user_mod)
        end
    end

    -- ─────────────────────────────────────────────────────────
    -- vim.g.* style configuration (per spec requirement #18)
    -- Users can place the following in ~/.config/rvm/init.lua:
    --   vim.g.mapleader = " "
    --   vim.g.rvm_theme = "terminal"
    --   vim.g.rvm_style = "lazyvim"
    --   vim.g.rvm_project = true
    --   vim.g.rvm_lsp = true
    --   vim.g.rvm_git = true
    --   vim.g.rvm_format_on_save = true
    --   vim.g.rvm_icons = true
    -- The user config module is expected to either define a `vim` global
    -- (i.e. `vim = { g = { ... } }`) before the merge, or set keys directly.
    -- ─────────────────────────────────────────────────────────
    local vg = (user_mod and user_mod.vim and user_mod.vim.g) or (vim and vim.g) or nil
    if vg then
        if vg.mapleader        then Config.leader = vg.mapleader end
        if vg.rvm_theme        then Config.theme = vg.rvm_theme end
        if vg.rvm_style        then Config.style = vg.rvm_style end
        if vg.rvm_project      ~= nil then Config.project_enabled  = vg.rvm_project end
        if vg.rvm_lsp          ~= nil then Config.lsp_enabled       = vg.rvm_lsp end
        if vg.rvm_git          ~= nil then Config.git_enabled       = vg.rvm_git end
        if vg.rvm_format_on_save ~= nil then Config.format_on_save  = vg.rvm_format_on_save end
        if vg.rvm_icons        ~= nil then Config.icons_enabled     = vg.rvm_icons end
    end

    -- Fallback defaults (spec requirement #18)
    if Config.leader           == nil then Config.leader           = " " end
    if Config.project_enabled  == nil then Config.project_enabled  = true end
    if Config.lsp_enabled      == nil then Config.lsp_enabled      = true end
    if Config.git_enabled      == nil then Config.git_enabled      = true end
    if Config.icons_enabled    == nil then Config.icons_enabled    = true end
    if Config.format_on_save   == nil then Config.format_on_save  = true end
end

return Config
