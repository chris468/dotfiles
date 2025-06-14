local snacks = require("snacks")
local whichkey = require("which-key")
local util_lua = require("chris468.util.lua")
local cmd = require("chris468.util.keymap").cmd

local mappings = {
  { "<Esc>", cmd("nohlsearch"), desc = "Clear search hilight" },
  { "<leader>L", cmd("Lazy"), desc = "Lazy", icon = "󰒲" },
  { "<leader>b", group = "Buffers" },
  { "<leader>bb", cmd("e #"), desc = "Switch to previous" },
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete buffer" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete buffer" },
  { "<leader>c", group = "Code" },
  { "<leader>cd", vim.diagnostic.setqflist, desc = "Diagnostics" },
  { "<leader>cl", vim.diagnostic.open_float, desc = "Line diagnostic" },
  { "<leader>f", group = "Files" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "Lua", icon = "󰢱" },
  { "<leader>lx", util_lua.run_selection, desc = "Run selected", mode = { "n", "x" } },
  { "<leader>s", group = "Search" },
  { "<leader>u", group = "UI" },
  { "<leader><Tab>", group = "Tab" },
  { "<leader><Tab>n", cmd("tabnew"), desc = "New" },
  { "<leader><Tab>c", cmd("tabclose"), desc = "Close" },
  { "[<Tab>", cmd("tabprevious"), desc = "Previous tab" },
  { "]<Tab>", cmd("tabnext"), desc = "Next tab" },
  { "j", "gj", hidden = true },
  { "k", "gk", hidden = true },
}

local lsp_mappings = {
  {
    "<leader>ci",
    vim.lsp.buf.incoming_calls,
    desc = "Incoming calls",
  },
  {
    "<leader>co",
    vim.lsp.buf.outgoing_calls,
    desc = "Outgoing calls",
  },
  {
    "<leader>cs",
    cmd("Telescope lsp_dynamic_workspace_symbols"),
    desc = "Find symbol",
  },
  {
    "gd",
    vim.lsp.buf.definition,
    desc = "Go to definition",
  },
  {
    "gD",
    vim.lsp.buf.declaration,
    desc = "Go to declaration",
  },
  {
    "gI",
    vim.lsp.buf.implementation,
    desc = "Go to implementation",
  },
  {
    "gr",
    vim.lsp.buf.references,
    desc = "Find references",
  },
  {
    "gy",
    vim.lsp.buf.type_definition,
    desc = "Go to type definition",
  },
}

whichkey.add(mappings)

snacks.toggle.diagnostics({ name = "diagnostics" }):map("<leader>cD")

snacks.toggle
  .new({
    id = "qf",
    name = "quickfix window",
    notify = false,
    wk_desc = {
      enabled = "Close ",
      disabled = "Open ",
    },
    get = function()
      return vim.fn.getqflist({ winid = 0 }).winid ~= 0
    end,
    set = function(state)
      if state then
        vim.cmd.copen()
      else
        vim.cmd.cclose()
      end
    end,
  })
  :map("<leader>q")

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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468.mappings.quick_quit", {}),
  callback = function()
    vim.keymap.set("n", "q", cmd("quit"), {
      buffer = true,
      desc = "Close",
      nowait = true,
    })
  end,
  pattern = {
    "TelescopePrompt",
    "help",
    "oil",
    "neotest-summary",
    "neotest-output-panel",
    "qf",
  },
})
