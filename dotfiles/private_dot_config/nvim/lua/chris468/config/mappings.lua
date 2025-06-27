local snacks = require("snacks")
local whichkey = require("which-key")
local util_lua = require("chris468.util.lua")
local cmd = require("chris468.util.keymap").cmd

local function wrap(fn, ...)
  local arg = { ... }
  return function()
    return fn(unpack(arg))
  end
end

local function trouble_open_or_replace(mode, opts)
  local trouble = require("trouble")
  local trouble_view = require("trouble.view")
  local views = trouble_view.get({ open = true })
  for _, view in ipairs(views or {}) do
    if view.mode ~= "lsp_document_symbols" and view.mode ~= mode then
      view.view:close()
    end
  end

  trouble.first(vim.tbl_extend("force", { mode = mode, refresh = true }, opts or {}))
end

local mappings = {
  { "<Esc>", cmd("nohlsearch"), desc = "Clear search hilight" },
  { "<leader>L", cmd("Lazy"), desc = "Lazy", icon = "󰒲" },
  { "<leader>b", group = "Buffers" },
  { "<leader>bb", cmd("e #"), desc = "Switch to previous" },
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete buffer" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete buffer" },
  { "<leader>c", group = "Code" },
  {
    "<leader>cd",
    wrap(trouble_open_or_replace, "diagnostics"),
    desc = "Diagnostics",
  },
  {
    "<leader>cD",
    wrap(trouble_open_or_replace, "diagnostics", { filter = { buf = 0 } }),
    desc = "Buffer diagnostics",
  },
  { "<leader>cl", vim.diagnostic.open_float, desc = "Line diagnostic" },
  { "<leader>f", group = "Files" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "Lua", icon = "󰢱" },
  { "<leader>lx", util_lua.run_selection, desc = "Run selected", mode = { "n", "x" } },
  { "<leader>s", group = "Search" },
  { "<leader>t", group = "Test" },
  { "<leader>u", group = "UI" },
  { "<leader><Tab>", group = "Tab" },
  { "<leader><Tab>n", cmd("tabnew"), desc = "New" },
  { "<leader><Tab>c", cmd("tabclose"), desc = "Close" },
  { "[<Tab>", cmd("tabprevious"), desc = "Previous tab" },
  { "]<Tab>", cmd("tabnext"), desc = "Next tab" },
  { "j", "gj", hidden = true },
  { "k", "gk", hidden = true },
}

-- lhs: string|{lhs: string, mode?: string|string[] }
local remove_mappings = {
  { "gra", { "n", "x" } }, -- -> <leader>ca
  "gri", -- -> gI go to implementation
  "grn", -- -> cn rename
  "grr", -- -> gr find references
}

local lsp_mappings = {
  {
    "<leader>ca",
    function()
      vim.lsp.buf.code_action()
    end,
    desc = "Code action",
    mode = { "n", "x" },
  },
  {
    "<leader>ci",
    wrap(trouble_open_or_replace, "lsp_incoming_calls"),
    desc = "Incoming calls",
  },
  {
    "<leader>cn",
    function()
      vim.lsp.buf.rename()
    end,
    desc = "Rename",
  },
  {
    "<leader>co",
    wrap(trouble_open_or_replace, "lsp_outgoing_calls"),
    desc = "Outgoing calls",
  },
  {
    "<leader>cs",
    cmd("Telescope lsp_dynamic_workspace_symbols"),
    desc = "Find symbol",
  },
  {
    "<leader>cS",
    cmd("Trouble lsp_document_symbols"),
    desc = "Document symbols",
  },
  {
    "<leader>cx",
    "<cmd>Trouble close<CR>",
    desc = "Close all",
  },
  {
    "gd",
    "<cmd>Trouble lsp_definitions first<CR>",
    wrap(trouble_open_or_replace, "lsp_definitions"),
    desc = "Go to definition)",
  },
  {
    "gI",
    wrap(trouble_open_or_replace, "lsp_implementations"),
    desc = "Go to implementation",
  },
  {
    "gr",
    wrap(trouble_open_or_replace, "lsp_references"),
    desc = "Find references",
  },
  {
    "gy",
    wrap(trouble_open_or_replace, "lsp_type_definitions"),
    desc = "Go to type definition",
  },
}

for _, spec in ipairs(remove_mappings) do
  if type(spec) ~= "table" then
    spec = { spec }
  end
  vim.keymap.del(spec[2] or "n", spec[1])
end

whichkey.add(mappings)

snacks.toggle.diagnostics({ name = "diagnostics" }):map("<leader>c<C-D>")

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
