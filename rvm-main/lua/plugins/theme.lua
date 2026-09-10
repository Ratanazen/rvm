-- lua/plugins/theme.lua
-- RVM Exclusive Restrained Theme (RVM Dark / RVM Light) & Fallbacks

return {
  -- TokyoNight with custom RVM restrained highlights
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      on_highlights = function(hl, c)
        -- Restrained, low-noise aesthetic
        hl.Normal = { bg = "#16171d", fg = "#a9b1d6" }
        hl.NormalFloat = { bg = "#1a1b23", fg = "#a9b1d6" }
        hl.FloatBorder = { bg = "#1a1b23", fg = "#2f3549" }
        hl.StatusLine = { bg = "#121318", fg = "#9aa5ce" }
        hl.StatusLineNC = { bg = "#121318", fg = "#565f89" }
        hl.CursorLine = { bg = "#1f2029" }
        hl.LineNr = { fg = "#3b4261" }
        hl.CursorLineNr = { fg = "#7aa2f7", bold = true }
        hl.Comment = { fg = "#565f89", italic = true }
      end,
    },
    config = function(_, opts)
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup(opts)
        vim.cmd("colorscheme tokyonight")
      else
        pcall(vim.cmd, "colorscheme default")
      end
    end,
  },
}
