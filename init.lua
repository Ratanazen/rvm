-- init.lua
-- RVM (Ratana Vim) — Modern Neovim Distribution based on LazyVim with Khmer Support

-- Add current directory to runtimepath if running standalone
vim.opt.rtp:prepend(".")

-- Initialize RVM Core & Commands
local rvm_ok, rvm = pcall(require, "rvm")
if rvm_ok then
  rvm.setup({})
end

-- Load options, keymaps, auto-commands, and plugin manager
pcall(require, "config.options")
pcall(require, "config.keymaps")
pcall(require, "config.autocmds")
pcall(require, "config.lazy")

