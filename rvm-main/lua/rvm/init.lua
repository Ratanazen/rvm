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

M.config = config
M.lang = lang
M.ui = ui
M.health = health
M.utils = utils
M.terminal = terminal
M.t = lang.t
M.set_lang = lang.set

return M
