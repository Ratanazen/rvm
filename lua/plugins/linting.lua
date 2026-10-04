-- lua/plugins/linting.lua
-- RVM Code Linting Configuration

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        ruby = { "rubocop" },
      }
      
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("RVM_Linting", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
