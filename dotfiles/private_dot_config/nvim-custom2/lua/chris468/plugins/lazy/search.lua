local util = require("chris468.util")
local util_lazy = require("chris468.util.lazy")
local cmd = require("chris468.util.keymap").cmd

local have_zoxide = vim.fn.executable("zoxide") == 1

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      for k, v in pairs(opts.extensions or {}) do
        if v.auto_load ~= false then
          pcall(telescope.load_extension, k)
        end
      end
    end,
    dependencies = {
      "plenary.nvim",
      "noice.nvim",
      "ANGkeith/telescope-terraform-doc.nvim",
      "jvgrootveld/telescope-zoxide",
      "tsakirist/telescope-lazy.nvim",
    },
    keys = function()
      local keys = {
        { "<leader>/", require("chris468.plugins.config.search.rg"), desc = "Live grep" },
        { "<leader><leader>", require("chris468.plugins.config.search.fd"), desc = "Files" },
        { "<leader>fb", cmd("Telescope buffers"), desc = "Buffers" },
        { "<leader>fr", cmd("Telescope oldfiles"), desc = "Recent files" },
        { "<leader>r", cmd("Telescope resume"), desc = "Resume last search" },
        { "<leader>sh", cmd("Telescope highlights"), desc = "Highlights" },
        { "<leader>sk", cmd("Telescope keymaps"), desc = "Key maps" },
        { "<leader>sT", cmd("Telescope terraform_doc"), desc = "Terraform docs" },
        { "<leader>su", require("chris468.plugins.config.search.unicode"), desc = "Unicode symbols" },
        {
          "<C-R><C-U>",
          util.wrap(require("chris468.plugins.config.search.unicode"), { mode = "i" }),
          desc = "Unicode symbols",
          mode = "i",
        },
        { "<leader>uC", cmd("Telescope colorschemes"), desc = "Change color scheme" },
      }

      if have_zoxide then
        table.insert(keys, { "<leader>fz", cmd("Telescope zoxide list"), desc = "Zoxide" })
      end

      return keys
    end,
    opts = {
      defaults = {
        dynamic_preview_title = true,
        layout_config = {
          prompt_position = "top",
          mirror = true,
        },
        mappings = {
          i = {
            ["<C-d>"] = "results_scrolling_down",
            ["<C-u>"] = "results_scrolling_up",
            ["<C-f>"] = "nop",
            ["<C-k>"] = "nop",
            ["<M-f>"] = "nop",
            ["<M-k>"] = "nop",
            ["<M-q>"] = "nop",
          },
          n = {
            ["<C-d>"] = "results_scrolling_down",
            ["<C-u>"] = "results_scrolling_up",
            ["<C-f>"] = "nop",
            ["<C-k>"] = "nop",
            ["<M-f>"] = "nop",
            ["<M-k>"] = "nop",
          },
        },
        layout_strategy = "vertical",
        sorting_strategy = "ascending",
      },
      extensions = {
        noice = {
          enabled = util_lazy.has_plugin("noice.nvim"),
        },
        terraform_doc = {},
        lazy = {},
        zoxide = {
          enabled = have_zoxide,
        },
      },
    },
    version = false,
  },
}
