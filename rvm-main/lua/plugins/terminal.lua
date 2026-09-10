-- lua/plugins/terminal.lua
-- RVM Integrated Floating & Panel Terminal

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>ft", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Floating Terminal (<leader>ft)" },
      { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Bottom Terminal (<leader>tt)" },
    },
    opts = {
      size = 15,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = os.getenv("SHELL") or vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 3,
      },
    },
  },
}
