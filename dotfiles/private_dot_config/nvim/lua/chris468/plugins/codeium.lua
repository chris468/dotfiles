return {
  "Exafunction/codeium.nvim",
  cond = require("chris468.config").ai_assistant == "codeium",
  config = function()
    require("codeium").setup({})
  end,
  cmd = {
    "Codeium",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = { "InsertEnter" },
}
