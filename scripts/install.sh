#!/usr/bin/env bash
# ==============================================================================
# RVM (Ratana Vim) — Safe Non-Destructive Installer & Migration Script
# ==============================================================================

set -e

COLOR_CYAN="\033[1;36m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_RESET="\033[0m"

echo -e "${COLOR_CYAN}RVM — Ratana Vim Neovim Distribution Installer${COLOR_RESET}"
echo "--------------------------------------------------------"

# 1. Check Neovim version
if ! command -v nvim &> /dev/null; then
    echo -e "${COLOR_RED}✘ Error: Neovim (nvim) is not installed.${COLOR_RESET}"
    echo "Please install Neovim >= 0.9.0 before installing RVM."
    exit 1
fi

NVIM_VER=$(nvim --version | head -n 1 | awk '{print $2}')
echo -e "${COLOR_GREEN}✔ Detected Neovim version: ${NVIM_VER}${COLOR_RESET}"

# 2. Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${TARGET_DIR}.backup.${TIMESTAMP}"

# 3. Non-destructive backup of existing configuration
if [ -d "$TARGET_DIR" ] || [ -f "$TARGET_DIR" ]; then
    echo -e "${COLOR_YELLOW}➜ Existing Neovim configuration detected at ${TARGET_DIR}${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}➜ Creating non-destructive backup at ${BACKUP_DIR}...${COLOR_RESET}"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    echo -e "${COLOR_GREEN}✔ Backup created successfully at ${BACKUP_DIR}${COLOR_RESET}"
fi

# 4. Install RVM
echo -e "${COLOR_CYAN}➜ Installing RVM to ${TARGET_DIR}...${COLOR_RESET}"
mkdir -p "$TARGET_DIR"
cp -r "$SCRIPT_DIR"/* "$TARGET_DIR/"

echo "--------------------------------------------------------"
echo -e "${COLOR_GREEN}✔ RVM (Ratana Vim) installation complete!${COLOR_RESET}"
echo -e "${COLOR_CYAN}Launch by running:${COLOR_RESET} nvim"
echo -e "${COLOR_CYAN}Commands inside Neovim:${COLOR_RESET}"
echo "  :RVM         - Show distribution info"
echo "  :RVMHealth   - Check environment health"
echo "  :RVMKhmer    - Switch interface to Khmer"
echo "  :RVMEnglish  - Switch interface to English"
echo "--------------------------------------------------------"
