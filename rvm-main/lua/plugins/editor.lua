-- lua/plugins/editor.lua
-- RVM Minimal Explorer, Finder, Mouse Click Open & Single Line Borders

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

  -- Clean Neo-tree Explorer (Mouse Left-Click Open File)
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
      { "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer (Ctrl+B)" },
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 28,
        popup = { border = "single" },
        mappings = {
          ["<space>"] = "none",
          ["<leftclick>"] = "open",
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
