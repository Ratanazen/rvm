local Terminal = require("src.terminal")

local Syntax = {}

local languages = {
    -- Dart & Flutter
    dart = {
        keywords = {
            ["class"]=true, ["extends"]=true, ["with"]=true, ["implements"]=true,
            ["void"]=true, ["int"]=true, ["double"]=true, ["String"]=true, ["bool"]=true,
            ["List"]=true, ["Map"]=true, ["Set"]=true, ["var"]=true, ["final"]=true,
            ["const"]=true, ["static"]=true, ["late"]=true, ["required"]=true,
            ["return"]=true, ["if"]=true, ["else"]=true, ["for"]=true, ["in"]=true,
            ["while"]=true, ["do"]=true, ["switch"]=true, ["case"]=true, ["break"]=true,
            ["continue"]=true, ["default"]=true, ["async"]=true, ["await"]=true,
            ["yield"]=true, ["try"]=true, ["catch"]=true, ["finally"]=true, ["throw"]=true,
            ["new"]=true, ["this"]=true, ["super"]=true, ["override"]=true, ["import"]=true,
            ["export"]=true, ["part"]=true, ["as"]=true, ["show"]=true, ["hide"]=true,
            ["true"]=true, ["false"]=true, ["null"]=true,
            -- Flutter specific
            ["Widget"]=true, ["StatefulWidget"]=true, ["StatelessWidget"]=true,
            ["State"]=true, ["BuildContext"]=true, ["Key"]=true, ["build"]=true,
            ["setState"]=true, ["initState"]=true, ["dispose"]=true, ["runApp"]=true,
            ["MaterialApp"]=true, ["CupertinoApp"]=true, ["Scaffold"]=true, ["AppBar"]=true,
            ["Center"]=true, ["Column"]=true, ["Row"]=true, ["Container"]=true,
            ["Text"]=true, ["Icon"]=true, ["ElevatedButton"]=true, ["Padding"]=true,
            ["EdgeInsets"]=true, ["Colors"]=true, ["TextStyle"]=true, ["Future"]=true,
            ["Stream"]=true, ["Navigator"]=true, ["Theme"]=true, ["ThemeData"]=true,
        },
        comments = { "//", "/*" }
    },

    -- Rust
    rust = {
        keywords = {
            ["fn"]=true, ["let"]=true, ["mut"]=true, ["pub"]=true, ["struct"]=true,
            ["enum"]=true, ["impl"]=true, ["trait"]=true, ["type"]=true, ["where"]=true,
            ["for"]=true, ["in"]=true, ["while"]=true, ["loop"]=true, ["match"]=true,
            ["if"]=true, ["else"]=true, ["return"]=true, ["break"]=true, ["continue"]=true,
            ["as"]=true, ["use"]=true, ["mod"]=true, ["crate"]=true, ["self"]=true,
            ["Self"]=true, ["super"]=true, ["unsafe"]=true, ["async"]=true, ["await"]=true,
            ["move"]=true, ["dyn"]=true, ["ref"]=true, ["const"]=true, ["static"]=true,
            ["true"]=true, ["false"]=true, ["Some"]=true, ["None"]=true, ["Ok"]=true,
            ["Err"]=true, ["Vec"]=true, ["String"]=true, ["Option"]=true, ["Result"]=true
        },
        comments = { "//", "/*" }
    },

    -- Go
    go = {
        keywords = {
            ["func"]=true, ["package"]=true, ["import"]=true, ["type"]=true,
            ["struct"]=true, ["interface"]=true, ["map"]=true, ["chan"]=true,
            ["var"]=true, ["const"]=true, ["return"]=true, ["if"]=true, ["else"]=true,
            ["for"]=true, ["range"]=true, ["switch"]=true, ["case"]=true, ["default"]=true,
            ["select"]=true, ["go"]=true, ["defer"]=true, ["break"]=true, ["continue"]=true,
            ["nil"]=true, ["true"]=true, ["false"]=true, ["make"]=true, ["new"]=true,
            ["len"]=true, ["append"]=true, ["error"]=true, ["string"]=true, ["int"]=true,
            ["bool"]=true, ["byte"]=true
        },
        comments = { "//", "/*" }
    },

    -- Python
    python = {
        keywords = {
            ["def"]=true, ["class"]=true, ["import"]=true, ["from"]=true, ["as"]=true,
            ["return"]=true, ["if"]=true, ["elif"]=true, ["else"]=true, ["for"]=true,
            ["while"]=true, ["in"]=true, ["not"]=true, ["and"]=true, ["or"]=true,
            ["is"]=true, ["None"]=true, ["True"]=true, ["False"]=true, ["try"]=true,
            ["except"]=true, ["finally"]=true, ["raise"]=true, ["with"]=true,
            ["lambda"]=true, ["yield"]=true, ["async"]=true, ["await"]=true,
            ["pass"]=true, ["break"]=true, ["continue"]=true, ["self"]=true,
            ["print"]=true, ["len"]=true, ["range"]=true, ["str"]=true, ["int"]=true
        },
        comments = { "#" }
    },

    -- JavaScript / TypeScript / React / Vue / Svelte
    javascript = {
        keywords = {
            ["const"]=true, ["let"]=true, ["var"]=true, ["function"]=true, ["return"]=true,
            ["import"]=true, ["from"]=true, ["export"]=true, ["default"]=true, ["as"]=true,
            ["if"]=true, ["else"]=true, ["for"]=true, ["while"]=true, ["do"]=true,
            ["switch"]=true, ["case"]=true, ["break"]=true, ["continue"]=true, ["new"]=true,
            ["class"]=true, ["extends"]=true, ["this"]=true, ["super"]=true, ["async"]=true,
            ["await"]=true, ["try"]=true, ["catch"]=true, ["finally"]=true, ["throw"]=true,
            ["typeof"]=true, ["instanceof"]=true, ["null"]=true, ["undefined"]=true,
            ["true"]=true, ["false"]=true, ["NaN"]=true,
            -- TS specific
            ["interface"]=true, ["type"]=true, ["enum"]=true, ["implements"]=true,
            ["declare"]=true, ["public"]=true, ["private"]=true, ["protected"]=true,
            ["readonly"]=true, ["any"]=true, ["unknown"]=true, ["never"]=true,
            -- React specific
            ["React"]=true, ["useState"]=true, ["useEffect"]=true, ["useMemo"]=true,
            ["useCallback"]=true, ["useRef"]=true, ["useContext"]=true, ["FC"]=true
        },
        comments = { "//", "/*" }
    },

    -- Lua
    lua = {
        keywords = {
            ["local"]=true, ["function"]=true, ["end"]=true, ["return"]=true,
            ["if"]=true, ["then"]=true, ["else"]=true, ["elseif"]=true,
            ["for"]=true, ["while"]=true, ["do"]=true, ["repeat"]=true, ["until"]=true,
            ["break"]=true, ["in"]=true, ["nil"]=true, ["true"]=true, ["false"]=true,
            ["and"]=true, ["or"]=true, ["not"]=true, ["require"]=true, ["self"]=true
        },
        comments = { "--" }
    },

    -- HTML / XML
    html = {
        keywords = {
            ["html"]=true, ["head"]=true, ["body"]=true, ["div"]=true, ["span"]=true,
            ["h1"]=true, ["h2"]=true, ["h3"]=true, ["p"]=true, ["a"]=true, ["img"]=true,
            ["button"]=true, ["input"]=true, ["form"]=true, ["ul"]=true, ["li"]=true,
            ["script"]=true, ["style"]=true, ["link"]=true, ["meta"]=true, ["title"]=true,
            ["class"]=true, ["id"]=true, ["src"]=true, ["href"]=true, ["type"]=true,
            ["name"]=true, ["value"]=true, ["rel"]=true
        },
        comments = { "<!--" }
    },

    -- CSS / SCSS
    css = {
        keywords = {
            ["color"]=true, ["background"]=true, ["margin"]=true, ["padding"]=true,
            ["border"]=true, ["display"]=true, ["flex"]=true, ["grid"]=true,
            ["position"]=true, ["top"]=true, ["left"]=true, ["right"]=true, ["bottom"]=true,
            ["width"]=true, ["height"]=true, ["font-size"]=true, ["font-weight"]=true,
            ["justify-content"]=true, ["align-items"]=true, ["overflow"]=true,
            ["none"]=true, ["block"]=true, ["inline"]=true, ["auto"]=true, ["important"]=true
        },
        comments = { "/*" }
    },

    -- SQL
    sql = {
        keywords = {
            ["SELECT"]=true, ["FROM"]=true, ["WHERE"]=true, ["INSERT"]=true,
            ["UPDATE"]=true, ["DELETE"]=true, ["JOIN"]=true, ["LEFT"]=true,
            ["RIGHT"]=true, ["INNER"]=true, ["ON"]=true, ["GROUP"]=true,
            ["BY"]=true, ["ORDER"]=true, ["HAVING"]=true, ["LIMIT"]=true,
            ["OFFSET"]=true, ["CREATE"]=true, ["TABLE"]=true, ["DROP"]=true,
            ["ALTER"]=true, ["INDEX"]=true, ["PRIMARY"]=true, ["KEY"]=true,
            ["FOREIGN"]=true, ["REFERENCES"]=true, ["AND"]=true, ["OR"]=true,
            ["NOT"]=true, ["IN"]=true, ["IS"]=true, ["NULL"]=true, ["AS"]=true,
            ["select"]=true, ["from"]=true, ["where"]=true, ["insert"]=true,
            ["update"]=true, ["delete"]=true, ["join"]=true, ["table"]=true
        },
        comments = { "--" }
    },

    -- Shell (Bash/Zsh/PowerShell)
    shell = {
        keywords = {
            ["if"]=true, ["then"]=true, ["else"]=true, ["elif"]=true, ["fi"]=true,
            ["for"]=true, ["in"]=true, ["do"]=true, ["done"]=true, ["while"]=true,
            ["case"]=true, ["esac"]=true, ["echo"]=true, ["exit"]=true, ["return"]=true,
            ["local"]=true, ["export"]=true, ["source"]=true, ["function"]=true,
            ["sudo"]=true, ["cd"]=true, ["ls"]=true, ["cat"]=true, ["grep"]=true
        },
        comments = { "#" }
    },

    -- C / C++ / C# / Java
    c_family = {
        keywords = {
            ["int"]=true, ["float"]=true, ["double"]=true, ["char"]=true, ["void"]=true,
            ["bool"]=true, ["class"]=true, ["struct"]=true, ["enum"]=true, ["public"]=true,
            ["private"]=true, ["protected"]=true, ["static"]=true, ["const"]=true,
            ["return"]=true, ["if"]=true, ["else"]=true, ["for"]=true, ["while"]=true,
            ["do"]=true, ["switch"]=true, ["case"]=true, ["default"]=true, ["break"]=true,
            ["continue"]=true, ["new"]=true, ["delete"]=true, ["this"]=true, ["include"]=true,
            ["namespace"]=true, ["using"]=true, ["template"]=true, ["typename"]=true
        },
        comments = { "//", "/*" }
    },

    -- Markdown
    markdown = {
        keywords = {
            ["#"]=true, ["##"]=true, ["###"]=true, ["####"]=true,
            ["-"]=true, ["*"]=true, [">"]=true, ["```"]=true
        },
        comments = {}
    }
}

-- Map file extension to syntax profile
local ext_map = {
    dart = "dart",
    rs = "rust",
    go = "go",
    py = "python",
    js = "javascript",
    ts = "javascript",
    jsx = "javascript",
    tsx = "javascript",
    vue = "javascript",
    svelte = "javascript",
    lua = "lua",
    html = "html",
    htm = "html",
    xml = "html",
    svg = "html",
    css = "css",
    scss = "css",
    sass = "css",
    sql = "sql",
    sh = "shell",
    bash = "shell",
    zsh = "shell",
    ps1 = "shell",
    c = "c_family",
    cpp = "c_family",
    cc = "c_family",
    h = "c_family",
    hpp = "c_family",
    cs = "c_family",
    java = "c_family",
    php = "c_family",
    rb = "python",
    json = "javascript",
    yaml = "python",
    yml = "python",
    toml = "python",
    md = "markdown",
}

function Syntax.highlight_line(line, file_path, theme)
    if not line or line == "" then return "" end
    if not theme then return line end

    local ext = file_path and file_path:match("%.([^%.]+)$") or ""
    ext = ext:lower()
    local profile_id = ext_map[ext] or "lua"
    local profile = languages[profile_id] or languages.lua

    local reset = Terminal.reset_color()
    local text_color = Terminal.fg_rgb(theme.foreground[1], theme.foreground[2], theme.foreground[3])
    local kw_color   = Terminal.fg_rgb(theme.keywords[1], theme.keywords[2], theme.keywords[3])
    local str_color  = Terminal.fg_rgb(theme.strings[1], theme.strings[2], theme.strings[3])
    local num_color  = Terminal.fg_rgb(theme.numbers[1], theme.numbers[2], theme.numbers[3])
    local cmt_color  = Terminal.fg_rgb(theme.comments[1], theme.comments[2], theme.comments[3])
    local fn_color   = Terminal.fg_rgb(theme.functions[1], theme.functions[2], theme.functions[3])

    -- Markdown headings special highlighting
    if profile_id == "markdown" and line:match("^%s*#+") then
        return fn_color .. Terminal.bold() .. line .. reset
    end

    -- Check comments
    for _, cmark in ipairs(profile.comments or {}) do
        local esc_c = cmark:gsub("%-", "%%-"):gsub("%*", "%%*"):gsub("%/", "%%/")
        if line:find("^%s*" .. esc_c) then
            return cmt_color .. line .. reset
        end
    end

    -- Fast word tokenizer & highlighter
    local result = {}
    for word in line:gmatch("%S+") do
        -- 1. Check for CSS/Hex color codes (e.g. #9C83FF, #3F21B4, #fff)
        local hex = word:match("#([0-9a-fA-F]+)")
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
                local swatch = Terminal.fg_rgb(r, g, b) .. "■ " .. reset
                local colored = Terminal.fg_rgb(r, g, b) .. "#" .. hex .. reset
                local replaced = word:gsub("#" .. hex, swatch .. colored)
                table.insert(result, replaced)
            else
                table.insert(result, text_color .. word .. reset)
            end
        -- 2. CSS property with colon (e.g. "background:", "color:", "display:")
        elseif (profile_id == "css" or ext == "css" or ext == "scss") and word:match("^([%a_%-]+):$") then
            local prop = word:match("^([%a_%-]+):$")
            table.insert(result, kw_color .. prop .. reset .. text_color .. ":" .. reset)
        -- 3. CSS class selector (e.g. ".glassmorphic-illustration")
        elseif (profile_id == "css" or ext == "css" or ext == "scss") and word:match("^%.[%a_%-]") then
            table.insert(result, fn_color .. word .. reset)
        -- 4. HTML tag (e.g. "<div>", "<section", "</div>")
        elseif (profile_id == "html" or ext == "html" or ext == "htm") and word:match("^</?[%a%d_%-]+>?$") then
            table.insert(result, kw_color .. word .. reset)
        -- 5. Standard Keywords
        elseif profile.keywords and profile.keywords[word] then
            table.insert(result, kw_color .. word .. reset)
        -- 6. Quoted Strings
        elseif word:find("^[\"'].*[\"']$") then
            table.insert(result, str_color .. word .. reset)
        -- 7. Numbers
        elseif tonumber(word) or word:match("^0x%x+$") or word:match("^%d+px$") or word:match("^%d+rem$") or word:match("^%d+%%$") then
            table.insert(result, num_color .. word .. reset)
        -- 8. Function calls
        elseif word:match("[%a_][%w_]*%(") then
            table.insert(result, fn_color .. word .. reset)
        -- 9. General Text
        else
            table.insert(result, text_color .. word .. reset)
        end
    end

    if #result > 0 then
        local idx = 1
        return line:gsub("%S+", function(w)
            local res = result[idx]
            idx = idx + 1
            return res or w
        end)
    end

    return text_color .. line .. reset
end

return Syntax
