local util = require("lspconfig.util")

local function configure_roslyn_commands()
  vim.lsp.commands["roslyn.client.peekReferences"] = function(command, context)
    local window = vim.fn.bufwinid(context.bufnr)
    local pos = { command.arguments[2].line + 1, command.arguments[2].character }

    vim.api.nvim_win_set_cursor(window, pos)

    require("telescope.builtin").lsp_references()
  end
end

return {
  server = {
    default_config = {
      cmd = { "roslyn_lsp", "--logLevel", "Information", "--extensionLogDirectory", vim.fn.stdpath("state") },
      filetypes = { "cs" },
      on_attach = function(_, _)
        -- Ideally this would just set up the command in the comands table, but in lspconfig
        -- that currently sets up autocmds. see neovim/nvim-lspconfig/issues/2632.
        configure_roslyn_commands()
      end,
      root_dir = util.root_pattern({ "*.sln", "*.csproj" }),
      settings = {},
    },
  },
  lspconfig = {},
}
