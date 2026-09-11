-- lua/rvm/ui.lua
-- Custom RVM Statusline, Minimal Start Screen, and Command Center UI

local lang = require("rvm.language")
local config = require("rvm.config")

local M = {}

--- Custom RVM Statusline Component Generator
function M.statusline()
  local mode_map = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    s = "SELECT",
    S = "S-LINE",
    R = "REPLACE",
  }

  local mode_code = vim.api.nvim_get_mode().mode
  local mode_str = mode_map[mode_code] or mode_code:upper()
  if lang.current == "km" then
    if mode_code == "n" then mode_str = "ធម្មតា"
    elseif mode_code == "i" then mode_str = "បញ្ចូល"
    elseif mode_code == "v" or mode_code == "V" then mode_str = "មើលឃើញ"
    elseif mode_code == "c" then mode_str = "ពាក្យបញ្ជា"
    end
  end

  local filename = vim.fn.expand("%:t")
  if filename == "" then filename = "[No Name]" end
  if vim.bo.modified then filename = filename .. " [+]" end

  local ft = vim.bo.filetype
  if ft == "" then ft = "text" else ft = ft:sub(1,1):upper() .. ft:sub(2) end

  local encoding = vim.bo.fileencoding
  if encoding == "" then encoding = "UTF-8" else encoding = encoding:upper() end

  -- Git branch
  local branch = vim.b.gitsigns_head or ""
  local git_str = branch ~= "" and ("git:" .. branch) or "git:local"

  -- Diagnostics count
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local diag_str = ""
  if errors > 0 or warnings > 0 then
    diag_str = string.format("E:%d W:%d", errors, warnings)
  end

  local left = string.format(" %s   %s ", mode_str, filename)
  local right_parts = { ft, encoding, git_str }
  if diag_str ~= "" then table.insert(right_parts, diag_str) end
  table.insert(right_parts, "RVM")

  local right = " " .. table.concat(right_parts, "   ") .. " "

  return left .. "%=" .. right
end

--- Render minimal RVM Start Screen
function M.start_screen()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "rvm_start"

  local lines = {
    "",
    "                 RVM",
    "",
    "             RATANA VIM",
    "",
    "       A Neovim environment",
    "",
    "     ───────────────────────",
    "",
    "     Open Project       ( <leader>pp )",
    "     Find File          ( <leader>ff / Ctrl+P )",
    "     Recent Files       ( <leader>fr )",
    "     Git                ( <leader>gg )",
    "     Configuration      ( :RVMConfig )",
    "",
    "     ───────────────────────",
    "",
    "     RVM " .. config.options.version,
    "     Neovim + LazyVim",
    "",
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].modifiable = false
end

--- Show RVM Command Center Menu (:RVM)
function M.command_center()
  local title = "RVM"
  local items = {
    "Open Project",
    "Find Files",
    "Recent Files",
    "Git",
    "Terminal",
    "LSP",
    "Plugins",
    "Settings",
    "Health",
    "Language",
  }

  local text = {
    title,
    "────────────────────",
  }
  for _, item in ipairs(items) do
    table.insert(text, item)
  end

  vim.notify(table.concat(text, "\n"), vim.log.levels.INFO, { title = "RVM Command Center" })
end

return M
