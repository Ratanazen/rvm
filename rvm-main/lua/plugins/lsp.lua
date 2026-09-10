-- lua/plugins/lsp.lua
-- RVM LSP, Mason, Diagnostics & Formatter

return {
  -- Mason Package Manager
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        border = "single",
      },
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        rust_analyzer = {},
        ts_ls = {},
        clangd = {},
      },
    },
  },

  -- Clean Diagnostics Panel (Trouble)
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle diagnostics<cr>", desc = "Diagnostics" },
    },
    opts = {
      use_diagnostic_signs = true,
    },
  },
}
