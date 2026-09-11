-- lua/config/keymaps.lua
-- RVM Complete VS Code Keybindings Integration

local map = vim.keymap.set
local rvm_term = require("rvm.terminal")

-- 1. File & Buffer Operations
map({ "n", "v" }, "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Quick Open File (VS Code Ctrl+P)" })
map({ "n", "v" }, "<C-o>", "<cmd>Telescope find_files<cr>", { desc = "Open File (VS Code Ctrl+O)" })
map({ "i", "n", "v" }, "<C-n>", "<cmd>enew<cr>", { desc = "New File (VS Code Ctrl+N)" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File (VS Code Ctrl+S)" })
map({ "n", "v" }, "<C-S-s>", ":w ", { desc = "Save As (VS Code Ctrl+Shift+S)" })
map({ "n", "v" }, "<C-w>", "<cmd>bdelete<cr>", { desc = "Close Editor Tab (VS Code Ctrl+W)" })
map("n", "<C-S-t>", "<cmd>e #<cr>", { desc = "Reopen Closed Tab (VS Code Ctrl+Shift+T)" })
map({ "n", "i" }, "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next Tab (VS Code Ctrl+Tab)" })
map({ "n", "i" }, "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev Tab (VS Code Ctrl+Shift+Tab)" })

-- 2. Sidebar Explorer & Command Palette
map({ "n", "v" }, "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Explorer (VS Code Ctrl+B)" })
map({ "n", "v" }, "<C-S-p>", "<cmd>Telescope commands<cr>", { desc = "Command Palette (VS Code Ctrl+Shift+P)" })

-- 3. Search & Replace (Workspace & File)
map({ "n", "v" }, "<C-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search Workspace (VS Code Ctrl+Shift+F)" })
map({ "n", "v" }, "<C-S-h>", "<cmd>Telescope live_grep<cr>", { desc = "Search & Replace (VS Code Ctrl+Shift+H)" })
map("n", "<C-f>", "/", { desc = "Find in File (VS Code Ctrl+F)" })
map("n", "<C-h>", ":%s/", { desc = "Replace in File (VS Code Ctrl+H)" })

-- 4. Terminal Integration
map("n", "<leader>ft", function() rvm_term.open_root() end, { desc = "Terminal (Project Root)" })
map("n", "<leader>fT", function() rvm_term.open_cwd() end, { desc = "Terminal (CWD)" })
map({ "n", "t" }, "<C-`>", function() rvm_term.open_root() end, { desc = "Toggle Terminal (VS Code Ctrl+`)" })
map({ "n", "t" }, "<C-t>", function() rvm_term.open_root() end, { desc = "Toggle Terminal (VS Code Ctrl+T)" })
map({ "n", "t" }, "<c-/>", function() rvm_term.open_root() end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<c-_>", function() rvm_term.open_root() end, { desc = "Toggle Terminal" })

-- Terminal Mode Navigation
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal Right Window" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- 5. Window Navigation & Splitting
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("n", "<C-\\>", "<cmd>vsplit<cr>", { desc = "Split Vertically (VS Code Ctrl+\\)" })
map("n", "<C-S-\\>", "<cmd>split<cr>", { desc = "Split Horizontally (VS Code Ctrl+Shift+\\)" })

-- 6. Edit Operations
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("v", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
map("v", "<C-x>", '"+d', { desc = "Cut to clipboard" })
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })
map({ "n", "i", "v" }, "<C-a>", "<esc>ggVG", { desc = "Select All (VS Code Ctrl+A)" })

-- 7. Line Movements & Line Duplication (Alt+Up/Down & Alt+Shift+Up/Down)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Line Down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Line Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move Line Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move Line Up" })

map("n", "<A-S-Down>", "<cmd>t.<cr>", { desc = "Duplicate Line Down" })
map("n", "<A-S-Up>", "<cmd>t.-1<cr>", { desc = "Duplicate Line Up" })

-- 8. Code Navigation & Refactoring (F12, F2, QuickFix)
map("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to Definition (VS Code F12)" })
map("n", "<A-F12>", "<cmd>Telescope lsp_definitions<cr>", { desc = "Peek Definition (VS Code Alt+F12)" })
map("n", "<S-F12>", "<cmd>Telescope lsp_references<cr>", { desc = "Find All References (VS Code Shift+F12)" })
map("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename Symbol (VS Code F2)" })
map({ "n", "v" }, "<C-.>", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Quick Fix (VS Code Ctrl+.)" })
map({ "n", "v" }, "<A-CR>", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Quick Fix (VS Code Alt+Enter)" })

-- 9. Escape & Clear Search
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- 10. Standard Navigation Keys (Home, End, PageUp, PageDown, Delete)
map({ "n", "v" }, "<Home>", "0", { desc = "Line Start" })
map("i", "<Home>", "<C-o>0", { desc = "Line Start" })
map({ "n", "v" }, "<End>", "$", { desc = "Line End" })
map("i", "<End>", "<C-o>$", { desc = "Line End" })
map({ "n", "v" }, "<PageUp>", "<C-b>", { desc = "Page Up" })
map("i", "<PageUp>", "<C-o><C-b>", { desc = "Page Up" })
map({ "n", "v" }, "<PageDown>", "<C-f>", { desc = "Page Down" })
map("i", "<PageDown>", "<C-o><C-f>", { desc = "Page Down" })
map("n", "<Del>", "x", { desc = "Delete Character" })

