local snacks = require("snacks")
local util_lua = require("chris468.util.lua")
return {
  { "<Esc>", "<cmd>nohlsearch<CR>", desc = "Clear search hilight" },
  { "<leader>L", "<cmd>Lazy<CR>", desc = "Lazy", icon = "󰒲" },
  { "<leader>lx", util_lua.run_selection, desc = "Run selected", mode = { "n", "x" } },
  { "<leader>bb", "<cmd>e #<CR>", desc = "Switch to previous" },
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete buffer" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete buffer" },
}
