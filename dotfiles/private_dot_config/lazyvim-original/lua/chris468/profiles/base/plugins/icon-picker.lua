local icons = "nerd_font_v3 symbols alt_font emoji html_colors"
return {
  {
    "ziontee113/icon-picker.nvim",
    keys = {
      { "<leader>ii", "<cmd>IconPickerNormal " .. icons .. "<CR>", mode = "n", desc = "Insert icon" },
      { "<leader>iy", "<cmd>IconPickerYank " .. icons .. "<CR>", mode = "n", desc = "Yank icon" },
    },
    cmd = {
      "IconPickerNormal",
      "IconPickerInsert",
      "IconPickerYank",
    },
    opts = {
      disable_legacy_commands = true,
    },
  },
}
