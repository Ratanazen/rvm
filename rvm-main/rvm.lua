local Config = require("src.config.init")
local Theme  = require("src.theme")
local Styles = require("src.styles")
local LSP    = require("src.lsp")
local Plugin = require("src.plugin")

local rvm = {}

rvm.config = Config

-- Modular config references
rvm.editor = Config.editor
rvm.languages = Config.languages
rvm.keymaps = Config.keymaps
rvm.themes = Config.themes
rvm.styles = Config.styles
rvm.lsp = Config.lsp
rvm.plugins = Config.plugins

-- Setup function for user configuration
function rvm.setup(opts)
    Config.merge(opts)
    return rvm
end

-- Support require("rvm.config.editor") etc. via package.preload
package.preload["rvm.config.editor"] = function() return Config.editor end
package.preload["rvm.config.languages"] = function() return Config.languages end
package.preload["rvm.config.keymaps"] = function() return Config.keymaps end
package.preload["rvm.config.themes"] = function() return Config.themes end
package.preload["rvm.config.styles"] = function() return Config.styles end
package.preload["rvm.config.plugins"] = function() return Config.plugins end
package.preload["rvm.config.lsp"] = function() return Config.lsp end

return rvm
