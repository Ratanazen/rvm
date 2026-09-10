-- lua/rvm/config.lua
-- RVM Configuration & Options State (Full / Lite mode, RVM Dark / Light theme options)

local M = {}

M.defaults = {
  version = "2.5.0",
  mode = "full", -- "full" or "lite"
  theme = "rvm-dark", -- "rvm-dark" or "rvm-light"
  lang = "en",
  statusline = {
    compact = true,
    show_diagnostics = true,
    show_git = true,
  },
  ui = {
    transparent = false,
    minimal_start = true,
    subtle_borders = true,
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
