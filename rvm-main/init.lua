#!/usr/bin/env lua

-- ============================================================================
-- RVM 2.0 — Native Terminal Code Editor (Vim + LazyVim UX)
-- CLI entry point. Parses arguments, dispatches to App.new(target):run()
-- ============================================================================

-- Add RVM root directory to package path
local script_dir = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = script_dir .. "?.lua;" .. script_dir .. "?/init.lua;" .. package.path

local App = require("src.app")

-- ─────────────────────────────────────────────────────────
-- Version info
-- ─────────────────────────────────────────────────────────
local RVM_VERSION = "2.0.0"

local function print_version()
    print(string.format("RVM %s — Native Terminal Code Editor (Vim + LazyVim UX)", RVM_VERSION))
    print("Built with Lua + Ratatui-style TUI primitives")
    print("Default theme: terminal-native (uses your terminal emulator's colors)")
    print("Default style: lazyvim (compact, keyboard-first)")
end

-- ─────────────────────────────────────────────────────────
-- Help text — reflects the 2.0 keybinding system per spec requirement #3
-- ─────────────────────────────────────────────────────────
local function print_help()
    print([[
RVM 2.0 — Native Terminal Code Editor (Vim + LazyVim UX)

USAGE:
    rvm                      Open starter dashboard in current directory
    rvm <file>               Open or edit a specific file
    rvm <directory>          Open a project workspace directory
    rvm .                    Open current directory as project workspace
    rvm new <file>           Create and edit a new file
    rvm find                 Open fuzzy file finder (Telescope-like)
    rvm grep                 Open live grep across project
    rvm recent               Open recent files picker
    rvm buffers               Open buffer list picker
    rvm git                  Launch git workflow (lazygit if present)
    rvm terminal             Open with terminal panel visible
    rvm project <path>       Open a project (detects root, records as recent)
    rvm --version            Display version info
    rvm --help               Display this help guide
    rvm --style <name>       Override editor style for this session
    rvm --theme <name>       Override theme for this session
    rvm --no-lsp             Disable LSP for this session
    rvm --no-git             Disable Git integration for this session

PROJECT DETECTION (walks up to find):
    .git, Cargo.toml, package.json, pubspec.yaml, pyproject.toml,
    requirements.txt, go.mod, pom.xml, build.gradle, build.gradle.kts,
    CMakeLists.txt, Makefile, composer.json, Gemfile, *.sln, *.csproj

FEATURES (2.0):
    • Full Vim editing: NORMAL / INSERT / VISUAL / V-LINE / V-BLOCK /
      COMMAND / SEARCH / REPLACE modes
    • LazyVim-style <Space> leader key with two-key chords
    • Which-Key popup showing groups (f/g/b/p/l/x/t/e/w)
    • Telescope-like fuzzy finder (files, grep, buffers, recent, commands)
    • Project system: detection, root walk-up, switcher, recent projects
    • Modern file explorer: create/rename/delete/copy/move/search/reveal
    • LSP workflow: hover, definition, references, code actions, rename,
      formatting, signature help, workspace symbols
    • Git workflow: status, diff, stage, unstage, commit, push, pull,
      branch, log, blame (lazygit integration when present)
    • Multi-buffer system: bufferline, modified indicators, next/prev/pick
    • Window system: split, vsplit, resize, close, focus navigation
    • Integrated terminal: <leader>tt (no hardcoded font/colors)
    • Terminal-native default theme (uses your terminal emulator's colors)
    • 41 themes (terminal-native default + 40 existing)
    • 13 editor styles (lazyvim default + 12 existing)
    • Lua configuration: ~/.config/rvm/init.lua
    • 20+ languages: Dart, Flutter, Rust, Python, JS/TS, React, Vue,
      Svelte, Go, Java, Kotlin, C, C++, C#, PHP, Ruby, Lua, Bash,
      SQL, HTML, CSS

KEY SHORTCUTS (LazyVim-style leader chords):
    <Space>                  Open Which-Key popup
    <leader>ff               Find Files (Telescope-like)
    <leader>fg               Live Grep
    <leader>fb               Buffers
    <leader>fr               Recent Files
    <leader>fc               Commands
    <leader>e                Toggle Explorer
    <leader>pp               Project Switcher
    <leader>pd               Project Dashboard
    <leader>gg               Git Status (lazygit if present)
    <leader>gc               Git Commit
    <leader>gp               Git Push
    <leader>gl               Git Log
    <leader>la               LSP Code Action
    <leader>lr               LSP Rename
    <leader>lf               LSP Format
    <leader>lh               LSP Hover
    <leader>ld               LSP Definition
    <leader>ll               LSP References
    <leader>xx               Diagnostics Panel
    <leader>tt               Toggle Terminal
    <leader>ws               Window Split
    <leader>wv               Window VSplit
    <leader>wh/j/k/l         Focus Window (left/down/up/right)
    <leader>bd               Delete Buffer
    <leader>bo               Close Other Buffers
    <leader>w                Save File
    <leader>q                Quit
    <leader>t                Cycle Themes
    <leader>s                Cycle Styles
    <leader>u                Undo
    <leader>r                Redo

VIM EDITING (NORMAL mode):
    h j k l                  Move cursor
    w b e                    Word motions
    0 $                      Line start / end
    gg G                     First / last line
    Ctrl-u Ctrl-d            Half-page up / down
    zz zt zb                 Center / top / bottom cursor
    i I a A o O              Enter INSERT mode (variants)
    x dd D                   Delete char / line / to EOL
    cc C                     Change line / to EOL
    yy p P                   Yank / paste below / above
    u Ctrl-r                 Undo / Redo
    v V Ctrl-v               Visual / V-Line / V-Block
    R                        REPLACE mode
    : / ?                    Command / Search mode
    n N                      Next / prev search match

UNIVERSAL SHORTCUTS:
    Ctrl+S                   Save
    Ctrl+Q                   Quit
    Ctrl+F                   Find in file
    Ctrl+E                   Toggle Explorer
    Ctrl+P                   Command Palette
    Ctrl+H/J/K/L              Window focus (left/down/up/right)
    Shift+H                  Previous buffer
    Shift+L                  Next buffer

CONFIGURATION (~/.config/rvm/init.lua):

    -- vim.g.* style (per spec requirement #18)
    vim = vim or {}
    vim.g = vim.g or {}
    vim.g.mapleader = " "
    vim.g.rvm_theme = "terminal"
    vim.g.rvm_style = "lazyvim"
    vim.g.rvm_project = true
    vim.g.rvm_lsp = true
    vim.g.rvm_git = true
    vim.g.rvm_format_on_save = true
    vim.g.rvm_icons = true

See README.md for full documentation.
]])
end

-- ─────────────────────────────────────────────────────────
-- CLI flag parser
-- ─────────────────────────────────────────────────────────
-- Supports:
--   rvm                          → dashboard in cwd
--   rvm <path>                   → open file or directory
--   rvm new <file>               → create + edit new file
--   rvm find / grep / recent / buffers / git / terminal
--   rvm project <path>           → open project
--   rvm --version / --help
--   rvm --style <name> / --theme <name> / --no-lsp / --no-git
--   rvm <path> --theme <name>   → combine path + override

local function parse_args(argv)
    local opts = {
        target       = nil,
        new_file     = nil,
        style        = nil,
        theme        = nil,
        no_lsp       = false,
        no_git       = false,
        open_finder  = nil,   -- "files" | "grep" | "buffers" | "recent"
        open_git     = false,
        open_terminal= false,
        open_project = nil,
        show_help    = false,
        show_version = false,
    }

    local i = 1
    local argc = #argv
    local positional_set = false

    while i <= argc do
        local a = argv[i]
        if a == "--help" or a == "-h" then
            opts.show_help = true
        elseif a == "--version" or a == "-v" or a == "--ver" then
            opts.show_version = true
        elseif a == "--style" then
            i = i + 1
            opts.style = argv[i]
        elseif a == "--theme" then
            i = i + 1
            opts.theme = argv[i]
        elseif a == "--no-lsp" then
            opts.no_lsp = true
        elseif a == "--no-git" then
            opts.no_git = true
        elseif a == "new" or a == "ex" then
            -- rvm new <file>
            i = i + 1
            opts.new_file = argv[i] or "untitled.txt"
        elseif a == "find" or a == "files" then
            opts.open_finder = "files"
        elseif a == "grep" then
            opts.open_finder = "grep"
        elseif a == "recent" then
            opts.open_finder = "recent"
        elseif a == "buffers" or a == "ls" then
            opts.open_finder = "buffers"
        elseif a == "git" then
            opts.open_git = true
        elseif a == "terminal" or a == "term" then
            opts.open_terminal = true
        elseif a == "project" then
            i = i + 1
            opts.open_project = argv[i] or "."
        elseif a and a:sub(1, 1) == "-" and a ~= "-" then
            -- Unknown flag — ignore but warn
            io.stderr:write(string.format("rvm: unknown option '%s' (try --help)\n", a))
        elseif a and not positional_set then
            opts.target = a
            positional_set = true
        end
        i = i + 1
    end

    return opts
end

-- ─────────────────────────────────────────────────────────
-- Main entry
-- ─────────────────────────────────────────────────────────
local opts = parse_args(arg)

if opts.show_help then
    print_help()
    os.exit(0)
end

if opts.show_version then
    print_version()
    os.exit(0)
end

-- Determine the target path
local target = opts.target or opts.new_file or opts.open_project

-- Build the App
local app = App.new(target)

-- Apply session overrides from CLI flags
if opts.style then
    local Styles = require("src.styles")
    local s = Styles.get(opts.style)
    if s then
        app.style = s
        if app.filesystem then app.filesystem.is_visible = s.sidebar end
    else
        io.stderr:write(string.format("rvm: unknown style '%s'\n", opts.style))
    end
end

if opts.theme then
    local Theme = require("src.theme")
    local t = Theme.get(opts.theme)
    if t then
        app.theme = t
    else
        io.stderr:write(string.format("rvm: unknown theme '%s'\n", opts.theme))
    end
end

if opts.no_lsp and app.config then
    app.config.lsp_enabled = false
end

if opts.no_git and app.config then
    app.config.git_enabled = false
end

-- Auto-open finder/git/terminal if requested
if opts.open_finder then
    -- Defer until app:run() starts; we set a flag and let the UI pick it up.
    -- The finder needs the project root to be set, which happens in App.new.
    app._pending_finder_mode = opts.open_finder
elseif opts.open_git then
    app._pending_action = "git_status"
elseif opts.open_terminal then
    app._pending_action = "terminal_toggle"
end

-- Hook: App:run() should check these flags and dispatch the corresponding
-- action before the first frame. We monkey-patch run() to do so.
local original_run = app.run
app.run = function(self)
    if self._pending_finder_mode and self.finder then
        self.finder:open(self._pending_finder_mode, {
            cwd = self.project and self.project.root or "."
        })
    elseif self._pending_action and self.dispatch_action then
        self:dispatch_action(self._pending_action)
    end
    return original_run(self)
end

app:run()
