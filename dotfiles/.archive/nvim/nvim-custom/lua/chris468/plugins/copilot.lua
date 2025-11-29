local enable = require("chris468.config").is_ai_assistant_enabled("copilot")

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = {
      "Copilot",
    },
    cond = enable,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    event = { "InsertEnter" },
    opts = {
      suggestion = { enable = false },
      panel = { enable = false },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = enable and { "zbirenbaum/copilot-cmp" } or {},
  },
  {
    "zbirenbaum/copilot-cmp",
    cond = enable,
    config = true,
    dependencies = "copilot.lua",
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatStop",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatDebugInfo",
      "CopilotChatModels",
      "CopilotChatModel",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatFixDiagnostic",
      "CopilotChatCommit",
      "CopilotChatCommitStaged",
    },
    cond = enable,
    config = function(_, opts)
      require("CopilotChat.integrations.cmp").setup()
      require("CopilotChat").setup(opts)
    end,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = vim.uv.os_uname().sysname:lower() ~= "windows_nt" and "make tiktoken" or {},
    opts = {},
  },
}
