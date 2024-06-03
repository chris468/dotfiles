local adapters_for_ft = {
  python = { "debugpy" },
}

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts.install_for_filetype = opts.install_for_filetype or {}
        opts.install_for_filetype.dap = adapters_for_ft
      end,
    },
    {
      "rcarriga/nvim-dap-ui",
      config = function()
        local dap, dapui = require("dap"), require("dapui")

        dapui.setup()

        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end
      end,
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {},
    },
    {
      "nvim-telescope/telescope-dap.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
    },
    {
      "rcarriga/cmp-dap",
      config = function()
        local cmp = require("cmp")
        cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
          sources = {
            { name = "dap" },
          },
        })
      end,
      dependencies = {
        "hrsh7th/nvim-cmp",
        opts = {
          enable = function()
            return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt"
              or require("cmp_dap").is_dap_buffer()
          end,
        },
      },
    },
    {
      "LiadOz/nvim-dap-repl-highlights",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {},
    },
    {
      "mfussenegger/nvim-dap-python",
      config = function(_, opts)
        local mcp = require("mason-core.path")
        local path = mcp.concat({ mcp.package_prefix("debugpy"), "venv", "bin", "python" })
        require("dap-python").setup(path, opts)
      end,
      dependencies = { "williamboman/mason.nvim" },
    },
  },
}
