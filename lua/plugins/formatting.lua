-- lua/plugins/formatting.lua
-- RVM Code Formatting Configuration

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        ruby = { "rubocop" },
        rust = { "rustfmt" },
      },
      format_on_save = function(bufnr)
        if vim.g.rvm_format_on_save then
          return { timeout_ms = 500, lsp_fallback = true }
        end
        return nil
      end,
    },
  },
}
