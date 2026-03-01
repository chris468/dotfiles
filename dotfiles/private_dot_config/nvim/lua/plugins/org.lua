local org_util = require("util.org")

---@module 'lazy'
---@type LazyPluginSpec[]
return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    cmd = { "Org" },
    keys = {
      { "<Leader>NO", org_util.select_org_path, desc = "Select path" },
    },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          if type(opts.ensure_installed) == "table" and not vim.tbl_contains(opts.ensure_installed, "org") then
            table.insert(opts.ensure_installed, "org")
          end
        end,
      },
    },
    opts = {
      mappings = {
        prefix = "<Leader>N",
      },
      ui = {
        input = {
          use_vim_ui = true,
        },
        menu = {
          handler = org_util.org_menu_handler,
        },
      },
    },
  },
}
