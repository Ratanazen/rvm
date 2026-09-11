#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NEOVIM_SRC="$SCRIPT_DIR/neovim-src"

echo ":: Building Neovim Core Engine from source code (neovim-src)..."

if [ ! -d "$NEOVIM_SRC" ]; then
    echo ":: Cloning Neovim source code..."
    git clone --depth 1 https://github.com/neovim/neovim.git "$NEOVIM_SRC"
fi

cd "$NEOVIM_SRC"
make CMAKE_BUILD_TYPE=Release -j$(nproc 2>/dev/null || echo 4)

mkdir -p "$HOME/.local/bin"
if [ -f "build/bin/nvim" ]; then
    cp build/bin/nvim "$HOME/.local/bin/rvm-engine"
    cp build/bin/nvim "$HOME/.local/bin/nvim" 2>/dev/null || true
    echo "  Neovim binary compiled and installed to $HOME/.local/bin/rvm-engine"
fi

echo "[OK] Neovim Core Engine built from source code successfully!"
