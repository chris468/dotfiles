local cmd = require("chris468.util.keymap").cmd

local filetypes =
  vim.list_extend({ "python" }, Chris468.venv.additional_filetypes ~= 0 and Chris468.venv.additional_filetypes or {})

local script_path = vim.fn.stdpath("config") .. "/scripts/find-venvs.sh"

return {
  {
    "nvim-lspconfig",
    opts = {
      pyright = {},
      ruff = {},
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    enabled = true,
    ft = filetypes,
    keys = {
      {
        "<leader>cv",
        cmd(":VenvSelect"),
        desc = "Select VirtualEnv",
        ft = vim.list_extend({ "python" }, filetypes),
      },
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
          require_lsp_activation = false,
        },
        search = {
          pipx = false,
          cwd = {
            command = "bash " .. script_path .. " $CWD",
          },
          filed = {
            command = "bash " .. script_path .. " $FILE_DIR",
          },
        },
      },
    },
    version = false,
  },
}
