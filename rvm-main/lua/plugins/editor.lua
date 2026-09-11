-- lua/plugins/editor.lua
-- RVM Minimal Explorer, Finder, and Keymaps

return {
  -- Clean Telescope Finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    },
    opts = {
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "❯ ",
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    },
  },

  -- Clean Neo-tree Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
      },
      window = {
        width = 25,
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- Restrained Which-Key (Single Border & Padding)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      win = {
        border = "single",
        padding = { 1, 2 },
      },
    },
  },
}
