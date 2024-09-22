return {
  "Exafunction/codeium.nvim",
  cmd = {
    "Codeium",
  },
  cond = require("chris468.config").is_ai_assistant_enabled("codeium"),
  config = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  opts = {
    enable_chat = true,
  },
  event = { "InsertEnter" },
}
