return {
  {
    "ziontee113/icon-picker.nvim",
    keys = {
      { "<leader>ii", "<cmd>IconPickerNormal<CR>", mode = "n", desc = "Insert icon" },
      { "<leader>iy", "<cmd>IconPickerYank<CR>", mode = "n", desc = "Yank icon" },
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
