-- lua/config/keymaps.lua
-- RVM Keymaps & Terminal Shortcuts

local map = vim.keymap.set

-- Terminal Navigation & Controls
local rvm_term = require("rvm.terminal")

map("n", "<leader>ft", function() rvm_term.open_root() end, { desc = "Terminal (Project Root)" })
map("n", "<leader>fT", function() rvm_term.open_cwd() end, { desc = "Terminal (CWD)" })
map({ "n", "t" }, "<c-/>", function() rvm_term.open_root() end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<c-_>", function() rvm_term.open_root() end, { desc = "Toggle Terminal" })

-- Terminal Mode Navigation (Ctrl+h/j/k/l and Esc Esc to exit insert mode)
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal Right Window" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Better Normal Mode Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize Window
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- VS Code Compatibility Shortcuts
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files (VS Code Ctrl+P)" })
map("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Explorer (VS Code Ctrl+B)" })
map("n", "<C-w>", "<cmd>bdelete<cr>", { desc = "Close Buffer (VS Code Ctrl+W)" })
