#!/usr/bin/env bash
set -e

# RVM 3.0 installer — installs the Tri-Engine architecture
# (Neovim, Rust Native, and Nano).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ":: Installing RVM 3.0 — Tri-Engine Terminal Code Editor..."

# 1. Create target directories
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/rvm"

# 2. Make launcher executable & copy to PATH
chmod +x "$SCRIPT_DIR/rvm"
cp "$SCRIPT_DIR/rvm" "$HOME/.local/bin/rvm"

if [ "$1" = "--build-neovim" ]; then
    "$SCRIPT_DIR/scripts/build_neovim_source.sh"
fi

# 3. Fix the launcher to point to the install location
cat > "$HOME/.local/bin/rvm" <<INNER_EOF
#!/usr/bin/env bash
# RVM (Ratana Vim) — Tri-Engine Code Editor
RVM_ROOT="$SCRIPT_DIR"

if [ "\$1" = "--version" ] || [ "\$1" = "-v" ]; then
    echo "RVM (Ratana Vim) 3.0 - Tri-Engine Editor"
    echo "Engines available:"
    if [ -x "\$HOME/.local/bin/rvm-engine" ]; then
        echo "  - Neovim Engine: Installed (rvm-engine)"
    elif command -v nvim >/dev/null 2>&1; then
        echo "  - Neovim Engine: Installed (system nvim)"
    else
        echo "  - Neovim Engine: Not installed"
    fi
    if [ -x "\$HOME/.local/bin/rvm-native" ]; then
        echo "  - Rust Native Engine: Installed"
    else
        echo "  - Rust Native Engine: Not installed"
    fi
    if [ -x "\$HOME/.local/bin/rvm-nano" ]; then
        echo "  - Nano Engine: Installed"
    else
        echo "  - Nano Engine: Not installed"
    fi
    exit 0
fi

if [ "\$1" = "--nano" ]; then
    shift
    if [ -x "\$HOME/.local/bin/rvm-nano" ]; then
        exec "\$HOME/.local/bin/rvm-nano" "\$@"
    fi
fi

if [ "\$1" = "--native" ]; then
    shift
    if [ -x "\$HOME/.local/bin/rvm-native" ]; then
        exec "\$HOME/.local/bin/rvm-native" "\$@"
    fi
fi

if [ -x "\$HOME/.local/bin/rvm-engine" ]; then
    exec "\$HOME/.local/bin/rvm-engine" -u "\$RVM_ROOT/init.lua" "\$@"
elif command -v nvim >/dev/null 2>&1; then
    exec nvim -u "\$RVM_ROOT/init.lua" "\$@"
elif [ -x "\$HOME/.local/bin/rvm-native" ]; then
    exec "\$HOME/.local/bin/rvm-native" "\$@"
elif [ -x "\$HOME/.local/bin/rvm-nano" ]; then
    exec "\$HOME/.local/bin/rvm-nano" "\$@"
else
    echo "Error: No RVM engines are available on this system."
    exit 1
fi
INNER_EOF
chmod +x "$HOME/.local/bin/rvm"
ln -sf "$HOME/.local/bin/rvm" "$HOME/.local/bin/rvim"

# 4. Optional: Copy to /usr/local/bin if permissions allow
if [ -w "/usr/local/bin" ]; then
    cp "$HOME/.local/bin/rvm" /usr/local/bin/rvm
    ln -sf /usr/local/bin/rvm /usr/local/bin/rvim 2>/dev/null || true
    echo "  Installed system-wide to /usr/local/bin/rvm (alias: rvim)"
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
    echo "  [INFO] cargo not found; skipping native Rust binary"
fi

# 6. Build the Nano engine (rvn)
echo ":: Building Nano engine (rvn)..."
if [ -d "$SCRIPT_DIR/rvn" ]; then
    cd "$SCRIPT_DIR/rvn"
    if [ ! -f "Makefile" ]; then
        ./autogen.sh >/dev/null 2>&1 || true
        ./configure >/dev/null 2>&1 || true
    fi
    if make >/dev/null 2>&1; then
        if [ -f "src/rvn" ]; then
            cp src/rvn "$HOME/.local/bin/rvm-nano"
            echo "  Nano engine installed to $HOME/.local/bin/rvm-nano"
        elif [ -f "src/nano" ]; then
            cp src/nano "$HOME/.local/bin/rvm-nano"
            echo "  Nano engine installed to $HOME/.local/bin/rvm-nano"
        else
            echo "  [WARN] Nano engine binary not found after build."
        fi
    else
        echo "  [WARN] make failed for Nano engine."
    fi
else
    echo "  [WARN] rvn directory not found, skipping Nano engine."
fi

# 7. Create a default user config if missing
if [ ! -f "$HOME/.config/rvm/init.lua" ]; then
    cat > "$HOME/.config/rvm/init.lua" <<'CONFIG_EOF'
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
CONFIG_EOF
    echo "  Default config written to ~/.config/rvm/init.lua"
fi

echo ""
echo "[OK] RVM 3.0 has been installed successfully!"
echo "   Executable path: $HOME/.local/bin/rvm"
echo ""
echo "Try running:"
echo "   rvm --version"
echo "   rvm .                # Open current directory (Neovim Engine)"
echo "   rvm --native .       # Open with Rust Native Engine"
echo "   rvm --nano file.txt  # Open with Nano Engine"
echo ""
echo "Default Neovim keybindings:"
echo "   <Space>               Leader key — opens Which-Key popup"
echo "   <leader>ff            Find Files (Telescope-like)"
echo "   <leader>fg            Live Grep"
