# ⚡ RVM 2.0 — Native Terminal Code Editor (Vim + LazyVim UX)

> **RVM** is a modern, blazingly fast, keyboard-first, native terminal code editor. Inspired by the elegance, speed, and workflow of Neovim + LazyVim, RVM features its own original architecture with **full Vim editing**, **LazyVim-style UX**, **modern project management**, **LSP**, **Git**, and **terminal-native colors**.

---

## 🌟 Highlights (2.0)

- **Full Vim editing system**: NORMAL / INSERT / VISUAL / V-LINE / V-BLOCK / COMMAND / SEARCH / REPLACE modes with motions (`h j k l w b e 0 $ gg G Ctrl-u Ctrl-d zz zt zb`), editing (`i I a A o O x dd D cc C yy p P u Ctrl-r`), and search (`/ ? n N`).
- **LazyVim-style leader key (`<Space>`)**: Two-character chord system with `<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fr`, `<leader>pp`, `<leader>gg`, `<leader>xx`, `<leader>ca`, `<leader>rn`, `<leader>tt`, `<leader>e`, etc.
- **Which-Key popup**: Grouped menu showing `f Find / g Git / b Buffers / p Projects / l LSP / x Diagnostics / t Terminal / e Explorer / w Window / s Search`.
- **Telescope-like fuzzy finder**: Find Files, Live Grep, Buffers, Recent Files, Commands — with fuzzy matching and live preview.
- **Project system**: First-class project detection walks up to find `.git`, `Cargo.toml`, `package.json`, `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `go.mod`, `pom.xml`, `build.gradle`, `build.gradle.kts`, `CMakeLists.txt`, `Makefile`, `composer.json`, `Gemfile`, `*.sln`, `*.csproj`. Project dashboard, project switcher, recent projects.
- **File explorer**: Modern tree explorer with create file/directory, rename, delete, copy, move, search, Git status, expand/collapse, reveal-current-file.
- **LSP workflow**: Hover, go-to-definition, references, code actions, rename, formatting, signature help, workspace symbols.
- **Git workflow**: status, diff, stage, unstage, commit, push, pull, branch, log, blame. Integrates with `lazygit` when present, falls back to native git otherwise.
- **Multi-buffer system**: Bufferline with modified indicators, next/previous buffer (`Shift-H` / `Shift-L`), buffer picker, close buffer, close other buffers.
- **Window system**: Split, vsplit, resize, close, focus navigation (`Ctrl-h/j/k/l`), equalize.
- **Integrated terminal**: `<leader>tt` toggles a bottom panel; does NOT hardcode font, font size, background, or transparency — defers to the user's terminal emulator.
- **Terminal-native theme (default)**: Uses the user's terminal emulator default foreground/background. No Catppuccin / Dracula / Tokyo Night / Nord are forced — they remain optional.
- **LazyVim style**: Compact, keyboard-first, minimal borders, information-dense, project-focused layout.
- **Lua configuration preserved**: `~/.config/rvm/init.lua` supports both the legacy `{ theme = ..., style = ... }` format and the new `vim.g.*` style (`vim.g.mapleader = " "`, `vim.g.rvm_theme = "terminal"`, `vim.g.rvm_style = "lazyvim"`, `vim.g.rvm_project = true`, `vim.g.rvm_lsp = true`, `vim.g.rvm_git = true`, `vim.g.rvm_format_on_save = true`, `vim.g.rvm_icons = true`).
- **12 editor styles + 41 themes**: All existing themes and styles remain backward-compatible.
- **20+ language support**: Dart, Flutter, Rust, Python, JavaScript, TypeScript, React, Vue, Svelte, Go, Java, Kotlin, C, C++, C#, PHP, Ruby, Lua, Bash, SQL, HTML, CSS — preserved.

---

## 🚀 Installation & Quick Start

```bash
# Lua implementation (default; just run)
./rvm                       # Open starter dashboard
./rvm .                     # Open current directory as project
./rvm main.dart             # Open a specific file

# Rust native binary (optional; build with cargo)
cargo build --release
./target/release/rvm .
```

---

## ⌨️ Keybindings (Vim + LazyVim)

### Leader key (`<Space>`)

| Chord         | Action                         |
|---------------|--------------------------------|
| `<leader>ff`  | Find Files (Telescope-like)    |
| `<leader>fg`  | Live Grep                       |
| `<leader>fb`  | Buffers                         |
| `<leader>fr`  | Recent Files                   |
| `<leader>fc`  | Commands                        |
| `<leader>fh`  | Help                            |
| `<leader>fk`  | Key Maps                        |
| `<leader>gg`  | Git Status                      |
| `<leader>gd`  | Git Diff                        |
| `<leader>gc`  | Git Commit                     |
| `<leader>gp`  | Git Push                        |
| `<leader>gl`  | Git Log                         |
| `<leader>gb`  | Git Branch                      |
| `<leader>ga`  | Git Stage All                   |
| `<leader>gu`  | Git Unstage All                 |
| `<leader>bd`  | Delete Buffer                   |
| `<leader>bo`  | Close Other Buffers              |
| `<leader>bn`  | Next Buffer                     |
| `<leader>bp`  | Previous Buffer                 |
| `<leader>bl`  | Buffer List                     |
| `<leader>pp`  | Project Switcher                |
| `<leader>pf`  | Project Files                   |
| `<leader>pg`  | Project Grep                    |
| `<leader>pr`  | Recent Projects                  |
| `<leader>pd`  | Project Dashboard               |
| `<leader>la`  | LSP Code Action                  |
| `<leader>lr`  | LSP Rename                       |
| `<leader>lf`  | LSP Format                       |
| `<leader>lh`  | LSP Hover                        |
| `<leader>ld`  | LSP Definition                   |
| `<leader>ll`  | LSP References                   |
| `<leader>ls`  | LSP Signature Help               |
| `<leader>lw`  | LSP Workspace Symbols            |
| `<leader>xx`  | Diagnostics Panel                |
| `<leader>xn`  | Next Diagnostic                  |
| `<leader>xp`  | Previous Diagnostic              |
| `<leader>tt`  | Toggle Terminal                  |
| `<leader>ws`  | Window Split (horizontal)        |
| `<leader>wv`  | Window VSplit (vertical)          |
| `<leader>wc`  | Close Window                     |
| `<leader>wo`  | Close Other Windows               |
| `<leader>wh`  | Focus Left                       |
| `<leader>wj`  | Focus Down                       |
| `<leader>wk`  | Focus Up                         |
| `<leader>wl`  | Focus Right                     |
| `<leader>w=`  | Equalize Windows                 |
| `<leader>e`   | Toggle Explorer                  |
| `<leader>w`   | Save File                        |
| `<leader>q`   | Quit                             |
| `<leader>Q`   | Force Quit                       |
| `<leader>n`   | New Buffer                       |
| `<leader>t`   | Cycle Themes                     |
| `<leader>s`   | Cycle Styles                     |
| `<leader>i`   | Toggle Icons Mode                |
| `<leader>u`   | Undo                             |
| `<leader>r`   | Redo                             |

### Vim editing

| Mode   | Keys                              | Action                          |
|--------|-----------------------------------|---------------------------------|
| NORMAL | `h j k l`                         | Move cursor                     |
| NORMAL | `w b e`                           | Word motions                    |
| NORMAL | `0 $`                            | Line start / end                |
| NORMAL | `gg G`                            | First / last line               |
| NORMAL | `Ctrl-u Ctrl-d`                  | Half-page up / down             |
| NORMAL | `zz zt zb`                        | Center / top / bottom cursor    |
| NORMAL | `i I a A o O`                     | Enter INSERT mode               |
| NORMAL | `x dd D`                          | Delete char / line / to EOL     |
| NORMAL | `cc C`                            | Change line / to EOL            |
| NORMAL | `yy p P`                          | Yank / paste                    |
| NORMAL | `u Ctrl-r`                        | Undo / Redo                     |
| NORMAL | `v V Ctrl-v`                      | Visual / V-Line / V-Block       |
| NORMAL | `R`                                | REPLACE mode                    |
| NORMAL | `: / ?`                            | Command / Search mode           |
| NORMAL | `n N`                              | Next / prev search match        |

### Universal shortcuts

| Key     | Action                 |
|---------|------------------------|
| `Ctrl-s` | Save                   |
| `Ctrl-q` | Quit                  |
| `Ctrl-f` | Find in file          |
| `Ctrl-e` | Toggle Explorer       |
| `Ctrl-p` | Command Palette       |
| `Ctrl-h/j/k/l` | Window focus   |
| `Shift-H` | Previous buffer       |
| `Shift-L` | Next buffer            |

---

## 🎨 Themes & Styles

- **Default theme**: `RVM Terminal` (terminal-native — uses your terminal emulator's colors)
- **Default style**: `RVM LazyVim` (compact, keyboard-first)
- 41 themes (40 existing + new terminal-native)
- 13 styles (12 existing + new lazyvim)

Switch themes via `:theme <name>` or `<leader>t` to cycle. Switch styles via `:RVMStyle <name>` or `<leader>s`.

---

## ⚙️ Configuration (`~/.config/rvm/init.lua`)

RVM supports both a Lua-table format and a `vim.g.*` style:

```lua
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
```

Or the legacy table format:

```lua
return {
    theme = "RVM Terminal",
    style = "RVM LazyVim",
    format_on_save = true,
    editor = { icons = { mode = "auto" } },
    explorer = { enabled = true, width = 22 },
}
```

---

## 🧩 Architecture (2.0)

```
rvm/
├── rvm                     # Shell launcher (executes lua init.lua)
├── init.lua                # CLI argument parser and entry point
├── rvm.lua                 # Top-level Lua module & public API
├── icons/                  # PNG file type and UI icon theme assets
├── src/
│   ├── app.lua             # Application runtime, buffer lifecycle, project state
│   ├── terminal.lua        # Raw mode, ANSI escape codes, and key reader
│   ├── terminal_graphics.lua # Kitty graphics protocol detection & emitter
│   ├── terminal_panel.lua  # Integrated terminal panel (no hardcoded font/colors)
│   ├── buffer.lua          # Line buffer, snapshot history (undo/redo), and text manipulation
│   ├── cursor.lua          # Viewport scrolling and cursor clamping
│   ├── filesystem.lua      # Directory scanner, tree navigation, file ops (create/rename/delete/copy/move/search)
│   ├── project.lua        # Project detection + project root walk + recent projects + switcher
│   ├── styles.lua          # 13 Editor Styles (including new "lazyvim" style)
│   ├── theme.lua           # 41 themes (including new "terminal" theme using ANSI defaults)
│   ├── syntax.lua          # Multi-language keyword & token syntax highlighter
│   ├── lsp.lua             # LSP client engine (Diagnostics, Hover, Definition, Format, Rename, Code Actions)
│   ├── plugin.lua          # Lua plugin registry and hook loader
│   ├── commands.lua        # Ex command dispatcher (:w, :q, :GitCommit, :GitPush, :ProjectSwitch, ...)
│   ├── keybindings.lua     # Leader chord dispatcher, which-key, command palette, action handlers
│   ├── search.lua          # Buffer text searching
│   ├── lazy.lua            # Lazy plugin panel viewer
│   ├── ui.lua              # Responsive ANSI renderer (terminal-native aware)
│   ├── ui_overlays.lua     # Bufferline, statusline, which-key popup, finder overlay, terminal panel, dashboard
│   ├── vim_engine.lua     # Full Vim engine (NORMAL/INSERT/VISUAL/V-LINE/V-BLOCK/COMMAND/SEARCH/REPLACE)
│   ├── whichkey.lua        # LazyVim-style Which-Key popup registry + state machine
│   ├── finder.lua          # Telescope-like fuzzy finder (files/grep/buffers/recent/commands)
│   ├── git.lua             # Git workflow (status/diff/stage/unstage/commit/push/pull/branch/log/blame + lazygit)
│   └── window.lua          # Window/split management (split/vsplit/resize/close/navigation)
└── src/config/
    ├── init.lua            # Unified config loader + vim.g.* support
    ├── editor.lua          # Editor options (line numbers, cursor, icon mode)
    ├── icons.lua           # Icon map (image assets, fallback glyphs, badge colors)
    ├── languages.lua       # 20+ language definitions, formatters, and LSPs
    ├── keymaps.lua         # Leader keymap registry
    ├── styles.lua          # Styles config
    ├── themes.lua          # Themes registry
    ├── lsp.lua             # LSP options
    └── plugins.lua         # Plugin list

# Native Rust binary (parallel implementation; build with cargo)
├── Cargo.toml              # Rust manifest (ratatui + crossterm + syntect + clap)
└── src/
    ├── main.rs             # Entry point
    ├── app.rs              # App runtime (uses Keymap + WhichKey + multi-buffer)
    ├── buffer.rs           # Text buffer with undo/redo
    ├── explorer.rs         # File explorer
    ├── bufferline.rs       # Modern bufferline + statusline renderer
    ├── keymap.rs           # Full Vim keymap dispatcher (Input → Mode → Keymap → Editor)
    ├── style.rs            # Editor styles (lazyvim/classic/minimal/vim/ide)
    ├── theme.rs            # 12 themes (terminal-native as default via Color::Reset)
    ├── terminal_theme.rs   # Terminal-native theme helpers
    ├── ui.rs               # Ratatui UI renderer (terminal-native aware)
    ├── vim.rs              # VimMode enum + Count + PendingKey
    └── whichkey.rs         # LazyVim-style Which-Key popup registry
```

---

## ✅ Backward compatibility

RVM 2.0 preserves:
- All existing themes (1-40)
- All existing styles (1-12)
- All existing language support (Dart, Flutter, Rust, Python, JS/TS, Go, Java, C/C++, PHP, Ruby, Lua, Bash, SQL, HTML, CSS, etc.)
- The Lua configuration system
- Existing ex commands (`:w`, `:q`, `:RVMStyle`, `:theme`, `:RVMIcons`, etc.)
- Installation scripts

The legacy "easy mode" is preserved but no longer the default. Users can still configure their editor to use any of the existing styles or themes via `~/.config/rvm/init.lua`.

---
