local Icons = {}

-- Icon definitions mapping file extensions & UI elements to image assets and terminal text fallbacks
Icons.map = {
    -- Languages & File Types
    vue = {
        image = "icons/vue.png",
        fallback_glyph = "V",
        fallback_color = {66, 184, 131}
    },
    css = {
        image = "icons/css.png",
        fallback_glyph = "#",
        fallback_color = {56, 189, 248}
    },
    scss = {
        image = "icons/css.png",
        fallback_glyph = "#",
        fallback_color = {56, 189, 248}
    },
    sass = {
        image = "icons/css.png",
        fallback_glyph = "#",
        fallback_color = {56, 189, 248}
    },
    html = {
        image = "icons/html.png",
        fallback_glyph = "<>",
        fallback_color = {249, 115, 22}
    },
    htm = {
        image = "icons/html.png",
        fallback_glyph = "<>",
        fallback_color = {249, 115, 22}
    },
    php = {
        image = "icons/php.png",
        fallback_glyph = "PHP",
        fallback_color = {136, 146, 191}
    },
    js = {
        image = "icons/js.png",
        fallback_glyph = "JS",
        fallback_color = {250, 204, 21}
    },
    mjs = {
        image = "icons/js.png",
        fallback_glyph = "JS",
        fallback_color = {250, 204, 21}
    },
    cjs = {
        image = "icons/js.png",
        fallback_glyph = "JS",
        fallback_color = {250, 204, 21}
    },
    ts = {
        image = "icons/ts.png",
        fallback_glyph = "TS",
        fallback_color = {96, 165, 250}
    },
    tsx = {
        image = "icons/ts.png",
        fallback_glyph = "TS",
        fallback_color = {96, 165, 250}
    },
    jsx = {
        image = "icons/js.png",
        fallback_glyph = "⚛",
        fallback_color = {56, 189, 248}
    },
    py = {
        image = "icons/py.png",
        fallback_glyph = "PY",
        fallback_color = {74, 222, 128}
    },
    dart = {
        image = "icons/dart.png",
        fallback_glyph = "🎯",
        fallback_color = {192, 132, 252}
    },
    rs = {
        image = "icons/rs.png",
        fallback_glyph = "🦀",
        fallback_color = {251, 146, 60}
    },
    rust = {
        image = "icons/rs.png",
        fallback_glyph = "🦀",
        fallback_color = {251, 146, 60}
    },
    go = {
        image = "icons/go.png",
        fallback_glyph = "🐹",
        fallback_color = {34, 211, 238}
    },
    json = {
        image = "icons/json.png",
        fallback_glyph = "{}",
        fallback_color = {253, 224, 71}
    },
    md = {
        image = "icons/md.png",
        fallback_glyph = "M↓",
        fallback_color = {148, 163, 184}
    },
    markdown = {
        image = "icons/md.png",
        fallback_glyph = "M↓",
        fallback_color = {148, 163, 184}
    },
    lua = {
        image = "icons/lua.png",
        fallback_glyph = "🌕",
        fallback_color = {59, 130, 246}
    },
    yaml = {
        image = "icons/default_file.png",
        fallback_glyph = "⚙",
        fallback_color = {251, 191, 36}
    },
    yml = {
        image = "icons/default_file.png",
        fallback_glyph = "⚙",
        fallback_color = {251, 191, 36}
    },
    toml = {
        image = "icons/default_file.png",
        fallback_glyph = "⚙",
        fallback_color = {251, 191, 36}
    },

    -- Folder & Special UI elements
    folder_open = {
        image = "icons/folder_open.png",
        fallback_glyph = "v",
        fallback_color = {156, 163, 175}
    },
    folder_closed = {
        image = "icons/folder_closed.png",
        fallback_glyph = ">",
        fallback_color = {156, 163, 175}
    },
    default_file = {
        image = "icons/default_file.png",
        fallback_glyph = "📄",
        fallback_color = {204, 204, 204}
    },

    -- Dashboard keys
    save = {
        image = "icons/save.png",
        fallback_glyph = "💾",
        fallback_color = {56, 189, 248}
    },
    explorer = {
        image = "icons/explorer.png",
        fallback_glyph = "📂",
        fallback_color = {251, 191, 36}
    },
    theme = {
        image = "icons/theme.png",
        fallback_glyph = "🎨",
        fallback_color = {192, 132, 252}
    },
}

-- Helper to resolve icon definition
function Icons.get(entry_or_key, is_dir, is_expanded)
    if type(entry_or_key) == "table" then
        local entry = entry_or_key
        if entry.is_dir then
            return entry.is_expanded and Icons.map.folder_open or Icons.map.folder_closed
        end
        local ext = entry.name and entry.name:match("%.([%w_]+)$")
        if ext then
            ext = ext:lower()
            return Icons.map[ext] or Icons.map.default_file
        end
        return Icons.map.default_file
    elseif type(entry_or_key) == "string" then
        local key = entry_or_key:lower()
        if is_dir then
            return is_expanded and Icons.map.folder_open or Icons.map.folder_closed
        end
        return Icons.map[key] or Icons.map.default_file
    end

    return Icons.map.default_file
end

return Icons
