local Project = {}

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

local function read_first_lines(path, max_lines)
    local f = io.open(path, "r")
    if not f then return "" end
    local content = {}
    for i = 1, (max_lines or 100) do
        local line = f:read("*l")
        if not line then break end
        table.insert(content, line)
    end
    f:close()
    return table.concat(content, "\n")
end

local function detect_raw(dir)
    -- 1. Flutter / Dart
    if file_exists(dir .. "pubspec.yaml") then
        local content = read_first_lines(dir .. "pubspec.yaml", 60)
        if content:find("flutter:") or file_exists(dir .. "lib/main.dart") or file_exists(dir .. "android") then
            return {
                id = "flutter",
                name = "Flutter Project",
                icon = "󰢗",
                lang = "dart",
                lsp = "dart",
                formatter = "dart_format",
                entry_point = "lib/main.dart",
                framework = "Flutter",
                desc = "Flutter Cross-Platform Application"
            }
        else
            return {
                id = "dart",
                name = "Dart Project",
                icon = "󰢗",
                lang = "dart",
                lsp = "dart",
                formatter = "dart_format",
                entry_point = "bin/main.dart",
                framework = "Dart",
                desc = "Dart Console/Package Project"
            }
        end
    end

    -- 2. React / Vue / Svelte / Node.js
    if file_exists(dir .. "package.json") then
        local pkg = read_first_lines(dir .. "package.json", 150)
        if pkg:find('"react"') or file_exists(dir .. "src/App.tsx") or file_exists(dir .. "src/App.jsx") then
            return {
                id = "react",
                name = "React Project",
                icon = "󰡨",
                lang = "typescript",
                lsp = "typescript-language-server",
                formatter = "prettier",
                entry_point = file_exists(dir .. "src/App.tsx") and "src/App.tsx" or "src/App.jsx",
                framework = "React",
                desc = "React Frontend Application"
            }
        elseif pkg:find('"vue"') or file_exists(dir .. "src/App.vue") then
            return {
                id = "vue",
                name = "Vue Project",
                icon = "󰡨",
                lang = "vue",
                lsp = "volar",
                formatter = "prettier",
                entry_point = "src/App.vue",
                framework = "Vue",
                desc = "Vue 3 Component Application"
            }
        elseif pkg:find('"svelte"') or file_exists(dir .. "src/App.svelte") then
            return {
                id = "svelte",
                name = "Svelte Project",
                icon = "󰡨",
                lang = "svelte",
                lsp = "svelte-language-server",
                formatter = "prettier",
                entry_point = "src/App.svelte",
                framework = "Svelte",
                desc = "Svelte Cybernetically Enhanced App"
            }
        else
            return {
                id = "nodejs",
                name = "Node.js Project",
                icon = "󰏖",
                lang = "javascript",
                lsp = "typescript-language-server",
                formatter = "prettier",
                entry_point = "index.js",
                framework = "Node.js",
                desc = "Node.js JavaScript/TypeScript Project"
            }
        end
    end

    -- 3. Rust
    if file_exists(dir .. "Cargo.toml") then
        return {
            id = "rust",
            name = "Rust Project",
            icon = "󱘗",
            lang = "rust",
            lsp = "rust-analyzer",
            formatter = "rustfmt",
            entry_point = "src/main.rs",
            framework = "Cargo",
            desc = "Rust Safe Systems Application"
        }
    end

    -- 4. Go
    if file_exists(dir .. "go.mod") then
        return {
            id = "go",
            name = "Go Project",
            icon = "󰟓",
            lang = "go",
            lsp = "gopls",
            formatter = "gofmt",
            entry_point = "main.go",
            framework = "Go Modules",
            desc = "Go High-Concurrency Service"
        }
    end

    -- 5. Python
    if file_exists(dir .. "pyproject.toml") or file_exists(dir .. "requirements.txt") or file_exists(dir .. "setup.py") then
        return {
            id = "python",
            name = "Python Project",
            icon = "󰌠",
            lang = "python",
            lsp = "pyright",
            formatter = "black",
            entry_point = file_exists(dir .. "main.py") and "main.py" or "app.py",
            framework = "Python",
            desc = "Python Application / Data Pipeline"
        }
    end

    -- 6. Java
    if file_exists(dir .. "pom.xml") or file_exists(dir .. "build.gradle") then
        return {
            id = "java",
            name = "Java Project",
            icon = "󰬷",
            lang = "java",
            lsp = "jdtls",
            formatter = "google-java-format",
            entry_point = "src/main/java",
            framework = file_exists(dir .. "pom.xml") and "Maven" or "Gradle",
            desc = "Java Enterprise / JVM Project"
        }
    end

    -- 7. C / C++
    if file_exists(dir .. "CMakeLists.txt") or file_exists(dir .. "Makefile") then
        local is_cpp = file_exists(dir .. "main.cpp") or file_exists(dir .. "src/main.cpp")
        return {
            id = is_cpp and "cpp" or "c",
            name = is_cpp and "C++ Project" or "C Project",
            icon = "󰙲",
            lang = is_cpp and "cpp" or "c",
            lsp = "clangd",
            formatter = "clang-format",
            entry_point = is_cpp and "main.cpp" or "main.c",
            framework = file_exists(dir .. "CMakeLists.txt") and "CMake" or "Make",
            desc = "C/C++ High Performance Codebase"
        }
    end

    -- 8. PHP
    if file_exists(dir .. "composer.json") then
        return {
            id = "php",
            name = "PHP Project",
            icon = "󰌟",
            lang = "php",
            lsp = "intelephense",
            formatter = "php-cs-fixer",
            entry_point = "index.php",
            framework = "Composer",
            desc = "PHP Web Application"
        }
    end

    -- 9. Ruby
    if file_exists(dir .. "Gemfile") then
        return {
            id = "ruby",
            name = "Ruby Project",
            icon = "󰴭",
            lang = "ruby",
            lsp = "solargraph",
            formatter = "rubocop",
            entry_point = "app.rb",
            framework = "Bundler",
            desc = "Ruby / Rails Application"
        }
    end

    -- 10. Static Web / HTML
    if file_exists(dir .. "index.html") then
        return {
            id = "html",
            name = "Web HTML/CSS Project",
            icon = "󰖟",
            lang = "html",
            lsp = "html-language-server",
            formatter = "prettier",
            entry_point = "index.html",
            framework = "Vanilla Web",
            desc = "Static Web Frontend Workspace"
        }
    end

    -- General directory
    return {
        id = "general",
        name = "Workspace Directory",
        icon = "󰉋",
        lang = "plaintext",
        lsp = nil,
        formatter = nil,
        entry_point = nil,
        framework = "RVM Workspace",
        desc = "Standard File Directory"
    }
end

-- ─────────────────────────────────────────────────────────
-- Project root markers — per spec requirement #5
-- Priority: .git → framework/language root → current dir
-- ─────────────────────────────────────────────────────────
Project.ROOT_MARKERS = {
  ".git",
  "Cargo.toml",
  "package.json",
  "pubspec.yaml",
  "pyproject.toml",
  "requirements.txt",
  "go.mod",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "CMakeLists.txt",
  "Makefile",
  "composer.json",
  "Gemfile",
  -- *.sln / *.csproj handled separately (glob)
}

-- Walk up from `dir` until we find a root marker. Returns the root dir.
function Project.find_root(dir)
  dir = dir or "."
  -- Resolve absolute path
  local abs = dir
  if abs == "." then
    abs = os.getenv("PWD") or io.popen("pwd"):read("*l") or "."
  end
  abs = abs:gsub("/+$", "")

  local cursor = abs
  for _ = 1, 32 do  -- up to 32 levels
    -- Check each marker
    for _, marker in ipairs(Project.ROOT_MARKERS) do
      local candidate = cursor .. "/" .. marker
      local f = io.open(candidate, "r")
      if f then f:close(); return cursor .. "/" end
    end
    -- Glob for *.sln and *.csproj
    local sln_handle = io.popen("ls " .. cursor:gsub("'", "'\\''") .. "/*.sln 2>/dev/null")
    if sln_handle then
      local line = sln_handle:read("*l")
      sln_handle:close()
      if line and line ~= "" then return cursor .. "/" end
    end
    local csproj_handle = io.popen("ls " .. cursor:gsub("'", "'\\''") .. "/*.csproj 2>/dev/null")
    if csproj_handle then
      local line = csproj_handle:read("*l")
      csproj_handle:close()
      if line and line ~= "" then return cursor .. "/" end
    end

    -- Walk up one level
    local parent = cursor:match("^(.*)/[^/]+$") or ""
    if parent == "" or parent == cursor then
      break
    end
    cursor = parent
  end

  -- Fallback: return original dir
  return dir
end

-- ─────────────────────────────────────────────────────────
-- Recent projects persistence
-- File: ~/.config/rvm/projects.json (simple plain text format)
-- ─────────────────────────────────────────────────────────
local function recent_path()
  local home = os.getenv("HOME") or ""
  if home == "" then return nil end
  return home .. "/.config/rvm/projects.txt"
end

function Project.recent_list()
  local path = recent_path()
  if not path then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local out = {}
  for line in f:lines() do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed ~= "" then
      table.insert(out, trimmed)
    end
  end
  f:close()
  return out
end

function Project.recent_add(path)
  if not path or path == "" then return end
  local recent_path = recent_path()
  if not recent_path then return end
  local current = Project.recent_list()
  -- De-dup
  for i, p in ipairs(current) do
    if p == path then table.remove(current, i); break end
  end
  table.insert(current, 1, path)
  -- Cap at 20 entries
  while #current > 20 do table.remove(current, #current) end
  -- Ensure directory exists
  os.execute("mkdir -p " .. (recent_path:match("(.*/)[^/]+$") or "/tmp/"):gsub("'", "'\\''"))
  local f = io.open(recent_path, "w")
  if f then
    for _, p in ipairs(current) do
      f:write(p .. "\n")
    end
    f:close()
  end
end

-- ─────────────────────────────────────────────────────────
-- Project switcher
-- Returns a list of projects for the finder (recent + visible sub-dirs of cwd)
-- ─────────────────────────────────────────────────────────
function Project.list_for_switcher(cwd)
  cwd = cwd or "."
  local out = {}
  -- Add recent projects
  for _, p in ipairs(Project.recent_list()) do
    table.insert(out, { path = p, name = p:match("([^/\\]+)$") or p, source = "recent" })
  end
  -- Add sub-directories that look like projects
  local h = io.popen("ls -d " .. cwd:gsub("'", "'\\''") .. "/*/ 2>/dev/null")
  if h then
    for line in h:lines() do
      local trimmed = line:gsub("^%s+", ""):gsub("/$", "")
      local name = trimmed:match("([^/\\]+)$") or trimmed
      table.insert(out, { path = trimmed, name = name, source = "workspace" })
    end
    h:close()
  end
  return out
end

-- ─────────────────────────────────────────────────────────
-- Dashboard data
-- ─────────────────────────────────────────────────────────
function Project.dashboard_data(cwd)
  local root = Project.find_root(cwd)
  local info = Project.detect(root)
  return {
    root = root,
    info = info,
    recent = Project.recent_list(),
    git_branch = info.git_branch,
  }
end

-- ─────────────────────────────────────────────────────────
-- Public API (existing)
-- ─────────────────────────────────────────────────────────
function Project.detect(dir)
    dir = dir or "."
    -- First, find the project root (walk up for .git / Cargo.toml / etc.)
    local root = Project.find_root(dir)
    if root and root ~= dir and root:sub(-1) == "/" then root = root end

    -- Use the detected root for project type detection
    local detect_dir = root
    if detect_dir:sub(-1) ~= "/" then detect_dir = detect_dir .. "/" end

    local proj = detect_raw(detect_dir)
    proj.root = detect_dir

    -- Detect git branch & status
    local b_handle = io.popen("git -C '" .. detect_dir .. "' branch --show-current 2>/dev/null")
    if b_handle then
        local b_name = b_handle:read("*a")
        b_handle:close()
        if b_name and b_name ~= "" then
            proj.git_branch = b_name:gsub("%s+", "")
        end
    end

    return proj
end

return Project
