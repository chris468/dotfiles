local git_signs = {
  add = { text = "┃" },
  change = { text = "┃" },
  delete = { text = "╻" },
  topdelete = { text = "╹" },
  changedelete = { text = "┃" },
  untracked = { text = "┆" },
}

local toggle_diffview_keymap = { "n", "<leader>gg", "<cmd>DiffviewClose<CR>", { desc = "Close git (diffview)" } }
local close_diffview_keymap = { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close git (diffview)" } }

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewLog" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen -- %<CR>", desc = "Diff current buffer" },
      { "<leader>gg", "<cmd>DiffviewOpen<CR>", desc = "Git (diffview)" },
      { "<leader>gl", "<cmd>DiffviewFileHistory %<CR>", desc = "Log (current file)" },
      { "<leader>gL", "<cmd>DiffviewFileHistory<CR>", desc = "Log" },
    },
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
    keys = {
      { "<leader>gG", "<cmd>Neogit<CR>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Neogit commit" },
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
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function(_, opts)
      require("gitsigns").setup(opts)
      vim.api.nvim_set_hl(0, "GitSignsChangeDelete", { link = "DiagnosticWarn" })
    end,
    keys = {
      { "<leader>gB", "<cmd>Gitsigns blame<CR>", desc = "Blame buffer" },
      { "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", desc = "Stage buffer" },
      { "<leader>gU", "<cmd>Gitsigns unstage_buffer<CR>", desc = "Untage buffer" },
      { "<leader>gb", "<cmd>Gitsigns blame_line<CR>", desc = "Blame line" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "Preview hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk" },
      { "<leader>gu", "<cmd>Gitsigns unstage_hunk<CR>", desc = "Untage hunk" },
      { "[g", "<cmd>Gitsigns prev_hunk<CR>", desc = "Previous git hunk" },
      { "]g", "<cmd>Gitsigns next_hunk<CR>", desc = "Next git hunk" },
    },
    opts = {
      signs = git_signs,
      signs_staged = git_signs,
    },
  },
}
