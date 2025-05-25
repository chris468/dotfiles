local snacks = require("snacks")
local whichkey = require("which-key")
local util_lua = require("chris468.util.lua")

local mappings = {
  { "<leader>c", group = "Code" },
  { "<leader>f", group = "Files" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "Lua", icon = "󰢱" },
  { "<leader>s", group = "Search" },
  { "<leader>u", group = "UI" },
  { "<Esc>", "<cmd>nohlsearch<CR>", desc = "Clear search hilight" },
  { "<leader>L", "<cmd>Lazy<CR>", desc = "Lazy", icon = "󰒲" },
  { "<leader>lx", util_lua.run_selection, desc = "Run selected", mode = { "n", "x" } },
  { "<leader>bb", "<cmd>e #<CR>", desc = "Switch to previous" },
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete buffer" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete buffer" },
  { "j", "gj", hidden = true },
  { "k", "gk", hidden = true },
}

whichkey.add(mappings)

snacks.toggle.diagnostics({ name = "diagnostics" }):map("<leader>cD")

snacks.toggle
  .new({
    id = "format",
    name = "format on save",
    get = function()
      return vim.b.format_on_save ~= false
    end,
    set = function(state)
      vim.b.format_on_save = state
    end,
  })
  :map("<leader>c<C-F>")
