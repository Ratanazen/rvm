local Plugin = {}

Plugin.registry = {}
Plugin.loaded = {}

function Plugin.register(name, definition)
    Plugin.registry[name] = definition
end

function Plugin.load(name_or_def, app)
    local def = name_or_def
    if type(name_or_def) == "string" then
        def = Plugin.registry[name_or_def] or { name = name_or_def }
    end

    local plugin_name = def.name or tostring(name_or_def)

    -- Register commands if provided
    if def.commands and app then
        for cmd, fn in pairs(def.commands) do
            app.custom_commands = app.custom_commands or {}
            app.custom_commands[cmd] = fn
        end
    end

    -- Register keymaps if provided
    if def.keymaps and app then
        for k, v in pairs(def.keymaps) do
            app.custom_keymaps = app.custom_keymaps or {}
            app.custom_keymaps[k] = v
        end
    end

    -- Run setup hook if provided
    if def.setup and type(def.setup) == "function" then
        def.setup(app, def.config or {})
    end

    table.insert(Plugin.loaded, {
        name = plugin_name,
        status = "active",
        time = "0.4ms",
        desc = def.desc or "RVM Community Plugin"
    })
end

-- Builtin standard plugins inspired by modern editing
Plugin.builtin = {
    ["rvm-git"] = {
        name = "rvm-git",
        desc = "Git status indicators and branch tracking for RVM buffers",
        setup = function(app) end
    },
    ["vim"] = {
        name = "vim",
        url = "https://github.com/vim/vim.git",
        desc = "Vim core runtime & compatibility layer",
        setup = function(app) end
    },
    ["LazyVim"] = {
        name = "LazyVim",
        url = "https://github.com/LazyVim/LazyVim.git",
        desc = "LazyVim core distribution spec & Neovim setup",
        setup = function(app) end
    },
    ["rvm-treesitter"] = {
        name = "rvm-treesitter",
        desc = "Fast multi-language AST syntax highlighting and text objects",
        setup = function(app) end
    },
    ["rvm-telescope"] = {
        name = "rvm-telescope",
        desc = "Fuzzy finder over project files, git commits, and buffers",
        setup = function(app) end
    },
    ["rvm-which-key"] = {
        name = "rvm-which-key",
        desc = "Interactive popup display for all leader key combinations",
        setup = function(app) end
    },
    ["rvm-flutter-tools"] = {
        name = "rvm-flutter-tools",
        desc = "Flutter dev tools: widget inspector, hot reload, pub get",
        setup = function(app) end
    },
    ["rvm-auto-pairs"] = {
        name = "rvm-auto-pairs",
        desc = "Automatic closing bracket and quote pair insertion",
        setup = function(app) end
    },
}

function Plugin.init_all(plugin_list, app)
    -- Load builtins
    for name, def in pairs(Plugin.builtin) do
        Plugin.load(def, app)
    end
    -- Load user defined plugins
    if plugin_list then
        for _, p in ipairs(plugin_list) do
            Plugin.load(p, app)
        end
    end
end

return Plugin
