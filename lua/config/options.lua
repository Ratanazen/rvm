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
vim.opt.guifont = "JetBrainsMono Nerd Font:h13,JetBrainsMono NF:h13,Hack Nerd Font:h13,FiraCode Nerd Font:h13,monospace:h13"
vim.opt.linespace = 2
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.cmdheight = 1
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = "eob: ,vert:│,horiz:─"
opt.formatoptions = "jcroql"
opt.grepformat = "%f:%l:%c:%m"
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep"
end
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "stack"
opt.laststatus = 3 -- Global statusline
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"
opt.mousemodel = "popup_g" -- Right click popup menu
opt.number = true
opt.pumblend = 0
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 5
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.showtabline = 2
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.timeoutlen = 300
opt.undofile = true
opt.updatetime = 200
opt.virtualedit = "block"
opt.winblend = 0
opt.winborder = "single"
opt.wrap = false

