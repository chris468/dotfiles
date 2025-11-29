local util = require("chris468.util")

return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  config = function(_, opts)
    for category, install_for_filetype in pairs(opts.install_for_filetype) do
      util.mason.lazy_install_for_filetype(install_for_filetype, "install " .. category .. " packages")
    end
    require("mason").setup(opts)
  end,
  dependencies = {
    { "folke/noice.nvim" },
  },
  keys = { { "<leader>M", "<cmd>Mason<cr>", desc = "Mason" } },
  opts = {
    install_for_filetype = {} --[[@as {[string]: chris468.util.mason.ToolsForFiletype}]],
    log_level = vim.log.levels.TRACE,
    registries = {
      "lua:chris468.mason.registry",
      "github:mason-org/mason-registry",
    },
  },
}
