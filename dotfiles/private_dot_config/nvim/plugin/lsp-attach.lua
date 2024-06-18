function open(mode)
  return function()
    local trouble = require("trouble")
    trouble.open(mode)
  end
end

local WorkspaceSymbolFinder = {
  close = function() end,
  __call = function(self, prompt, process_result, process_complete)
    self:find(prompt, process_result, process_complete)
  end,
}

function WorkspaceSymbolFinder:new(bufnr)
  local finder = { bufnr = bufnr }
  setmetatable(finder, self)
  self.__index = self
  return finder
end

function WorkspaceSymbolFinder:find(prompt, process_result, process_complete)
  if self.cancel then
    self.cancel()
  end

  if prompt == "" then
    process_complete()
    return
  end

  local cancel = vim.lsp.buf_request_all(self.bufnr, "workspace/symbol", { query = prompt }, function(results)
    local entry_maker = require("telescope.make_entry").gen_from_lsp_symbols({})
    self.cancel = nil
    for client_id, client_results in pairs(results) do
      local err, result = client_results.error, client_results.result
      if err then
        vim.notify("Error requesting workspace symbols from client_id " .. client_id .. ": " .. err.message)
      else
        local locations = vim.lsp.util.symbols_to_items(result or {}, self.bufnr) or {}
        for _, location in ipairs(locations) do
          process_result(entry_maker(location))
        end
      end
    end
    process_complete()
  end)
  self.cancel = function()
    self.cancel = nil
    cancel()
  end
  WorkspaceSymbolFinder.current = self
end

local function set_keymaps(buf)
  local telescope_builtin = require("telescope.builtin")

  --- @param modes string|table: mode(s) to bind keymap
  --- @param key string: key to map
  --- @param action string|function: action to run
  --- @param desc string: description
  --- @param opts nil|table: additional options
  local function set_keymap(modes, key, action, desc, opts)
    opts = opts or {}

    opts.desc = desc

    if type(action) == "function" then
      opts.callback = action
      action = ""
    end

    if type(modes) == "string" then
      modes = { modes }
    end

    for _, mode in ipairs(modes) do
      vim.api.nvim_buf_set_keymap(buf, mode, key, action, opts)
    end
  end

  -- trouble lsp_definitions isn't working w/ omnisharp. there's usually only one definition anyway
  -- set_keymap("n", "gd", open("lsp_definitions"), "Go to definition")
  set_keymap("n", "gd", telescope_builtin.lsp_definitions, "Go to definition")
  set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  set_keymap("n", "gI", open("lsp_implementations"), "Go to implementation")
  set_keymap("n", "gr", open("lsp_references"), "Find references")
  set_keymap("n", "gy", open("lsp_type_definitions"), "Go to type definition")
  set_keymap("n", "K", vim.lsp.buf.hover, "Hover help")
  set_keymap("n", "gK", vim.lsp.buf.signature_help, "Signature help")
  set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  set_keymap("n", "<leader>cc", vim.lsp.codelens.run, "Run codelens")
  set_keymap("n", "<leader>ci", open("lsp_incoming_calls"), "Incoming calls")
  set_keymap("n", "<leader>co", open("lsp_outgoing_calls"), "Outgoing calls")
  set_keymap("n", "<leader>cr", function()
    return ":IncRename "
  end, "Rename", { expr = true })
  set_keymap("n", "<leader>cR", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, "Rename (edit)", { expr = true })
  set_keymap("n", "<leader>flI", telescope_builtin.lsp_implementations, "Implementations")
  set_keymap("n", "<leader>flr", telescope_builtin.lsp_references, "References")
  set_keymap("n", "<leader>fls", function()
    local pickers = require("telescope.pickers")
    local conf = require("telescope.config").values

    local bufnr = vim.api.nvim_get_current_buf()

    pickers
      .new({
        prompt_title = "Workspace Symbols",
        finder = WorkspaceSymbolFinder:new(bufnr),
        previewer = conf.qflist_previewer({}),
        sorter = conf.prefilter_sorter({
          tag = "symbol_type",
          sorter = conf.generic_sorter({}),
        }),
      }, {})
      :find()
  end, "Symbols")
  set_keymap("n", "<leader>fly", telescope_builtin.lsp_type_definitions, "Type definitions")
end

local function refresh_codelens(buf)
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
    group = vim.api.nvim_create_augroup("Refresh codelens", { clear = true }),
    buffer = buf,
    callback = function()
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = buf })) do
        if client.supports_method("textDocument/codeLens") then
          vim.lsp.codelens.refresh()
          return
        end
      end
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("Configure LSP", { clear = true }),
  callback = function(args)
    local buf = args.buf
    set_keymaps(buf)
    refresh_codelens(buf)
  end,
})
