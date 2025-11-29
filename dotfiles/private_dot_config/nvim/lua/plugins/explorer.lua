return {
  {
    -- TODO: snacks-rename integration
    "stevearc/oil.nvim",
    dependencies = { "mini.icons" },
    cmd = "Oil",
    keys = {
      {
        "<leader>fo",
        function()
          local root = LazyVim.root({ normalize = true })
          require("oil").toggle_float(root)
        end,
        desc = "Oil explorer (root dir) ",
      },
      {
        "<leader>fO",
        function()
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          require("oil").toggle_float(cwd)
        end,
        desc = "Oil explorer (cwd) ",
      },
    },
    opts = {
      float = {
        border = "rounded",
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = false,
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
        q = "actions.close",
        ["<esc>"] = "actions.close",
      },
    },
  },
}
