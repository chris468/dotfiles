local git_signs = {
  add = { text = "┃" },
  change = { text = "┃" },
  delete = { text = "╻" },
  topdelete = { text = "╹" },
  changedelete = { text = "┃" },
  untracked = { text = "┆" },
}

return {
  {
    "echasnovski/mini.surround",
    keys = {
      "sa",
      "sd",
      "sf",
      "sF",
      "sh",
      "sr",
      "sn",
    },
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
    verion = "*",
  },
  {
    "echasnovski/mini.files",
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open()
        end,
        desc = "Explore",
      },
    },
    opts = {
      mappings = {
        close = "<Esc>",
        go_in_plus = "<Enter>",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    lazy = true,
    opts = {},
    version = false,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },
    keys = {
      { "<leader>gg", "<cmd>G<CR>", desc = "Git (vim-fugitive)" },
    },
  },
  {
    "junegunn/gv.vim",
    cmd = { "GV" },
    dependencies = "vim-fugitive",
  },
  {
    "ruifm/gitlinker.nvim",
    dependencis = "plenary.nvim",
    keys = { { "<leader>gy", mode = { "n", "v" } } },
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
    opts = {
      signs = git_signs,
      signs_staged = git_signs,
    },
  },
}
