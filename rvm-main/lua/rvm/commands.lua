-- lua/rvm/commands.lua
-- RVM Commands Registry Implementation

local lang = require("rvm.language")
local config = require("rvm.config")
local health = require("rvm.health")
local ui = require("rvm.ui")

local M = {}

--- Setup user commands
function M.setup()
  vim.api.nvim_create_user_command("RVM", ui.command_center, { desc = "RVM Command Center" })
  vim.api.nvim_create_user_command("RVMHealth", health.check, { desc = "Run RVM Health Check" })
  vim.api.nvim_create_user_command("RVMVersion", function()
    local nvim_ver = vim.version()
    local ver_str = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)
    vim.notify(
      "RVM (Ratana Vim) v" .. config.options.version .. "\nNeovim Engine: v" .. ver_str .. "\nMode: " .. config.options.mode:upper(),
      vim.log.levels.INFO,
      { title = "RVM Version" }
    )
  end, { desc = "Show RVM Version" })

  vim.api.nvim_create_user_command("RVMUpdate", function()
    vim.notify("Checking Git repository & updating Lazy plugins...", vim.log.levels.INFO, { title = "RVM Update" })
    local lazy_ok, lazy = pcall(require, "lazy")
    if lazy_ok then
      lazy.update({ show = true })
    end
  end, { desc = "Update RVM components and plugins" })

  vim.api.nvim_create_user_command("RVMKhmer", function() lang.set("km") end, { desc = "Switch to Khmer" })
  vim.api.nvim_create_user_command("RVMEnglish", function() lang.set("en") end, { desc = "Switch to English" })

  vim.api.nvim_create_user_command("RVMConfig", function()
    local opts = {
      "RVM Configuration",
      "────────────────────",
      "Distribution : " .. (config.options.distribution or "Ratana Vim (RVM)"),
      "Version      : " .. (config.options.version or "2.5.0"),
      "Mode         : " .. (config.options.mode or "full"),
      "Theme        : " .. (config.options.theme or "rvm-dark"),
      "Language     : " .. (lang.current or "en"),
      "Leader       : '" .. (config.options.leader or " ") .. "'",
    }
    vim.notify(table.concat(opts, "\n"), vim.log.levels.INFO, { title = "RVM Config" })
  end, { desc = "Show RVM configuration" })

  vim.api.nvim_create_user_command("RVMDiagnostics", function()
    vim.cmd("TroubleToggle diagnostics")
  end, { desc = "Toggle RVM diagnostics panel" })
end

return M
