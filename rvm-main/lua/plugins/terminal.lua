-- lua/plugins/terminal.lua
-- RVM Floating Terminal (<leader>ft) matching user shell

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm" },
    keys = {
      { "<leader>ft", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating Terminal (<leader>ft)" },
    },
    opts = {
      size = 15,
      open_mapping = [[<c-\>]],
      direction = "float",
      shell = os.getenv("SHELL") or vim.o.shell,
      float_opts = {
        border = "single",
      },
    },
  },
}
