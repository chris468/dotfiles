local icons = "nerd_font_v3 symbols alt_font emoji html_colors"
return {
  {
    "ziontee113/icon-picker.nvim",
    cmd = {
      "IconPickerNormal",
      "IconPickerInsert",
      "IconPickerYank",
    },
    keys = {
      { "<leader>ii", "<cmd>IconPickerNormal " .. icons .. "<CR>", desc = "Insert icon" },
      { "<leader>iy", "<cmd>IconPickerYank " .. icons .. "<CR>", desc = "Yank icon" },
    },
    opts = {
      disable_legacy_commands = true,
    },
  },
}
