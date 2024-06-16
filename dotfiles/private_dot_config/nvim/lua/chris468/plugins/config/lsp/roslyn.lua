local util = require("lspconfig.util")

local function configure_roslyn_commands()
  vim.lsp.commands["roslyn.client.peekReferences"] = function(command, context)
    local window = vim.fn.bufwinid(context.bufnr)
    local pos = { command.arguments[2].line + 1, command.arguments[2].character }

    vim.api.nvim_win_set_cursor(window, pos)

    require("telescope.builtin").lsp_references()
  end
end

local function find_and_open_solution(client)
  local root = client.config.root_dir
  local slns = vim.fn.glob(root .. "/*.sln", nil, true)
  vim.notify(tostring(#slns) .. " solution found.")
  if #slns == 0 then
    return
  end
  local sln = slns[1]
  client.notify("solution/open", { solution = vim.uri_from_fname(sln) })
end

return {
  server = {
    default_config = {
      cmd = {
        "roslyn_lsp",
        "--logLevel",
        "Information",
        "--extensionLogDirectory",
        vim.fn.stdpath("state"),
      },
      filetypes = { "cs" },
      handlers = {
        ["workspace/projectInitializationComplete"] = function()
          vim.notify("Project initialization complete.")
        end,
      },
      on_attach = function(client, _)
        -- Ideally this would just set up the command in the comands table, but in lspconfig
        -- that currently sets up autocmds. see neovim/nvim-lspconfig/issues/2632.
        configure_roslyn_commands()
        find_and_open_solution(client)
      end,
      on_new_config = function(new_config, _)
        if vim.g.debug_roslyn_lsp == 1 then
          new_config.cmd = {
            "lsp-devtools",
            "agent",
            "--",
            unpack(new_config.cmd),
          }
        end
      end,
      root_dir = util.root_pattern({ "*.sln", "*.csproj" }),
      settings = {},
    },
  },
  lspconfig = {},
}
