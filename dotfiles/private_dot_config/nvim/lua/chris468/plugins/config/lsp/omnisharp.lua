local function between(current, range)
  return range.start.row == range["end"].row
    and current.row == range.start.row
    and current.col >= range.start.col
    and current.col <= range["end"].col
end

local function configure_omnisharp_commands()
  vim.lsp.commands["omnisharp/client/findReferences"] = function(command, context)
    local window = vim.fn.bufwinid(context.bufnr)
    local range = {
      start = {
        row = command.arguments[1].range.start.line + 1,
        col = command.arguments[1].range.start.character,
      },
      ["end"] = {
        row = command.arguments[1].range["end"].line + 1,
        col = command.arguments[1].range["end"].character,
      },
    }

    local current = {}
    current.row, current.col = unpack(vim.api.nvim_win_get_cursor(window))

    if not between(current, range) then
      vim.api.nvim_win_set_cursor(window, { range.start.row, range.start.col })
    end

    require("telescope.builtin").lsp_references()
  end
end

return {
  cmd = { "omnisharp" },
  on_attach = function(_, _)
    -- Ideally this would just set up the command in the comands table, but in lspconfig
    -- that currently sets up autocmds. see neovim/nvim-lspconfig/issues/2632.
    configure_omnisharp_commands()
  end,
  settings = {
    FormattingOptions = {
      OrganizeImports = true,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = true,
      EnableImportCompletion = true,
    },
  },
}
