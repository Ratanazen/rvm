-- lua/config/options.lua
-- RVM Vim Options & TrueColor Terminal Palette

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Encoding (Full Khmer UTF-8 Unicode Support)
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- TrueColor Support
opt.termguicolors = true

-- RVM Cohesive Terminal TrueColor Palette (ANSI 0-15)
vim.g.terminal_color_0  = "#16171d" -- Black
vim.g.terminal_color_1  = "#f7768e" -- Red
vim.g.terminal_color_2  = "#9ece6a" -- Green
vim.g.terminal_color_3  = "#e0af68" -- Yellow
vim.g.terminal_color_4  = "#7aa2f7" -- Blue
vim.g.terminal_color_5  = "#bb9af7" -- Magenta
vim.g.terminal_color_6  = "#7dcfff" -- Cyan
vim.g.terminal_color_7  = "#a9b1d6" -- White
vim.g.terminal_color_8  = "#414868" -- Bright Black
vim.g.terminal_color_9  = "#f7768e" -- Bright Red
vim.g.terminal_color_10 = "#9ece6a" -- Bright Green
vim.g.terminal_color_11 = "#e0af68" -- Bright Yellow
vim.g.terminal_color_12 = "#7aa2f7" -- Bright Blue
vim.g.terminal_color_13 = "#bb9af7" -- Bright Magenta
vim.g.terminal_color_14 = "#7dcfff" -- Bright Cyan
vim.g.terminal_color_15 = "#c0caf5" -- Bright White

-- UI & Editor Options
vim.o.guifont = "JetBrainsMono Nerd Font:h13"
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.cmdheight = 1
opt.completeopt = "menu,menuone,noselect"
opt.cursorline = true
opt.expandtab = true
opt.fillchars = "eob: ,vert:│,horiz:─"
opt.ignorecase = true
opt.laststatus = 3 -- Global statusline
opt.mouse = "a"
opt.mousemodel = "popup_g" -- Right click popup menu
opt.number = true
opt.pumblend = 0
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.shiftwidth = 2
opt.showmode = false
opt.showtabline = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.undofile = true
opt.updatetime = 200
opt.winblend = 0
opt.winborder = "single"
opt.wrap = false
