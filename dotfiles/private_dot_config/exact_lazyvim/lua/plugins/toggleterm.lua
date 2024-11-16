return {
  {
    "akinsho/toggleterm.nvim",
    cmd = {
      "ToggleTerm",
      "ToggleTermToggleAll",
      "TermExec",
      "TermSelect",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
      "ToggleTermSetName",
    },
    enabled = vim.g.chris468_use_toggleterm,
    opts = function()
      return {
        direction = "float",
        open_mapping = nil, -- handled by chris468.terminal
        float_opts = {
          border = { "", "─", "", "", "", "", "", "" },
          title_pos = "center",
          width = function()
            return vim.o.columns
          end,
          height = function()
            return vim.o.lines - 1
          end,
        },
        size = function(term)
          if term.direction == "horizontal" then
            return vim.o.lines * 0.25
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
      }
    end,
  },
  {
    config = function(_, opts)
      require("chris468.terminal").setup(opts)
    end,
    dir = vim.fn.stdpath("config") .. "/lua/chris468/terminal",
    enabled = vim.g.chris468_use_toggleterm,
    lazy = false,
    opts = {
      toggle_mapping = [[<C-\><C-\>]],
      overrides = {
        function(cmd, opts)
          if cmd == nil then
            opts.display_name = "Terminal"
          end
        end,
        ["'lazygit'"] = function(_, opts)
          opts.display_name = "lazygit"
        end,
        ["^'lazygit' '([^']*)'"] = function(_, opts, match)
          opts.display_name = "lazygit " .. match[1]
        end,
      },
    },
  },
}
