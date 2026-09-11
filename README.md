# RVM — Ratana Vim

> **RVM (Ratana Vim)** is a modern, professional, Khmer-friendly Neovim distribution powered by the **Neovim Core Engine** (`github.com/neovim/neovim`), **LazyVim**, and **lazy.nvim**.

---

## 🚀 Local Run Guide (Quickstart)

After running `./install.sh`, `rvm` is available globally on your computer at `~/.local/bin/rvm`.

### Common Commands:

```bash
# 1. Open current directory as a project in RVM
rvm .

# 2. Open a specific file
rvm main.rb

# 3. Check installed RVM and Neovim engine versions
rvm --version

# 4. Run standalone Rust TUI fallback editor
rvm --native

# 5. Re-run local installation & build updates
./install.sh
```

---

## ✨ Features

- **Full Neovim Core Engine Integration (`github.com/neovim/neovim`)**: Powered directly by Neovim `v0.12+` runtime with LuaJIT 2.1.
- **First-Class Khmer Localization (`:RVMKhmer` / `:RVMEnglish`)**: Built-in translation engine supporting both Khmer (`km`) and English (`en`) interface languages with fallback protection (`ធម្មតា`, `បញ្ចូល`, `មើលឃើញ`, `ពាក្យបញ្ជា`, `រក្សាទុក`, `បើក`, `ស្វែងរក`).
- **Distribution API & User Commands**:
  - `require("rvm").version()` / `:RVMVersion`: Displays distribution version, Neovim engine, system paths, and LuaJIT info.
  - `require("rvm").update()` / `:RVMUpdate`: Automatically pulls latest Git repository commits and updates Lazy plugins.
  - `:RVMGitStatus`: Launches full terminal Git workflow.
- **Integrated Telescope & Neo-tree Navigation**: Single-click mouse file opening, `<leader>ff` (Find Files), `<leader>fg` (Live Grep), `<leader>fr` (Recent Files), `<leader>fb` (Buffers), `<leader>e` (Explorer).
- **VS Code & Vim Dual Keybindings**: Full VS Code shortcuts (`Ctrl+P`, `Ctrl+B`, `Ctrl+Shift+F`, `Ctrl+T`, `Ctrl+W`, `Ctrl+S`, `Ctrl+Z`, `Ctrl+Y`, `Ctrl+A`, `Ctrl+C`, `Ctrl+V`, `Alt+Up/Down`, `Alt+Shift+Up/Down`, `F12`, `F2`) alongside standard Vim navigation (`Home`, `End`, `PageUp`, `PageDown`, `Delete`).
- **Complete Git Signs & LazyGit Integration**: Gutter indicators (`│`, `_`, `~`), real-time inline line blame, hunk navigation (`]h`, `[h`), diff splits (`<leader>gd`), and LazyGit (`<leader>gg`).
- **Ruby & Rails Development Environment**: Pre-configured `ruby_lsp`, `vim-rails` shortcuts (`rf`, `rc`, `rs`, `rt`, `rm`, `rr`), RuboCop formatting via `conform.nvim` (`<leader>cf`), `nvim-dap-ruby` debugging (`<leader>db`, `<leader>dc`), and RSpec/Minitest testing via `neotest`.
- **Integrated Floating & Bottom Terminal (`<leader>ft` / `<leader>tt`)**: Powered by `snacks.nvim` using your native shell (`bash`/`zsh`/`fish`).
- **Flat Technical UI**: Single-line borders (`border = "single"`), zero emojis, margin/padding (`scrolloff = 5`, `sidescrolloff = 8`, `pumheight = 10`), and font fallbacks (`JetBrainsMono Nerd Font:h13`).

---

## 📦 Installation & Setup

### Recommended Local Installer

To update or install RVM on your computer:

```bash
./install.sh
```

The script automatically:
1. Installs the main `rvm` launcher to `~/.local/bin/rvm`.
2. Compiles the native Rust TUI binary to `~/.local/bin/rvm-native`.
3. Creates default configuration at `~/.config/rvm/init.lua`.

---

## 🛠️ User API & Commands

| Command / API | Action |
|---------------|--------|
| `:RVM` | Opens RVM Command Center |
| `:RVMVersion` | Displays RVM version, Neovim engine, binary paths, and LuaJIT info |
| `:RVMUpdate` | Pulls Git updates and updates all Lazy plugins |
| `:RVMGitStatus` | Opens LazyGit terminal workflow (`<leader>gg`) |
| `:RVMHealth` | Runs complete environment diagnostic check |
| `:RVMKhmer` | Switches interface language to Khmer (`km`) |
| `:RVMEnglish` | Switches interface language to English (`en`) |
| `require("rvm").version()` | Lua API returning RVM system status table |
| `require("rvm").update()` | Lua API triggering git pull and plugin update |

---

## ⌨️ Keybindings Reference

### VS Code & Navigation Shortcuts

| Keybinding | Action |
|------------|--------|
| `Ctrl+P` / `Ctrl+O` | Quick Open File (Telescope) |
| `Ctrl+B` | Toggle File Explorer (Neo-tree) |
| `Ctrl+Shift+F` | Search Workspace (Live Grep) |
| `Ctrl+S` | Save File |
| `Ctrl+W` | Close Buffer |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |
| `Ctrl+A` | Select All |
| `Ctrl+C` / `Ctrl+V` | Copy / Paste Clipboard |
| `Home` / `End` | Jump to Start / End of Line |
| `PageUp` / `PageDown` | Scroll Page Up / Down |
| `Delete` | Delete Character Forward |
| `F12` | Go to Definition |
| `F2` | Rename Symbol |
| `Alt+Up` / `Alt+Down` | Move Line Up / Down |
| `Alt+Shift+Up` / `Alt+Shift+Down` | Duplicate Line Up / Down |

### Git Keybindings

| Keybinding | Action |
|------------|--------|
| `<leader>gg` | Open LazyGit Interface |
| `<leader>gG` | Open LazyGit for Current File |
| `<leader>gbt` | Toggle Line Blame |
| `<leader>gbl` | Full Line Blame |
| `<leader>ghp` | Preview Hunk |
| `<leader>ghs` | Stage Hunk |
| `<leader>ghr` | Reset Hunk |
| `<leader>gd` | Git Diff Split |
| `]h` / `[h` | Jump to Next / Previous Git Hunk |

---

## 📄 License

RVM (Ratana Vim) is licensed under the MIT License.
