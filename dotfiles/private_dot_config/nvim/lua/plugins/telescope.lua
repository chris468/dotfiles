return {
  "telescope.nvim",
  dependencies = {
    {
      "tsakirist/telescope-lazy.nvim",
      config = function()
        local actions = require("telescope._extensions.lazy.actions")

        actions.show_configuration = function()
          local state = require("telescope.actions.state")
          local util = require("chris468.util")
          local util_lazy = require("chris468.util.lazy")

          local entry = state.get_selected_entry()
          if not entry then
            return
          end

          local opts = util_lazy.get_plugin_opts(entry.value.name)
          util.show_in_readonly_popup(vim.inspect(opts))
        end
      end,
    },
  },
  enabled = LazyVim.pick.want() == "telescope",
  keys = {
    { "<leader>sL", "<cmd>Telescope lazy<CR>", desc = "Lazy plugins" },
    { "<leader>r", "<cmd>Telescope resume<CR>", desc = "Resume last search " },
  },
  opts = {
    defaults = {
      layout_strategy = "vertical",
    },
    extensions = {
      lazy = {
        mappings = {
          change_cwd_to_plugin = "<C-w>",
          open_plugins_picker = "<C-o>",
          show_configuration = "<C-s>",
        },
        actions_opts = {
          change_cwd_to_plugin = {
            auto_close = true,
          },
          show_configuration = {
            auto_close = true,
          },
        },
      },
    },
  },
}
