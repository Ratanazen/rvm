-- lua/rvm/init.lua
-- RVM Core framework entry point

local khmer = require("rvm.khmer")
local rvm_config = require("rvm.config")
local rvm_commands = require("rvm.commands")

local M = {}

function M.setup(opts)
  rvm_config.setup(opts)
  rvm_commands.setup()
end

M.t = khmer.t
M.set_lang = khmer.set_lang

return M
