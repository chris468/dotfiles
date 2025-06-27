local util = require("chris468.util")
local util_lazy = require("chris468.util.lazy")
local cmd = require("chris468.util.keymap").cmd
local os = require("chris468.util.os")

local have_zoxide = vim.fn.executable("zoxide") == 1

local function configure_select()
  local original = vim.ui.select
  local M = {}
  function M.select(...)
    _ = require("telescope")
    if vim.ui.select == M.select then
      vim.ui.select = original
    end

    return vim.ui.select(...)
  end

  vim.ui.select = M.select
end

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
      "telescope-fzf-native.nvim",
      {
        "nvim-telescope/telescope-ui-select.nvim",
        config = configure_select(),
      },
    },
    keys = function()
      local keys = {
        { "<leader>/", require("chris468.plugins.config.search.rg"), desc = "Live grep" },
        { "<leader><leader>", require("chris468.plugins.config.search.fd"), desc = "Files" },
        { "<leader>fb", cmd("Telescope buffers"), desc = "Buffers" },
        { "<leader>fg", cmd("Telescope git_status"), desc = "Git changes" },
        { "<leader>fr", cmd("Telescope oldfiles"), desc = "Recent files" },
        { "<leader>r", cmd("Telescope resume"), desc = "Resume last search" },
        { "<leader>sh", cmd("Telescope help_tags"), desc = "Help" },
        { "<leader>sl", cmd("Telescope lazy"), desc = "Lazy" },
        { "<leader>sH", cmd("Telescope highlights"), desc = "Highlights" },
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
        fzf = {},
        noice = {
          enabled = util_lazy.has_plugin("noice.nvim"),
        },
        lazy = {
          mappings = {
            change_cwd_to_plugin = "<C-w>",
            open_plugins_picker = "<C-o>",
          },
          actions_opts = {
            change_cwd_to_plugin = {
              auto_close = true,
            },
          },
        },
        terraform_doc = {},
        ["ui-select"] = {
          layout_strategy = "center",
        },
        zoxide = {
          enabled = have_zoxide,
        },
      },
      pickers = {
        buffers = {
          mappings = {
            n = {
              ["<BS>"] = "delete_buffer",
            },
          },
        },
      },
    },
    version = false,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = os.is_windows() and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
      or "make",
    enabled = not os.is_windows() or vim.fn.executable("cmake") == 1,
  },
}
