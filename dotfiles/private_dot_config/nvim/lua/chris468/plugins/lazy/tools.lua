local getenv = require("os").getenv
local cmd = require("chris468.util.keymap").cmd

return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUninstallAll", "MasonUpdate" },
    keys = {
      { "<leader>ci", cmd("checkhealth vim.lsp conform"), desc = "LSP/Formatter info" },
      { "<leader>M", cmd("Mason"), desc = "Mason" },
    },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "chris468-tools",
    event = "FileType",
    dependencies = { "mason.nvim", "nvim-lspconfig", "mason-nvim-dap.nvim" },
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/tools",
    opts = {
      disabled_filetypes = Chris468.disabled_filetypes,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "blink.cmp", optional = true },
    },
    event = "FileType",
    keys = {
      { "<leader>cL", cmd("LspInfo"), desc = "LSP info" },
    },
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim", "chris468-tools" },
    event = "FileType",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format",
      },
      { "<leader>cF", cmd("ConformInfo"), desc = "Formatter info" },
    },
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        default_format_opts = {
          lsp_format = "fallback",
        },
        formatters_by_ft = require("chris468-tools").formatter.names_by_ft,
        format_on_save = function(bufnr)
          if vim.b[bufnr].format_on_save == nil then
            vim.b[bufnr].format_on_save = Chris468.format_on_save_default[vim.bo[bufnr].filetype] ~= false
          end
          if vim.g.format_on_save == false or vim.b[bufnr].format_on_save == false then
            return
          end

          return { timeout_ms = 500 }
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    dependencies = { "mason.nvim", "chris468-tools" },
    config = function(_, opts)
      require("lint").linters_by_ft = opts.linters_by_ft
    end,
    event = { "BufNew", "BufReadPre" },
    opts = function(_, opts)
      opts = opts or {}
      opts.linters_by_ft = require("chris468-tools").linter.names_by_ft
      return opts
    end,
    version = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    main = "nvim-treesitter.configs",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
    version = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      enable = true,
    },
    version = false,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local icons = Chris468.ui.icons
      vim.fn.sign_define({
        { name = "DapBreakpoint", text = icons.breakpoint, texthl = "Error" },
        { name = "DapBreakpointCondition", text = icons.breakpoint_condition, texthl = "Error" },
        { name = "DapBreakpointRejected", text = icons.breakpoint_condition, texthl = "Comment" },
        { name = "DapLogPoint", text = icons.log_point, texthl = "Error" },
        { name = "DapStopped", text = icons.stopped, texthl = "Function" },
      })
    end,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      config = function(_, opts)
        local before = require("dap").listeners.before
        local dapui = require("dapui")

        before.attach.dapui_config = dapui.open
        before.launch.dapui_config = dapui.open
        before.disconnect.dapui_config = dapui.close
        before.event_terminated.dapui_config = dapui.close
        before.event_exited.dapui_config = dapui.close

        require("dapui").setup(opts)
      end,
      dependencies = {
        "nvim-dap",
        "nvim-nio",
        {
          "lazydev.nvim",
          opts = {
            library = { "nvim-dap-ui" },
          },
        },
      },
      opts = {},
      version = false,
    },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        mode = { "n", "v" },
        desc = "Hover",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step in",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run last configuration",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        mode = { "n", "v" },
        desc = "Preview",
      },
      {
        "<leader>dr",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<leader>dR",
        function()
          require("dap").repl_toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle UI",
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason.nvim" },
    cmd = {
      "DapInstall",
      "DapUninstall",
    },
    opts = {},
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-nio",
      "plenary.nvim",
      "nvim-treesitter",
    },
    keys = {
      {
        "<leader>te",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle explorer",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run current file",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run last",
      },
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>to",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle output",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.getcwd())
        end,
        desc = "Run all",
      },
    },
    opts = {},
  },
}
