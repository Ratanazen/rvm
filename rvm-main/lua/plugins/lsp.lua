-- lua/plugins/lsp.lua
-- RVM LSP, Mason, Diagnostics, and Formatter Setup

return {
  -- Mason Package Manager for LSPs and Linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason Package Manager" } },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "pyright",
        "typescript-language-server",
        "rust-analyzer",
        "gopls",
        "clangd",
        "bash-language-server",
      },
    },
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        ts_ls = {},
        rust_analyzer = {},
        gopls = {},
        clangd = {},
        bashls = {},
      },
    },
    config = function(_, opts)
      local ok_mason, mason_lsp = pcall(require, "mason-lspconfig")
      if ok_mason then
        mason_lsp.setup({
          ensure_installed = vim.tbl_keys(opts.servers),
        })
      end
    end,
  },

  -- Conform Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format Buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
    },
  },

  -- Trouble Diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle diagnostics<cr>", desc = "Diagnostics Panel (Trouble)" },
      { "<leader>xD", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    },
    opts = {},
  },
}
