local cmd = require("chris468.util.keymap").cmd

---@class chris468.config.LspServer
---@field enabled? boolean Whether to enable the server. Default true
---@field name? string The server config name. Defaults to package name, or lspconfig name from package if available.
---@field public package? boolean Whether there is a mason package. Defaults to true.
---@field lspconfig? vim.lsp.Config The server config. Defaults to empty

---@alias chris468.config.LspConfig table<string, chris468.config.LspServer> Map of package name to server config

---@class chris468.config.Tool
---@field filetypes? string[] FileTypes where this tool should be installed and enabled
---@field enabled? boolean Whether to enable the formatter, default true
---@field public package? boolean Whether there is a package associated with the tool
---@field name? string Tool (formatter/dap/etc) name, if different from the package name

return {
  {
    "mason-org/mason.nvim",
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
    "neovim/nvim-lspconfig",
    config = function(_, opts)
      require("chris468.plugins.config.tools").lspconfig(opts)
    end,
    dependencies = { "blink.cmp", optional = true },
    lazy = false,
    keys = {
      { "<leader>cL", cmd("LspInfo"), desc = "LSP info" },
    },
    -- This is custom config (nvim-lspconfig is just data and has no setup)
    ---@type chris468.config.LspConfig
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    config = function(_, opts)
      require("chris468.plugins.config.tools").formatter_config(opts)
    end,
    lazy = false,
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
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Formatters is custom, use it instead of tools.
      -- Outer map is to avoid conflicts, inner maps will be merged.
      ---@type { [string]: { [string]: chris468.config.Tool } }
      formatters = {},
      format_on_save = function(bufnr)
        if vim.g.format_on_save == false or vim.b[bufnr].format_on_save == false then
          return
        end

        return { timeout_ms = 500 }
      end,
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function(_, opts)
      require("chris468.plugins.config.tools").linter_config(opts)
    end,
    dependencies = { "mason.nvim" },
    lazy = false,
    opts = {
      -- Linters is custom, use it instead of tools.
      -- Outer map is to avoid conflicts, inner maps will be merged.
      ---@type { [string]: { [string]: chris468.config.Tool } }
      linters = {},
    },
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
        "<leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.float(widgets.frames)
        end,
        desc = "Frames",
      },
      {
        "<leader>dS",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.float(widgets.scopes)
        end,
        desc = "Scopes",
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
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "plenary.nvim",
      "nvim-treesitter",
      "nvim-neotest/neotest-plenary",
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
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        adapters = {
          require("neotest-plenary"),
        },
      })
    end,
  },
}
