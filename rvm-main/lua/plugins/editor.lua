-- lua/plugins/editor.lua
-- RVM File Explorer, Fuzzy Finder, and Keymap Helper

return {
  -- Telescope Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (Root Dir)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
    opts = {
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
      },
    },
  },

  -- Neo-tree File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree (Root Dir)" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Explorer NeoTree Reveal" },
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- Which-Key Popup
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      defaults = {
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>l"] = { name = "+lsp" },
        ["<leader>t"] = { name = "+terminal" },
        ["<leader>w"] = { name = "+window" },
        ["<leader>x"] = { name = "+diagnostics" },
      },
    },
  },
}
