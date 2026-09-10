# ⚡ RVM — Ratana Vim

> **RVM (Ratana Vim)** is a modern, high-performance, Khmer-friendly Neovim distribution built on top of **LazyVim**, **Neovim**, and **lazy.nvim**.

---

## 🌟 Features

- **LazyVim Base & Plugin Architecture**: Full LazyVim keymaps, plugin management, and UI layout while retaining RVM's unique distribution identity.
- **First-Class Khmer Localization (`:RVMKhmer` / `:RVMEnglish`)**: Built-in translation engine supporting both Khmer (`km`) and English (`en`) interface languages with fallback protection.
- **RVM Distribution Commands**: `:RVM`, `:RVMVersion`, `:RVMHealth`, `:RVMUpdate`, `:RVMKhmer`, `:RVMEnglish`.
- **Integrated Telescope & Neo-tree Navigation**: `<leader>ff` (Find Files), `<leader>fg` (Live Grep), `<leader>fr` (Recent Files), `<leader>fb` (Buffers), `<leader>e` (Explorer).
- **VS Code & Vim/LazyVim Dual Keybindings**: Native support for VS Code shortcuts (`Ctrl+P`, `Ctrl+B`, `Ctrl+Shift+F`, `Ctrl+T`, `Ctrl+W`, `Ctrl+S`, `Ctrl+Z`, `Ctrl+Y`) alongside full Vim modes.
- **Git signs & LazyGit Workflow (`<leader>gg` / `gg`)**: Buffer gutter indicators, blame, diffs, and integrated LazyGit terminal popup.
- **Integrated Floating & Bottom Terminal (`<leader>ft` / `<leader>tt`)**: Powered by `toggleterm.nvim` using your native shell (`zsh`/`bash`/`fish`).
- **LSP & Multi-Language Support (18+ Languages)**: Pre-configured LSPs, Treesitter syntax highlighting, autocompletion (`nvim-cmp`), and formatters (`conform.nvim`) for Lua, Python, JS, TS, Rust, Go, C, C++, Java, Kotlin, Bash, SQL, HTML, CSS, Markdown, JSON, YAML.
- **RVM Visual Identity & OneDark / TokyoNight Themes**: Sleek dark mode with customizable floating windows, statusline, and theme fallbacks.

---

## 📸 Screenshots Placeholder

```
+-----------------------------------------------------------------------+
|  ⚡ RVM 2.5 — Ratana Vim [NORMAL]  .vimrc                             |
|  📁 Explorer    |  1  set nocompatible                               |
|  ▶ .config/     |  2  set number                                     |
|  ▶ lua/         |  3  colorscheme tokyonight                         |
|  📄 init.lua    |  4  set laststatus=3                               |
|                 |-----------------------------------------------------|
|                 | 💻 TERMINAL: rvm .                                 |
|                 | ✔ [RVM Session Active] Health: OK                  |
+-----------------------------------------------------------------------+
```

---

## 📋 Requirements

- **Neovim** >= `v0.9.0` (Recommended `v0.10+` or `v0.12+`)
- **Git** >= `2.19.0`
- **Nerd Font** (Optional, recommended for file icons)
- **C Compiler** (`gcc` or `clang` for Treesitter parsers)
- **rg (ripgrep)** & **fd** (Optional, for fast Telescope grep)

---

## 🚀 Installation

### Automated Safe Installer (Recommended)

Run the safe, non-destructive installation script:

```bash
./scripts/install.sh
```

> **Note**: The installer automatically creates a timestamped backup of your existing configuration at `~/.config/nvim.backup.<timestamp>` before applying RVM.

### Manual Installation

```bash
# Backup existing Neovim config
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Clone RVM to Neovim config directory
git clone https://github.com/Ratanazen/rvm.git ~/.config/nvim

# Launch RVM
nvim
```

---

## 🚀 First Launch

Launch Neovim normally:

```bash
nvim
```

On first launch, `lazy.nvim` will automatically download and set up all plugins in the background.

---

## 🇰🇭 Khmer Mode

RVM includes first-class Khmer localization:

- Switch to Khmer interface: `:RVMKhmer` or press `<leader>K`
- Switch back to English interface: `:RVMEnglish`

Translated elements include statusline modes (`ធម្មតា`, `បញ្ចូល`, `មើលឃើញ`), file operations (`រក្សាទុក`, `បើក`, `ស្វែងរក`), diagnostics, and commands.

---

## ⚙️ RVM Commands

| Command | Action |
|---------|--------|
| `:RVM` | Displays RVM welcome banner, version, and features summary |
| `:RVMVersion` | Prints detailed Neovim and RVM component versions |
| `:RVMHealth` | Runs full environment diagnostic check |
| `:RVMUpdate` | Safely updates plugins via `lazy.nvim` & git status |
| `:RVMKhmer` | Switches interface language to Khmer (`km`) |
| `:RVMEnglish` | Switches interface language to English (`en`) |

---

## ⌨️ Keymaps

### LazyVim Leader Shortcuts (`<Space>`)

| Keymap | Action |
|--------|--------|
| `<space>ff` | Find Files (Telescope) |
| `<space>fg` | Live Grep |
| `<space>fb` | Buffers List |
| `<space>fr` | Recent Files |
| `<space>e` | Toggle Neo-tree Explorer |
| `<space>gg` | LazyGit Interface |
| `<space>ft` | Toggle Floating Terminal |
| `<space>tt` | Toggle Bottom Terminal |
| `<space>lf` | Format Buffer (LSP / Conform) |
| `<space>xx` | Diagnostics Panel (Trouble) |
| `<space>K` | Toggle Khmer / English Language |

### VS Code Shortcuts (CLI Terminal)

| VS Code Shortcut | RVM Action |
|------------------|------------|
| `Ctrl+P` | Find Files |
| `Ctrl+B` | Toggle File Explorer |
| `Ctrl+Shift+F` | Search in Workspace |
| `Ctrl+T` / `Ctrl+\`` | Toggle Terminal |
| `Ctrl+W` | Close Buffer |
| `Ctrl+S` | Save File |
| `Ctrl+Z` / `Ctrl+Y` | Undo / Redo |

---

## 🔌 Plugins

RVM includes modern Neovim plugins managed via `lazy.nvim`:
- **LazyVim / LazyVim**: Base distribution framework
- **folke/tokyonight.nvim**: Primary dark theme
- **nvim-telescope/telescope.nvim**: Fuzzy finder
- **nvim-neo-tree/neo-tree.nvim**: Workspace file tree
- **folke/which-key.nvim**: Interactive leader menu popup
- **nvim-lualine/lualine.nvim**: Global statusline with Khmer mode indicator
- **akinsho/bufferline.nvim**: Buffer tabs line
- **nvim-treesitter/nvim-treesitter**: Syntax parser & highlighter
- **hrsh7th/nvim-cmp**: Autocompletion engine
- **neovim/nvim-lspconfig**: LSP server manager
- **stevearc/conform.nvim**: Formatter
- **kdheepak/lazygit.nvim**: LazyGit integration
- **akinsho/toggleterm.nvim**: Integrated shell terminal

---

## 🛠️ LSP & Language Support

Pre-configured language servers and tools:
- **Lua**: `lua-language-server`, `stylua`
- **Python**: `pyright`, `black`, `isort`
- **JavaScript / TypeScript**: `ts_ls`, `prettier`
- **Rust**: `rust-analyzer`, `rustfmt`
- **Go**: `gopls`, `gofmt`
- **C / C++**: `clangd`
- **Bash**: `bashls`

---

## 🌿 Git Integration

- Buffer gutter diff signs via `gitsigns.nvim`
- Hunk navigation: `]h` (Next hunk), `[h` (Prev hunk)
- Line blame: `<leader>ghb`
- Full LazyGit terminal interface: `<leader>gg`

---

## 💻 Terminal

- Floating Terminal: `<leader>ft`
- Bottom Terminal Panel: `<leader>tt`
- Uses your environment's `$SHELL` (`zsh`, `bash`, or `fish`).

---

## 🛠️ Troubleshooting

If you encounter startup issues:
1. Run `:RVMHealth` to check environment diagnostic status.
2. Run `:Lazy` to inspect plugin installation state.
3. Check Neovim version with `nvim --version` (must be >= `v0.9.0`).

---

## 🤝 Contributing

Contributions to RVM and Khmer localization are welcome! Please open issues or pull requests on [GitHub](https://github.com/Ratanazen/rvm.git).

---

## 📄 License

RVM is licensed under the MIT License.
