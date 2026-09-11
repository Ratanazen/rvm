-- lua/rvm/init.lua
-- RVM (Ratana Vim) Core Entry Point

local config = require("rvm.config")
local lang = require("rvm.language")
local commands = require("rvm.commands")
local ui = require("rvm.ui")
local health = require("rvm.health")
local utils = require("rvm.utils")
local terminal = require("rvm.terminal")

local M = {}

function M.setup(opts)
  config.setup(opts)
  terminal.setup()
  commands.setup()
end

function M.version()
  local nvim_ver = vim.version()
  local nvim_str = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)
  return {
    version = config.options.version or "2.6.0",
    engine = "Neovim v" .. nvim_str .. " (github.com/neovim/neovim)",
    binary = vim.fn.expand("$HOME/.local/bin/rvm"),
    native_binary = vim.fn.expand("$HOME/.local/bin/rvm-native"),
    repository = "https://github.com/Ratanazen/rvm.git",
    luajit = jit and jit.version or "Unknown",
    os = vim.loop.os_uname().sysname,
  }
end

function M.update()
  vim.notify(":: Updating RVM (Ratana Vim) & Lazy Plugins...", vim.log.levels.INFO, { title = "RVM Update" })
  vim.fn.jobstart({ "git", "pull" }, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("[OK] Git pull successful!", vim.log.levels.INFO, { title = "RVM Git Update" })
      else
        vim.notify("[INFO] Git pull finished (code " .. exit_code .. ")", vim.log.levels.WARN, { title = "RVM Git Update" })
      end
      local lazy_ok, lazy = pcall(require, "lazy")
      if lazy_ok then
        lazy.update({ show = true })
      end
    end,
  })
end

M.config = config
M.lang = lang
M.ui = ui
M.health = health
M.utils = utils
M.terminal = terminal
M.t = lang.t
M.set_lang = lang.set

return M

