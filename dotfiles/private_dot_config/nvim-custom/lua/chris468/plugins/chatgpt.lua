return {
  "jackMort/ChatGPT.nvim",
  cond = require("chris468.config").is_ai_assistant_enabled("chatgpt"),
  config = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
  event = "VeryLazy",
  opts = {
    api_key_cmd = "gpg --decrypt " .. vim.fn.expand("$HOME/.secrets/openapi.key.txt.gpg"),
  },
}
