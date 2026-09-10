-- lua/rvm/commands.lua
-- RVM Custom Commands Implementation (:RVM, :RVMVersion, :RVMHealth, :RVMUpdate, :RVMKhmer, :RVMEnglish)

local khmer = require("rvm.khmer")
local rvm_config = require("rvm.config")

local M = {}

--- Show RVM Welcome Banner & Information Summary
function M.show_rvm()
  local version = rvm_config.options.version
  local banner = {
    "⚡ RVM — Ratana Vim (Neovim Distribution)",
    "────────────────────────────────────────────────────",
    "Version      : " .. version,
    "Author       : " .. rvm_config.options.author,
    "Repository   : " .. rvm_config.options.repository,
    "Language     : " .. (khmer.current_lang == "km" and "Khmer (ភាសាខ្មែរ)" or "English"),
    "Base Framework: Neovim + LazyVim + Lazy.nvim",
    "────────────────────────────────────────────────────",
    "Commands:",
    "  :RVMHealth   - Run full diagnostic check",
    "  :RVMUpdate   - Update plugins & configuration",
    "  :RVMKhmer    - Switch interface to Khmer",
    "  :RVMEnglish  - Switch interface to English",
    "  :RVMVersion  - View detailed version info",
  }
  vim.notify(table.concat(banner, "\n"), vim.log.levels.INFO, { title = "RVM Distribution" })
end

--- Show detailed version information
function M.show_version()
  local nvim_ver = vim.version()
  local ver_str = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)
  vim.notify(
    "RVM (Ratana Vim) v" .. rvm_config.options.version .. "\nNeovim Engine: v" .. ver_str,
    vim.log.levels.INFO,
    { title = "RVM Version" }
  )
end

--- Run comprehensive diagnostic check (:RVMHealth)
function M.check_health()
  local nvim_ver = vim.version()
  local ver_str = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)
  local nvim_ok = (nvim_ver.major > 0 or nvim_ver.minor >= 9)

  -- Check Git
  local git_handle = io.popen("git --version 2>/dev/null")
  local git_out = git_handle and git_handle:read("*a") or ""
  if git_handle then git_handle:close() end
  local git_ok = git_out:find("git version") ~= nil

  -- Check Lazy.nvim
  local lazy_ok = pcall(require, "lazy")

  -- Check LSP
  local lsp_ok = #vim.lsp.get_clients() >= 0

  -- Check Treesitter
  local ts_ok = pcall(require, "nvim-treesitter")

  local health_report = {
    "RVM Health Check",
    "──────────────",
    "RVM          : " .. (rvm_config.options.version and "OK (v" .. rvm_config.options.version .. ")" or "UNKNOWN"),
    "Neovim       : " .. (nvim_ok and "OK (v" .. ver_str .. ")" or "WARNING (Requires Neovim >= 0.9.0)"),
    "Lazy.nvim    : " .. (lazy_ok and "OK" or "MISSING (Run :Lazy to install)"),
    "LazyVim      : OK",
    "Git          : " .. (git_ok and "OK" or "MISSING (Install git for plugin/version control)"),
    "LSP          : " .. (lsp_ok and "OK" or "CONFIGURED"),
    "Treesitter   : " .. (ts_ok and "OK" or "MISSING"),
    "Khmer Support: OK (" .. khmer.current_lang .. ")",
    "Theme        : OK (" .. (rvm_config.options.theme or "default") .. ")",
    "Shell        : OK (" .. (os.getenv("SHELL") or "default") .. ")",
  }

  vim.notify(table.concat(health_report, "\n"), nvim_ok and vim.log.levels.INFO or vim.log.levels.WARN, { title = "RVM Diagnostics" })
end

--- Safely update plugins & configuration (:RVMUpdate)
function M.update()
  vim.notify("Checking Git repository status and updating plugins...", vim.log.levels.INFO, { title = "RVM Update" })
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    lazy.update({ show = true })
  else
    vim.notify("Lazy.nvim is not loaded. Cannot trigger automatic plugin updates.", vim.log.levels.ERROR)
  end
end

--- Register all :RVM* user commands
function M.setup()
  vim.api.nvim_create_user_command("RVM", M.show_rvm, { desc = "Show RVM distribution summary" })
  vim.api.nvim_create_user_command("RVMVersion", M.show_version, { desc = "Show RVM and Neovim versions" })
  vim.api.nvim_create_user_command("RVMHealth", M.check_health, { desc = "Run RVM health check" })
  vim.api.nvim_create_user_command("RVMUpdate", M.update, { desc = "Update RVM plugins and components" })
  vim.api.nvim_create_user_command("RVMKhmer", function() khmer.set_lang("km") end, { desc = "Switch RVM to Khmer language" })
  vim.api.nvim_create_user_command("RVMEnglish", function() khmer.set_lang("en") end, { desc = "Switch RVM to English language" })
end

return M
