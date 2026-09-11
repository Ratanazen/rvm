-- lua/plugins/ui.lua
-- RVM Minimal Custom Statusline & UI Integration

local rvm_ui = require("rvm.ui")

return {
  -- Custom RVM Statusline: NORMAL  main.lua  Lua  UTF-8  git:main  RVM
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = "tokyonight",
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = {
            function()
              return rvm_ui.statusline()
            end,
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },

  -- Clean Bufferline (Flat Thin Tabs)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        style = "thin",
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        enforce_regular_tabs = true,
        modified_icon = "[+]",
      },
    },
  },
}
