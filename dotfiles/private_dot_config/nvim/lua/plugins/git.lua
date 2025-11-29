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
          local file = url_data.file
          local rev = url_data.rev
          local lstart = url_data.lstart
          local lend = url_data.lend
          if not lend or lend == lstart then
            lend = lstart + 1
          end
          return string.format(
            "%s?path=/%s&version=GC%s&line=%d&lineEnd=%d&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
            require("gitlinker.hosts").get_base_https_url(url_data),
            file,
            rev,
            lstart,
            lend
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
