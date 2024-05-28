local function set_keymaps(buf)
  local telescope_builtin = require("telescope.builtin")
  local util = require("chris468.util")

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
  -- set_keymap("n", "gd", util.trouble.open("lsp_definitions"), "Go to definition")
  set_keymap("n", "gd", telescope_builtin.lsp_definitions, "Go to definition")
  set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  set_keymap("n", "gI", util.trouble.open("lsp_implementations"), "Go to implementation")
  set_keymap("n", "gr", util.trouble.open("lsp_references"), "Find references")
  set_keymap("n", "gy", util.trouble.open("lsp_type_definitions"), "Go to type definition")
  set_keymap("n", "K", vim.lsp.buf.hover, "Hover help")
  set_keymap("n", "gK", vim.lsp.buf.signature_help, "Signature help")
  set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  set_keymap("n", "<leader>cc", vim.lsp.codelens.run, "Run codelens")
  set_keymap("n", "<leader>cr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, "Rename", { expr = true })
  set_keymap("n", "<leader>flI", telescope_builtin.lsp_implementations, "Implementations")
  set_keymap("n", "<leader>flr", telescope_builtin.lsp_references, "References")
  set_keymap("n", "<leader>fls", telescope_builtin.lsp_workspace_symbols, "Symbols")
  set_keymap("n", "<leader>fly", telescope_builtin.lsp_type_definitions, "Type definitions")
end

local function refresh_codelens(buf)
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
    group = "Configure LSP",
    buffer = buf,
    callback = function()
      for _, client in ipairs(vim.lsp.get_active_clients({ buf = buf })) do
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
  once = true,
  callback = function(args)
    local buf = args.buf
    set_keymaps(buf)
    refresh_codelens(buf)
  end,
})
