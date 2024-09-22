return {
  "Exafunction/codeium.nvim",
  cmd = {
    "Codeium",
  },
  cond = function()
    local enable = require("chris468.config").ai_assistant == "codeium"
    local work = require("chris468.config.settings").work
    if enable and work then
      enable = false
      vim.notify("only copilot at work", vim.log.levels.ERROR)
    end

    return enable
  end,
  config = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = { "InsertEnter" },
}
