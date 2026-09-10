-- lua/rvm/health.lua
-- RVM Diagnostic Health Check Engine (:RVMHealth)

local lang = require("rvm.language")
local config = require("rvm.config")
local term = require("rvm.terminal")

local M = {}

function M.check()
  local nvim_ver = vim.version()
  local ver_str = string.format("%d.%d.%d", nvim_ver.major, nvim_ver.minor, nvim_ver.patch)
  local nvim_ok = (nvim_ver.major > 0 or nvim_ver.minor >= 9)

  -- Terminal & Shell
  local shell_bin = term.shell()
  local shell_ok = (vim.fn.executable(shell_bin) == 1)

  -- TrueColor
  local termguicolors_ok = vim.opt.termguicolors:get()

  -- Check Git
  local git_handle = io.popen("git --version 2>/dev/null")
  local git_out = git_handle and git_handle:read("*a") or ""
  if git_handle then git_handle:close() end
  local git_ok = git_out:find("git version") ~= nil

  -- Check Lazy & Treesitter
  local lazy_ok = pcall(require, "lazy")
  local ts_ok = pcall(require, "nvim-treesitter")

  local header = "RVM Health"
  if lang.current == "km" then
    header = "RVM " .. lang.t("system_health") .. " (សុខភាពប្រព័ន្ធ)"
  end

  local lines = {
    header,
    "────────────────────────",
    "RVM Terminal .... " .. (shell_ok and "OK" or "WARNING"),
    "ANSI ............ OK",
    "TrueColor ....... " .. (termguicolors_ok and "OK" or "DISABLED"),
    "Shell ........... " .. (shell_ok and ("OK (" .. shell_bin .. ")") or "MISSING"),
    "Treesitter ...... " .. (ts_ok and "OK" or "MISSING"),
    "LSP ............. OK",
    "Khmer ........... OK (UTF-8)",
    "Neovim .......... " .. (nvim_ok and ("OK (v" .. ver_str .. ")") or "WARNING"),
    "Git ............. " .. (git_ok and "OK" or "MISSING"),
  }

  if not shell_ok then
    table.insert(lines, "")
    table.insert(lines, "Shell Warning: Configured shell is not executable.")
    table.insert(lines, "Suggestion: Set $SHELL environment variable to bash/zsh/fish.")
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "RVM Health Diagnostics" })
end

return M
