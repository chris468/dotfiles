---@module "lazy"
---@type LazySpec[]
return {
  -- Inline task management within markdown files
  {
    "huantrinh1802/m_taskwarrior_d.nvim",
    ft = "markdown",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      task_statuses = { " ", "x", ">", "!" },
    },
  },
  -- Sidebar panel
  -- {
  --   "duckdm/neowarrior.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   keys = {
  --     { "<leader>NT", "<cmd>NeoWarriorOpen<CR>", desc = "NeoWarrior Panel" },
  --   },
  --   opts = {
  --     bin = "tw",
  --   },
  -- },
}
