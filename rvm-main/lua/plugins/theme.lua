-- lua/plugins/theme.lua
-- RVM Theme configuration & fallback

return {
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
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
  },
  {
    "joshdick/onedark.vim",
    lazy = true,
  },
}
