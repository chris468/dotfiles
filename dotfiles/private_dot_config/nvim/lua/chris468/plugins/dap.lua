local adapters_for_ft = {
  python = { "debugpy" },
}

local mappings = {
  ["<F5>"] = {
    function()
      require("dap").continue()
    end,
    desc = "Run",
  },
  ["<S-F5>"] = {
    function()
      require("dap").terminate()
    end,
    desc = "Stop debugging",
  },
  ["<C-S-F5>"] = {
    function()
      require("dap").restart()
    end,
    desc = "Restart debugging",
  },
  ["<F10>"] = {
    function()
      require("dap").step_over()
    end,
    desc = "Step over",
  },
  ["<C-F10>"] = {
    function()
      require("dap").run_to_cursor()
    end,
    desc = "Run to cursor",
  },
  ["<C-S-F10>"] = {
    function()
      require("dap").goto_()
    end,
    desc = "Set next statement",
  },
  ["<F11>"] = {
    function()
      require("dap").step_into()
    end,
    desc = "Step into",
  },
  ["<S-F11>"] = {
    function()
      require("dap").step_out()
    end,
    desc = "Step out",
  },
  ["<F9>"] = {
    function()
      require("dap").toggle_breakpoint()
    end,
    desc = "Toggle breakpoint",
  },
  ["<C-S-F9>"] = {
    function()
      require("dap").clear_breakpoints()
    end,
    desc = "Clear all breakpoints",
  },
  ["<leader>dlp"] = {
    function()
      require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end,
    "Set logpoint",
  },
  ["<leader>dr"] = {
    function()
      require("dap").repl.open()
    end,
    desc = "Open REPL",
  },
  ["<leader>dl"] = {
    function()
      require("dap").run_last()
    end,
    desc = "Run last configuration",
  },
  ["<leader>dh"] = {
    function()
      require("dap.ui.widgets").hover()
    end,
    mode = { "n", "v" },
    desc = "Hover",
  },
  ["<leader>dp"] = {
    function()
      require("dap.ui.widgets").preview()
    end,
    mode = { "n", "v" },
    desc = "Preview",
  },
  ["<leader>df"] = {
    function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.frames)
    end,
    desc = "Frames",
  },
  ["<leader>ds"] = {
    function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.scopes)
    end,
    desc = "Scopes",
  },
}

local function attach()
  local dapui = require("dapui")
  dapui.open()
end

local function detach()
  local dapui = require("dapui")
  dapui.close()
end

return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    local icons = require("chris468.config.icons")

    dap.listeners.before.attach.dapui_config = attach
    dap.listeners.before.launch.dapui_config = attach
    dap.listeners.before.event_terminated.dapui_config = detach
    dap.listeners.before.event_exited.dapui_config = detach

    vim.fn.sign_define("DapBreakpoint", {
      text = icons.debugging.breakpoint,
      texthl = "DapBreakpoint",
      linehl = "chris468.BreakpointLine",
    })
    vim.fn.sign_define(
      "DapBreakpointCondition",
      { text = icons.debugging.conditional_breakpoint, texthl = "DapBreakpoint" }
    )
    vim.fn.sign_define("DapLogPoint", { text = icons.debugging.logpoint, texthl = "DapLogPoint" })
    vim.fn.sign_define(
      "DapStopped",
      { text = icons.debugging.stopped, texthl = "chris468.StoppedIcon", linehl = "chris468.StoppedLine" }
    )
    vim.fn.sign_define("DapBreakpointRejected", { text = icons.debugging.breakpoint, texthl = "Comment" })
  end,
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
      dependencies = { "nvim-neotest/nvim-nio" },
      opts = {},
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
  keys = function(_, keys)
    keys = keys or {}
    for key, mapping in pairs(mappings) do
      local m = vim.deepcopy(mapping)
      table.insert(m, 1, key)
      table.insert(keys, m)
    end
  end,
}
