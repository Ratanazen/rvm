local Languages = {
    -- Web
    html = {
        name = "HTML",
        syntax = true,
        lsp = "html-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "html", "htm" },
        icon = "🌐",
        theme = "RVM Ocean",
    },
    css = {
        name = "CSS",
        syntax = true,
        lsp = "css-languageserver",
        formatter = "prettier",
        indentation = 2,
        extensions = { "css" },
        icon = "🎨",
    },
    scss = {
        name = "SCSS",
        syntax = true,
        lsp = "css-languageserver",
        formatter = "prettier",
        indentation = 2,
        extensions = { "scss", "sass" },
        icon = "💅",
    },
    javascript = {
        name = "JavaScript",
        syntax = true,
        lsp = "typescript-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "js", "mjs", "cjs" },
        icon = "📜",
    },
    typescript = {
        name = "TypeScript",
        syntax = true,
        lsp = "typescript-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "ts", "mts", "cts" },
        icon = "🔷",
    },
    jsx = {
        name = "JSX",
        syntax = true,
        lsp = "typescript-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "jsx" },
        icon = "⚛️",
    },
    tsx = {
        name = "TSX",
        syntax = true,
        lsp = "typescript-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "tsx" },
        icon = "⚛️",
    },

    -- Frontend Frameworks
    react = {
        name = "React",
        syntax = true,
        lsp = "typescript-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "jsx", "tsx" },
        icon = "⚛️",
    },
    vue = {
        name = "Vue",
        syntax = true,
        lsp = "volar",
        formatter = "prettier",
        indentation = 2,
        extensions = { "vue" },
        icon = "💚",
    },
    svelte = {
        name = "Svelte",
        syntax = true,
        lsp = "svelte-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "svelte" },
        icon = "🧡",
    },

    -- Mobile
    dart = {
        name = "Dart",
        syntax = true,
        lsp = "dart",
        formatter = "dart_format",
        indentation = 2,
        extensions = { "dart" },
        icon = "🎯",
        theme = "RVM Purple",
    },
    flutter = {
        name = "Flutter",
        syntax = true,
        lsp = "dart",
        formatter = "dart_format",
        indentation = 2,
        extensions = { "dart" },
        icon = "💙",
    },

    -- Backend
    python = {
        name = "Python",
        syntax = true,
        lsp = "pyright",
        formatter = "black",
        indentation = 4,
        extensions = { "py", "pyw", "pyi" },
        icon = "🐍",
        theme = "RVM Forest",
    },
    lua = {
        name = "Lua",
        syntax = true,
        lsp = "lua-language-server",
        formatter = "stylua",
        indentation = 4,
        extensions = { "lua" },
        icon = "🌙",
    },
    go = {
        name = "Go",
        syntax = true,
        lsp = "gopls",
        formatter = "gofmt",
        indentation = 4,
        extensions = { "go" },
        icon = "🐹",
    },
    rust = {
        name = "Rust",
        syntax = true,
        lsp = "rust-analyzer",
        formatter = "rustfmt",
        indentation = 4,
        extensions = { "rs" },
        icon = "🦀",
        theme = "RVM Midnight",
    },
    java = {
        name = "Java",
        syntax = true,
        lsp = "jdtls",
        formatter = "google-java-format",
        indentation = 4,
        extensions = { "java" },
        icon = "☕",
    },
    php = {
        name = "PHP",
        syntax = true,
        lsp = "intelephense",
        formatter = "php-cs-fixer",
        indentation = 4,
        extensions = { "php" },
        icon = "🐘",
    },
    c = {
        name = "C",
        syntax = true,
        lsp = "clangd",
        formatter = "clang-format",
        indentation = 4,
        extensions = { "c", "h" },
        icon = "🅒",
    },
    cpp = {
        name = "C++",
        syntax = true,
        lsp = "clangd",
        formatter = "clang-format",
        indentation = 4,
        extensions = { "cpp", "cc", "cxx", "hpp", "hh", "hxx" },
        icon = "➕",
    },
    csharp = {
        name = "C#",
        syntax = true,
        lsp = "omnisharp",
        formatter = "dotnet-format",
        indentation = 4,
        extensions = { "cs" },
        icon = "♯",
    },
    ruby = {
        name = "Ruby",
        syntax = true,
        lsp = "solargraph",
        formatter = "rubocop",
        indentation = 2,
        extensions = { "rb", "rake" },
        icon = "💎",
    },

    -- Data & Config
    json = {
        name = "JSON",
        syntax = true,
        lsp = "vscode-json-languageserver",
        formatter = "prettier",
        indentation = 2,
        extensions = { "json" },
        icon = "📋",
    },
    yaml = {
        name = "YAML",
        syntax = true,
        lsp = "yaml-language-server",
        formatter = "prettier",
        indentation = 2,
        extensions = { "yaml", "yml" },
        icon = "⚙️",
    },
    toml = {
        name = "TOML",
        syntax = true,
        lsp = "taplo",
        formatter = "taplo",
        indentation = 2,
        extensions = { "toml" },
        icon = "📦",
    },
    xml = {
        name = "XML",
        syntax = true,
        lsp = "lemminx",
        formatter = "prettier",
        indentation = 2,
        extensions = { "xml", "svg" },
        icon = "📑",
    },
    csv = {
        name = "CSV",
        syntax = true,
        lsp = nil,
        formatter = nil,
        indentation = 2,
        extensions = { "csv", "tsv" },
        icon = "📊",
    },

    -- Database
    sql = {
        name = "SQL",
        syntax = true,
        lsp = "sqls",
        formatter = "sql-formatter",
        indentation = 4,
        extensions = { "sql" },
        icon = "🗄️",
    },

    -- Shell
    bash = {
        name = "Bash",
        syntax = true,
        lsp = "bash-language-server",
        formatter = "shfmt",
        indentation = 4,
        extensions = { "sh", "bash", "zsh" },
        icon = "🐚",
    },
    powershell = {
        name = "PowerShell",
        syntax = true,
        lsp = "powershell-editor-services",
        formatter = "powershell",
        indentation = 4,
        extensions = { "ps1", "psm1" },
        icon = "⚡",
    },

    -- Documentation
    markdown = {
        name = "Markdown",
        syntax = true,
        lsp = "marksman",
        formatter = "prettier",
        indentation = 2,
        extensions = { "md", "markdown" },
        icon = "📝",
    },
}

function Languages.detect(file_path)
    if not file_path then return Languages.markdown end
    local ext = file_path:match("%.([%w_]+)$")
    if ext then
        ext = ext:lower()
        for lang_id, lang in pairs(Languages) do
            if type(lang) == "table" and lang.extensions then
                for _, e in ipairs(lang.extensions) do
                    if e == ext then
                        return lang, lang_id
                    end
                end
            end
        end
    end
    -- Fallback for special filenames
    local fname = file_path:match("([^/\\]+)$") or file_path
    fname = fname:lower()
    if fname == "dockerfile" then return Languages.bash, "bash" end
    if fname == "makefile" then return Languages.bash, "bash" end
    if fname == "pubspec.yaml" then return Languages.yaml, "yaml" end
    if fname == "cargo.toml" then return Languages.toml, "toml" end

    return { name = "Plain Text", syntax = false, indentation = 4, icon = "📄" }, "plaintext"
end

return Languages
