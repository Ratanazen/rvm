-- lua/plugins/terminal.lua
-- RVM Responsive Terminal Integration using Snacks.nvim

local rvm_term = require("rvm.terminal")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal = {
        win = {
          style = "terminal",
          border = "single",
          title = false,
          wo = {
            winbar = "",
          },
        },
      },
    },
    keys = {
      {
        "<leader>ft",
        function() rvm_term.open_root() end,
        desc = "Terminal (Project Root)",
      },
      {
        "<leader>fT",
        function() rvm_term.open_cwd() end,
        desc = "Terminal (Current Directory)",
      },
      {
        "<c-/>",
        function() rvm_term.open_root() end,
        desc = "Toggle Terminal",
      },
      {
        "<c-_>",
        function() rvm_term.open_root() end,
        desc = "Toggle Terminal",
      },
    },
  },
}
