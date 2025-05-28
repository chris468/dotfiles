local snacks = require("snacks")
local whichkey = require("which-key")
local util = require("chris468.util")
local util_lua = require("chris468.util.lua")

local mappings = {
  { "<Esc>", "<cmd>nohlsearch<CR>", desc = "Clear search hilight" },
  { "<leader>L", "<cmd>Lazy<CR>", desc = "Lazy", icon = "󰒲" },
  { "<leader>b", group = "Buffers" },
  { "<leader>bb", "<cmd>e #<CR>", desc = "Switch to previous" },
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete buffer" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete buffer" },
  { "<leader>c", group = "Code" },
  {
    "<leader>cd",
    "<cmd>Trouble diagnostics<CR>",
    desc = "Diagnostics (Trouble)",
  },
  { "<leader>cl", vim.diagnostic.open_float, desc = "Line diagnostic" },
  { "<leader>f", group = "Files" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "Lua", icon = "󰢱" },
  { "<leader>lx", util_lua.run_selection, desc = "Run selected", mode = { "n", "x" } },
  { "<leader>s", group = "Search" },
  { "<leader>u", group = "UI" },
  { "j", "gj", hidden = true },
  { "k", "gk", hidden = true },
}

local lsp_mappings = {
  {
    "<leader>ci",
    "<cmd>Trouble lsp_incoming_calls first<CR>",
    desc = "Incoming calls (Trouble)",
  },
  {
    "<leader>co",
    "<cmd>Trouble lsp_outgoing_calls first<CR>",
    desc = "Outgoing calls (Trouble)",
  },
  {
    "<leader>cs",
    "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
    desc = "Find symbol",
  },
  {
    "<leader>cx",
    "<cmd>Trouble close<CR>",
    desc = "Close Trouble",
  },
  {
    "gd",
    "<cmd>Trouble lsp_definitions first<CR>",
    desc = "Go to definition (Trouble)",
  },
  {
    "gD",
    "<cmd>Trouble lsp_declarations first<CR>",
    desc = "Go to declarations (Trouble)",
  },
  {
    "gI",
    "<cmd>Trouble lsp_implementations first<CR>",
    desc = "Go to implementation (Trouble)",
  },
  {
    "gr",
    "<cmd>Trouble lsp_references first<CR>",
    desc = "Find references (Trouble)",
  },
  {
    "gy",
    "<cmd>Trouble lsp_type_definitions first<CR>",
    desc = "Go to type definition (Trouble)",
  },
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("chris468.mappings.lsp", {}),
  callback = function(args)
    local bufnr = args.buf
    for _, mapping in ipairs(lsp_mappings) do
      vim.keymap.set(mapping.mode or "n", mapping[1], mapping[2], {
        buffer = bufnr,
        desc = mapping.desc,
      })
    end
  end,
})
