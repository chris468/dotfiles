local toggle_diffview_keymap = { "n", "<leader>gg", "<cmd>DiffviewClose<cr>", { desc = "Close git (diffview)" } }
local close_diffview_keymap = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close git (diffview)" } }

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewLog" },
    opts = {
      keymaps = {
        view = { toggle_diffview_keymap },
        file_panel = { toggle_diffview_keymap, close_diffview_keymap },
        file_history_panel = { toggle_diffview_keymap, close_diffview_keymap },
      },
    },
    version = false,
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "diffview.nvim" },
    cmd = "Neogit",
    opts = {
      remember_settings = false,
    },
  },
  {
    "ruifm/gitlinker.nvim",
    dependencis = "plenary.nvim",
    keys = { { "<leader>gy", desc = "Copy link", mode = { "n", "v" } } },
    opts = {
      callbacks = {
        ["dev.azure.com"] = function(url_data)
          return string.format(
            "%s?path=/%s&version=GC%s&line=%d&lineEnd=%d&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
            require("gitlinker.hosts").get_base_https_url(url_data),
            url_data.file,
            url_data.rev,
            url_data.lstart,
            url_data.lend or url_data.lstart + 1
          )
        end,
      },
      opts = {
        action_callback = function(url)
          require("gitlinker.actions").copy_to_clipboard(url)
          vim.notify("Url on clipboard", nil, { title = "gitlinker" })
        end,
        print_url = false,
      },
    },
  },
}
