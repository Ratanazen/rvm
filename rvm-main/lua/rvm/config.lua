-- lua/rvm/config.lua
-- RVM Configuration module

local M = {}

M.defaults = {
  version = "2.5.0",
  distribution = "Ratana Vim (RVM)",
  author = "Ratanazen",
  repository = "https://github.com/Ratanazen/rvm.git",
  theme = "tokyonight",
  fallback_theme = "default",
  leader = " ",
  lang = "en",
  lsp_autostart = true,
  format_on_save = true,
}

M.options = vim.deepcopy(M.defaults)

function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
end

return M
