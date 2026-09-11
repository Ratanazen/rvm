#!/usr/bin/env bash
set -e

# RVM 2.0 installer — installs both the Lua editor (default) and the
# Rust native binary (when cargo is available).
#
# Per spec requirement #19: keep existing installation scripts working.
# We make the script path-portable (no hardcoded /home/reny/RVM path).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ":: Installing RVM 2.6 — Native Terminal Code Editor (Vim + LazyVim UX)..."

# 1. Create target directories
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/rvm"

# 2. Make launcher executable & copy to PATH
chmod +x "$SCRIPT_DIR/rvm"
cp "$SCRIPT_DIR/rvm" "$HOME/.local/bin/rvm"

# 3. Fix the launcher to point to the install location
cat > "$HOME/.local/bin/rvm" <<EOF
#!/usr/bin/env bash
# RVM (Ratana Vim) — Powered by Neovim Core Engine (github.com/neovim/neovim)
RVM_ROOT="$SCRIPT_DIR"

if [ "\$1" = "--native" ]; then
    shift
    if [ -x "\$HOME/.local/bin/rvm-native" ]; then
        exec "\$HOME/.local/bin/rvm-native" "\$@"
    fi
fi

if command -v nvim >/dev/null 2>&1; then
    exec nvim -u "\$RVM_ROOT/init.lua" "\$@"
elif [ -x "\$HOME/.local/bin/rvm-native" ]; then
    exec "\$HOME/.local/bin/rvm-native" "\$@"
else
    echo "Error: Neovim (nvim) is not installed."
    exit 1
fi
EOF
chmod +x "$HOME/.local/bin/rvm"

# 4. Optional: Copy to /usr/local/bin if permissions allow
if [ -w "/usr/local/bin" ]; then
    cp "$HOME/.local/bin/rvm" /usr/local/bin/rvm
    echo "  Installed system-wide to /usr/local/bin/rvm"
fi

# 5. Build the native Rust binary if cargo is available
if command -v cargo >/dev/null 2>&1; then
    echo ":: Building native Rust binary..."
    cd "$SCRIPT_DIR"
    if cargo build --release 2>/dev/null; then
        cp target/release/rvm "$HOME/.local/bin/rvm-native" 2>/dev/null || true
        echo "  Native binary installed to $HOME/.local/bin/rvm-native"
    else
        echo "  [WARN] cargo build failed; continuing with Lua-only installation"
    fi
else
    echo "  [INFO] cargo not found; skipping native Rust binary (Lua implementation is sufficient)"
fi

# 6. Create a default user config if missing
if [ ! -f "$HOME/.config/rvm/init.lua" ]; then
    cat > "$HOME/.config/rvm/init.lua" <<'EOF'
-- RVM user configuration — see README.md for full options
-- Defaults: theme = "RVM Terminal" (terminal-native), style = "RVM LazyVim"

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
EOF
    echo "  Default config written to ~/.config/rvm/init.lua"
fi

echo ""
echo "[OK] RVM 2.6 has been installed successfully!"
echo "   Executable path: $HOME/.local/bin/rvm"
echo ""
echo "Try running:"
echo "   rvm --version"
echo "   rvm .                # Open current directory as project"
echo "   rvm main.dart         # Open a specific file"
echo "   rvm --help            # View help"
echo ""
echo "Default keybindings:"
echo "   <Space>               Leader key — opens Which-Key popup"
echo "   <leader>ff            Find Files (Telescope-like)"
echo "   <leader>fg            Live Grep"
echo "   <leader>tt            Toggle Terminal"
echo "   <leader>gg            Git Status"
echo "   :w / :q               Save / Quit"
echo ""
echo "Default theme: RVM Terminal (terminal-native — uses your terminal emulator's colors)"
echo "Default style: RVM LazyVim (compact, keyboard-first)"
