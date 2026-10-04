-- lua/plugins/task.lua
-- RVM Task Management & TODOs

return {
  -- TODO comments highlighting and searching
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO Comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODOs (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "TODO/FIX/FIXME (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search TODOs" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Search TODO/FIX/FIXME" },
    },
  },

  -- Task Runner (Overseer)
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerRun",
      "OverseerRunCmd",
      "OverseerInfo",
      "OverseerBuild",
    },
    opts = {
      dap = false,
      task_list = {
        bindings = {
          ["<C-h>"] = false,
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<C-l>"] = false,
        },
      },
    },
    keys = {
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run Task" },
      { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Toggle Task List" },
      { "<leader>tc", "<cmd>OverseerRunCmd<cr>", desc = "Run Command" },
      { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
      { "<leader>ti", "<cmd>OverseerInfo<cr>", desc = "Overseer Info" },
    },
  },
}
