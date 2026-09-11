-- lua/plugins/syntax.lua
-- RVM Syntax Engine: Treesitter (28+ Languages) & LSP Semantic Token Highlighting

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "html",
        "css",
        "scss",
        "markdown",
        "markdown_inline",
        "c",
        "cpp",
        "rust",
        "go",
        "java",
        "kotlin",
        "sql",
        "dockerfile",
        "gitcommit",
        "git_rebase",
        "regex",
        "query",
      },
    },
    config = function(_, opts)
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts.setup(opts)
      end
    end,
  },
}
