local getenv = require("os").getenv
local cmd = require("chris468.util.keymap").cmd

local require_on_call = require("lazy-require").require_on_exported_call
local dap_call = require_on_call("dap")
local dap_widgets_call = require_on_call("dap.ui.widgets")
local dap_ui_call = require_on_call("dapui")

local function smart_end_session()
  local session = dap_call.session()
  if not (session and session.config) then
    vim.notify(vim.inspect({ session = vim.inspect(session), config = vim.inspect((session or {}).config) }))
    return
  end

  if session.config.request == "attach" then
    dap_call.disconnect()
  else
    dap_call.terminate()
  end
end

local dap_key_spec = {
  [{ "<leader>db", "<F9>" }] = { dap_call.toggle_breakpoint, desc = "Toggle breakpoint" },
  ["<leader>dh"] = { dap_widgets_call.hover, mode = { "n", "v" }, desc = "Hover" },
  [{ "<leader>di", "<F11>" }] = { dap_call.step_into, desc = "Step in" },
  ["<leader>dl"] = { dap_call.run_last, desc = "Run last configuration" },
  [{ "<leader>do", "<F10>" }] = { dap_call.step_over, desc = "Step over" },
  [{ "<leader>dO", "<S-F11>" }] = { dap_call.step_out, desc = "Step out" },
  ["<leader>dp"] = { dap_widgets_call.preview, mode = { "n", "v" }, desc = "Preview" },
  [{ "<leader>dr", "<F5>" }] = { dap_call.continue, desc = "Run/Continue" },
  ["<leader>dR"] = { dap_call.repl_toggle, desc = "Toggle REPL" },
  ["<leader>du"] = { dap_ui_call.toggle, desc = "Toggle UI" },
  [{ "<leader>dx", "<S-F5>" }] = { smart_end_session, desc = "End session" },
  ["<leader>d<C-T>"] = { dap_call.terminate, desc = "Terminate" },
  ["<leader>d<C-D>"] = { dap_call.disconnect, desc = "Disconnect" },
}

local function dap_keys()
  local specs = {}
  for keys, spec in pairs(dap_key_spec) do
    keys = type(keys) == "string" and { keys } or keys
    ---@cast keys string[]
    for _, key in ipairs(keys) do
      table.insert(
        specs,
        vim.iter(spec):fold({}, function(t, k, v)
          if k == 1 then
            t[1] = key
            t[2] = v
          else
            t[k] = v
          end
          return t
        end)
      )
    end
  end

  return specs
end

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
    keys = dap_keys(),
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
