local util = require("lspconfig.util")

local function configure_client_commands()
  vim.lsp.commands["roslyn.client.peekReferences"] = function(command, context)
    local window = vim.fn.bufwinid(context.bufnr)
    local pos = { command.arguments[2].line + 1, command.arguments[2].character }

    vim.api.nvim_win_set_cursor(window, pos)

    require("telescope.builtin").lsp_references()
  end
end

local function open_solution(client, sln)
  vim.notify("Opening " .. sln .. "...")
  client.notify("solution/open", { solution = vim.uri_from_fname(sln) })
end

local function get_solutions(client)
  local root = client.config.root_dir
  local slns = vim.fn.glob(root .. "/*.sln", nil, true)
  return slns
end

local function find_and_open_solution(client)
  local slns = get_solutions(client)
  vim.notify(tostring(#slns) .. " solution found.")
  if #slns == 0 then
    return
  end
  open_solution(client, slns[1])
end

local function prompt_for_solution(client)
  local slns = get_solutions(client)
  vim.ui.select(slns, { prompt = "Choose solution" }, function(selected)
    if selected then
      open_solution(client, selected)
    end
  end)
end

local function register_user_commands(client, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gos", "", {
    callback = function()
      prompt_for_solution(client)
    end,
    desc = "Open solution",
  })
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
      on_attach = function(client, bufnr)
        register_user_commands(client, bufnr)
      end,
      on_init = function(client)
        find_and_open_solution(client)

        -- Ideally this would just set up the command in the comands table, but in lspconfig
        -- that currently sets up autocmds. see neovim/nvim-lspconfig/issues/2632.
        configure_client_commands()
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
