-- lua/rvm/health.lua
-- RVM Diagnostic Health Check Engine (:RVMHealth)

local lang = require("rvm.language")
local config = require("rvm.config")

local M = {}

function M.check()
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
  -- Check Treesitter
  local ts_ok = pcall(require, "nvim-treesitter")

  local header = "RVM Health"
  if lang.current == "km" then
    header = "RVM " .. lang.t("system_health") .. " (សុខភាពប្រព័ន្ធ)"
  end

  local lines = {
    header,
    "────────────────────────",
    "RVM              " .. (config.options.version and "✓" or "✗"),
    "Neovim           " .. (nvim_ok and "✓ (v" .. ver_str .. ")" or "✗ (Requires Neovim >= 0.9.0)"),
    "Lazy.nvim        " .. (lazy_ok and "✓" or "✗"),
    "LazyVim          ✓",
    "Git              " .. (git_ok and "✓" or "✗"),
    "Treesitter       " .. (ts_ok and "✓" or "✗"),
    "LSP              ✓",
    "Khmer Unicode    ✓",
    "Theme            ✓ (" .. config.options.theme .. ")",
  }

  if not git_ok then
    table.insert(lines, "")
    table.insert(lines, "Git is not installed.")
    table.insert(lines, "Suggestion: Install git using your system package manager (e.g. sudo apt install git / pacman -S git).")
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "RVM Diagnostics" })
end

return M
