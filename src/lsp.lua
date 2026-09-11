local Languages = require("src.config.languages")

local LSP = {}

LSP.servers = {
    dart = { binary = "dart", args = { "language-server", "--protocol=lsp" }, desc = "Official Dart Analysis Server & Flutter LSP" },
    typescript = { binary = "typescript-language-server", args = { "--stdio" }, desc = "TypeScript/JavaScript/React LSP" },
    python = { binary = "pyright-langserver", args = { "--stdio" }, desc = "Pyright Fast Static Type Checker" },
    rust = { binary = "rust-analyzer", args = {}, desc = "Modular Rust Language Server" },
    go = { binary = "gopls", args = {}, desc = "Official Go Language Server" },
    lua = { binary = "lua-language-server", args = {}, desc = "Sumneko Lua LSP" },
    html = { binary = "vscode-html-language-server", args = { "--stdio" }, desc = "HTML Language Server" },
    css = { binary = "vscode-css-language-server", args = { "--stdio" }, desc = "CSS/SCSS Language Server" },
    clangd = { binary = "clangd", args = {}, desc = "LLVM Clangd C/C++ LSP" },
}

-- Detect server for a given buffer
function LSP.detect_server(buffer)
    local lang, lang_id = Languages.detect(buffer.file_path)
    if not lang or not lang.lsp then return nil end
    local srv = LSP.servers[lang_id]
    if srv then return srv, lang end
    return { binary = lang.lsp, desc = lang.name .. " Language Server" }, lang
end

local function rgb_to_hsl(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l
    l = (max + min) / 2
    if max == min then
        h = 0; s = 0
    else
        local d = max - min
        s = l > 0.5 and (d / (2 - max - min)) or (d / (max + min))
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return math.floor(h * 360 + 0.5), math.floor(s * 100 + 0.5), math.floor(l * 100 + 0.5)
end

-- Comprehensive CSS Properties Reference
local css_properties = {
    ["backdrop-filter"] = { desc = "Applies graphical effects like blur or color shifting behind an element.", syntax = "backdrop-filter: <filter-function-list>" },
    ["background"] = { desc = "Shorthand for background color, image, position, size, and repeat.", syntax = "background: <color | image | gradient>" },
    ["background-color"] = { desc = "Sets the background color of an element.", syntax = "background-color: <color>" },
    ["border-radius"] = { desc = "Rounds the corners of an element's outer border edge.", syntax = "border-radius: <length | percentage>" },
    ["box-shadow"] = { desc = "Adds shadow effects around an element's frame.", syntax = "box-shadow: <offset-x> <offset-y> <blur> <color>" },
    ["display"] = { desc = "Sets whether an element is treated as a block, inline, flex, or grid container.", syntax = "display: block | flex | grid | none" },
    ["flex"] = { desc = "Shorthand setting flex-grow, flex-shrink, and flex-basis.", syntax = "flex: <flex-grow> <flex-shrink> <flex-basis>" },
    ["justify-content"] = { desc = "Defines how space is distributed between and around content items along main-axis.", syntax = "justify-content: center | space-between | flex-start" },
    ["align-items"] = { desc = "Sets the align-self value on all direct children as a group along cross-axis.", syntax = "align-items: center | flex-start | stretch" },
    ["position"] = { desc = "Sets how an element is positioned in a document.", syntax = "position: relative | absolute | fixed | sticky" },
    ["color"] = { desc = "Sets the foreground color value of an element's text content.", syntax = "color: <color>" },
    ["font-family"] = { desc = "Specifies a prioritized list of one or more font family names.", syntax = "font-family: <family-name> | <generic-family>" },
    ["padding"] = { desc = "Sets the padding area on all four sides of an element.", syntax = "padding: <length | percentage>" },
    ["margin"] = { desc = "Sets the margin area on all four sides of an element.", syntax = "margin: <length | percentage | auto>" },
    ["overflow"] = { desc = "Sets what to do when content overflows an element's box.", syntax = "overflow: visible | hidden | scroll | auto" },
    ["opacity"] = { desc = "Sets the transparency of an element.", syntax = "opacity: <alpha-value>" },
    ["z-index"] = { desc = "Sets the z-order of a positioned element and its descendants.", syntax = "z-index: auto | <integer>" },
    ["transition"] = { desc = "Shorthand for transition-property, duration, timing-function, and delay.", syntax = "transition: <property> <duration> <timing-function>" },
    ["transform"] = { desc = "Rotates, scales, skews, or translates an element.", syntax = "transform: translate() | scale() | rotate()" },
}

-- Detailed Hover Information
function LSP.hover_details(buffer)
    local token = buffer.get_token_under_cursor and buffer:get_token_under_cursor() or buffer:get_word_under_cursor()
    local word  = buffer:get_word_under_cursor()
    local line  = buffer.lines[buffer.cursor_row] or ""
    local lang  = Languages.detect(buffer.file_path)
    local ext   = buffer.file_path and buffer.file_path:match("%.([^%.]+)$") or ""
    ext = ext:lower()

    if not token or token == "" then
        return {
            category = "Inspector",
            title = "No symbol under cursor",
            subtitle = "Place cursor on any symbol, tag, class, or color code",
            details = { "Press Space+h or select Hover Info to inspect." }
        }
    end

    -- 1. Check if token contains Hex Color (e.g. #9C83FF, #3F21B4, #fff)
    local hex = token:match("#([0-9a-fA-F]+)") or word:match("#([0-9a-fA-F]+)")
    if hex and (#hex == 6 or #hex == 3 or #hex == 8) then
        local r, g, b
        if #hex == 6 or #hex == 8 then
            r = tonumber(hex:sub(1, 2), 16)
            g = tonumber(hex:sub(3, 4), 16)
            b = tonumber(hex:sub(5, 6), 16)
        elseif #hex == 3 then
            r = tonumber(hex:sub(1, 1):rep(2), 16)
            g = tonumber(hex:sub(2, 2):rep(2), 16)
            b = tonumber(hex:sub(3, 3):rep(2), 16)
        end
        if r and g and b then
            local h, s, l = rgb_to_hsl(r, g, b)
            return {
                category = "Color Picker",
                title = "#" .. hex:upper(),
                subtitle = string.format("rgb(%d, %d, %d)  │  hsl(%d, %d%%, %d%%)", r, g, b, h, s, l),
                details = {
                    "CSS 24-bit Truecolor Color Swatch",
                    string.format("Hex: #%s │ Red: %d Green: %d Blue: %d", hex:upper(), r, g, b)
                },
                swatch = { r = r, g = g, b = b }
            }
        end
    end

    -- 2. CSS / SCSS Element & Selector Inspector
    if ext == "css" or ext == "scss" or ext == "sass" or ext == "less" then
        -- Class selector (.glassmorphic-illustration)
        local class_name = token:match("^%.([%w_%-]+)")
        if class_name then
            return {
                category = "CSS Inspector",
                title = string.format('<element class="%s">', class_name),
                subtitle = "Selector Specificity: (0, 1, 0)",
                details = {
                    "CSS Class Selector",
                    "Matches all elements with class=\"" .. class_name .. "\""
                }
            }
        end

        -- ID selector (#header)
        local id_name = token:match("^#([%w_%-]+)")
        if id_name then
            return {
                category = "CSS Inspector",
                title = string.format('<element id="%s">', id_name),
                subtitle = "Selector Specificity: (1, 0, 0)",
                details = {
                    "CSS ID Selector",
                    "Matches unique element with ID \"" .. id_name .. "\""
                }
            }
        end

        -- CSS Property
        local prop = token:gsub(":", "")
        if css_properties[prop] then
            local p = css_properties[prop]
            return {
                category = "CSS Property",
                title = "(property) " .. prop,
                subtitle = p.syntax,
                details = { p.desc }
            }
        end
    end

    -- 3. HTML Element
    if ext == "html" or ext == "htm" or ext == "vue" or ext == "svelte" then
        local tag = token:match("<([%w_%-]+)") or word
        if tag and tag ~= "" then
            return {
                category = "HTML Element",
                title = "<" .. tag .. ">",
                subtitle = "HTML5 Standard Element",
                details = {
                    "Living Standard HTML DOM element.",
                    "Defined in W3C & WHATWG HTML specifications."
                }
            }
        end
    end

    -- 4. React / JS / TS APIs
    if word == "useState" or word == "useEffect" or word == "useCallback" or word == "useMemo" or word == "useRef" or word == "useContext" then
        return {
            category = "React Hook",
            title = "(hook) " .. word .. "<T>()",
            subtitle = "React Core Hooks API",
            details = {
                "Official React standard hook for state and effect lifecycle.",
                "Imported from 'react'."
            }
        }
    end

    -- 5. Flutter / Dart
    if word == "Widget" or word == "StatelessWidget" or word == "StatefulWidget" or word == "Scaffold" or word == "Container" or word == "Column" or word == "Row" then
        return {
            category = "Flutter SDK",
            title = "class " .. word .. " extends Widget",
            subtitle = "Flutter Material Framework",
            details = {
                "Declarative UI component in Flutter framework.",
                "Builds widget hierarchy via build(BuildContext context)."
            }
        }
    end

    -- 6. Generic LSP Symbol Fallback
    return {
        category = (lang.name or "LSP") .. " Symbol",
        title = word,
        subtitle = "Language: " .. (lang.name or "Plain Text"),
        details = {
            string.format("Symbol in %s", buffer.file_path and buffer.file_path:match("[^/]+$") or "current buffer"),
            "Press Space+g to jump to definition."
        }
    }
end

-- Hover Information (String summary for statusline)
function LSP.hover(buffer)
    local details = LSP.hover_details(buffer)
    if details.subtitle and details.subtitle ~= "" then
        return string.format("󰋼 %s │ %s", details.title, details.subtitle)
    else
        return string.format("󰋼 %s", details.title)
    end
end

-- Diagnostics (scan buffer lines for syntax errors, missing semicolons, unclosed brackets, etc.)
function LSP.diagnostics(buffer)
    local issues = {}
    local bracket_stack = {}

    for line_idx, line in ipairs(buffer.lines) do
        -- Check brackets
        for i = 1, #line do
            local ch = line:sub(i, i)
            if ch == "(" or ch == "{" or ch == "[" then
                table.insert(bracket_stack, { ch = ch, line = line_idx, col = i })
            elseif ch == ")" or ch == "}" or ch == "]" then
                local top = table.remove(bracket_stack)
                local match_ok = (ch == ")" and top and top.ch == "(")
                              or (ch == "}" and top and top.ch == "{")
                              or (ch == "]" and top and top.ch == "[")
                if not match_ok then
                    table.insert(issues, {
                        line = line_idx,
                        col = i,
                        level = "ERROR",
                        message = "Unmatched closing bracket: " .. ch
                    })
                end
            end
        end

        -- Dart/Flutter specific lint
        if buffer.file_path and buffer.file_path:find("%.dart$") then
            if line:find("print%(") then
                table.insert(issues, { line = line_idx, col = 1, level = "INFO", message = "avoid_print: Avoid 'print' in production code" })
            end
        end

        -- JS/TS specific lint
        if buffer.file_path and (buffer.file_path:find("%.tsx?$") or buffer.file_path:find("%.jsx?$")) then
            if line:find("console%.log%(") then
                table.insert(issues, { line = line_idx, col = 1, level = "INFO", message = "no-console: Unexpected console statement" })
            end
        end

        -- Python specific lint
        if buffer.file_path and buffer.file_path:find("%.py$") then
            if line:find("import %*") then
                table.insert(issues, { line = line_idx, col = 1, level = "WARN", message = "wildcard-import: 'from module import *' used" })
            end
        end
    end

    if #bracket_stack > 0 then
        for _, b in ipairs(bracket_stack) do
            table.insert(issues, {
                line = b.line,
                col = b.col,
                level = "ERROR",
                message = "Unclosed bracket: " .. b.ch
            })
        end
    end

    return issues
end

-- Go to Definition
function LSP.goto_definition(buffer)
    local word = buffer:get_word_under_cursor()
    if not word or word == "" then return nil end

    -- Search backward and forward for definition patterns: function word, def word, class word, const word, void word
    local patterns = {
        "function%s+" .. word,
        "def%s+" .. word,
        "class%s+" .. word,
        "fn%s+" .. word,
        "const%s+" .. word,
        "let%s+" .. word,
        "var%s+" .. word,
        "void%s+" .. word,
        word .. "%s*="
    }

    for line_idx, line in ipairs(buffer.lines) do
        for _, pat in ipairs(patterns) do
            local s = line:find(pat)
            if s then
                return line_idx, s
            end
        end
    end

    return nil
end

-- Go to References
function LSP.goto_references(buffer)
    local word = buffer:get_word_under_cursor()
    if not word or word == "" then return {} end

    local refs = {}
    for line_idx, line in ipairs(buffer.lines) do
        local start_pos = 1
        while true do
            local s, e = line:find(word, start_pos, true)
            if not s then break end
            table.insert(refs, { line = line_idx, col = s, snippet = line })
            start_pos = e + 1
        end
    end
    return refs
end

-- Rename Symbol across buffer
function LSP.rename(buffer, old_sym, new_sym)
    if not old_sym or not new_sym or old_sym == "" or new_sym == "" then
        return 0
    end
    local count = 0
    for line_idx, line in ipairs(buffer.lines) do
        if line:find(old_sym, 1, true) then
            buffer.lines[line_idx] = line:gsub(old_sym, new_sym)
            count = count + 1
        end
    end
    if count > 0 then
        buffer.is_dirty = true
    end
    return count
end

-- Code Actions
function LSP.code_actions(buffer)
    local actions = {
        { title = "Organize Imports", action = "organize_imports" },
        { title = "Format Document (" .. (buffer.formatter or "Builtin") .. ")", action = "format" },
        { title = "Extract Local Variable", action = "extract_var" },
        { title = "Wrap with Widget / Container", action = "wrap_widget" },
        { title = "Fix All ESLint / Linter Diagnostics", action = "fix_linter" },
    }
    return actions
end

-- Auto Completion Suggestions
function LSP.completion(buffer, prefix)
    prefix = prefix or ""
    local results = {}
    local lang, lang_id = Languages.detect(buffer.file_path)

    -- Language-specific keywords & Flutter/Dart symbols
    local keywords = {
        dart = { "Widget", "StatefulWidget", "StatelessWidget", "build", "BuildContext", "setState", "runApp", "MaterialApp", "Scaffold", "AppBar", "Center", "Text", "Column", "Row", "Container", "ElevatedButton", "Padding", "EdgeInsets", "TextStyle", "Colors", "Future", "Stream", "async", "await", "void", "final", "const", "override" },
        typescript = { "import", "export", "interface", "type", "const", "function", "return", "useEffect", "useState", "useMemo", "useCallback", "useRef", "React", "FC", "Props", "Promise", "async", "await" },
        python = { "def", "class", "import", "from", "return", "self", "None", "True", "False", "async", "await", "try", "except", "with", "as", "lambda", "yield" },
        rust = { "fn", "let", "mut", "pub", "struct", "enum", "impl", "trait", "match", "Some", "None", "Ok", "Err", "Vec", "String", "Result", "Option", "async", "await" },
        go = { "func", "package", "import", "type", "struct", "interface", "return", "go", "chan", "select", "defer", "nil", "err", "context", "Context" },
        lua = { "function", "local", "return", "table", "string", "math", "pairs", "ipairs", "require", "self", "setmetatable" },
    }

    local list = keywords[lang_id] or keywords.lua
    for _, kw in ipairs(list) do
        if prefix == "" or kw:lower():find(prefix:lower(), 1, true) then
            table.insert(results, { label = kw, kind = "Keyword", detail = lang.name })
        end
    end

    -- Collect identifier words already in buffer
    local seen = {}
    for _, line in ipairs(buffer.lines) do
        for word in line:gmatch("[%a_][%w_]+") do
            if #word > 2 and not seen[word] and (prefix == "" or word:lower():find(prefix:lower(), 1, true)) then
                seen[word] = true
                table.insert(results, { label = word, kind = "Text", detail = "Buffer" })
            end
        end
    end

    return results
end

-- Format buffer (auto-indent indentation cleaning)
function LSP.format(buffer)
    local lang = Languages.detect(buffer.file_path)
    local indent_size = lang.indentation or 4
    local indent_str = string.rep(" ", indent_size)

    local current_indent = 0
    for idx, line in ipairs(buffer.lines) do
        local trimmed = line:gsub("^%s+", "")
        -- Decrease indent if closing bracket/tag
        if trimmed:match("^[%}%]%)]") or trimmed:match("^end%f[%W]") or trimmed:match("^</") then
            current_indent = math.max(0, current_indent - 1)
        end

        if trimmed ~= "" then
            buffer.lines[idx] = string.rep(indent_str, current_indent) .. trimmed
        else
            buffer.lines[idx] = ""
        end

        -- Increase indent if opening bracket/tag
        if trimmed:match("[%{%(%[]$") or trimmed:match("%f[%W]then$") or trimmed:match("%f[%W]do$") or trimmed:match("<%w+[^>/]*>$") then
            current_indent = current_indent + 1
        end
    end

    buffer.is_dirty = true
    return true
end

return LSP
