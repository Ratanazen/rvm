-- lua/plugins/khmer.lua
-- RVM Khmer localization integration hook

local khmer = require("rvm.khmer")

return {
  {
    "Ratanazen/rvm-khmer",
    virtual = true,
    lazy = false,
    config = function()
      -- Hook Khmer language status & keymap overrides if needed
      vim.keymap.set("n", "<leader>K", function()
        if khmer.current_lang == "km" then
          khmer.set_lang("en")
        else
          khmer.set_lang("km")
        end
      end, { desc = "Toggle Khmer/English Language Mode" })
    end,
  },
}
