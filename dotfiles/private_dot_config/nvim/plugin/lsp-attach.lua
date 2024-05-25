local function set_keymaps(buf)
  local telescope = { builtin = require("telescope.builtin") }

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

  set_keymap("n", "gd", telescope.builtin.lsp_definitions, "Go to definition")
  set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  set_keymap("n", "gI", telescope.builtin.lsp_implementations, "Go to implementation")
  set_keymap("n", "gr", telescope.builtin.lsp_references, "Find references")
  set_keymap("n", "gy", telescope.builtin.lsp_type_definitions, "Go to type definition")
  set_keymap("n", "K", vim.lsp.buf.hover, "Hover help")
  set_keymap("n", "gK", vim.lsp.buf.signature_help, "Signature help")
  set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  set_keymap("n", "<leader>cc", vim.lsp.codelens.run, "Run codelens")
  set_keymap("n", "<leader>cr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, "Rename", { expr = true })
  set_keymap("n", "<leader>fs", telescope.builtin.lsp_workspace_symbols, "Symbols")
end

local function refresh_codelens(buf)
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
    buffer = buf,
    callback = vim.lsp.codelens.refresh,
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
