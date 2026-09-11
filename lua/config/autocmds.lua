-- lua/config/autocmds.lua
-- RVM Auto-commands & Terminal Event Hooks

local function augroup(name)
  return vim.api.nvim_create_augroup("rvm_" .. name, { clear = true })
end

-- Responsive Terminal Resize on VimResized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("terminal_resize"),
  callback = function()
    local rvm_term_ok, rvm_term = pcall(require, "rvm.terminal")
    if rvm_term_ok then
      rvm_term.resize()
    end
  end,
})

-- Terminal Buffer Options (no line numbers, no relative numbers, no signcolumn, no winbar)
vim.api.nvim_create_autocmd({ "TermOpen", "FileType" }, {
  group = augroup("terminal_open"),
  pattern = { "*", "terminal", "toggleterm", "snacks_terminal" },
  callback = function(event)
    if vim.bo[event.buf].buftype == "terminal" or vim.bo[event.buf].filetype == "terminal" then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.scrolloff = 0
      vim.wo.winbar = ""
      vim.wo.statusline = " "
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore cursor location on BufReadPost
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit", "terminal" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].rvm_last_loc then
      return
    end
    vim.b[buf].rvm_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
