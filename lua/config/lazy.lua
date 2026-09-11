-- lua/config/lazy.lua
-- RVM Lazy.nvim and LazyVim Base Integration

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- Bootstrap lazy.nvim if missing
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local lazy_ok, lazy = pcall(require, "lazy")
if lazy_ok then
  lazy.setup({
    spec = {
      -- Import LazyVim plugins
      { "LazyVim/LazyVim", import = "lazyvim.plugins" },
      -- Import RVM custom plugin specifications
      { import = "plugins" },
    },
    defaults = {
      lazy = false,
      version = false, -- always use the latest git commit
    },
    install = { colorscheme = { "tokyonight", "catppuccin", "habamax" } },
    checker = { enabled = false }, -- don't check for updates on startup automatically
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
end
