local function format()
  local conform = require("conform")
  conform.format({ lsp_fallback = true, timeout_ms = 1500 })
end

local formatters_by_ft = {
  lua = { "stylua" },
  python = { "black" },
  javascript = { { "prettierd", "prettier" } },
}

return {
  "stevearc/conform.nvim",
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = {
        install_for_filetype = { formatter = formatters_by_ft },
      },
    },
  },
  event = "BufWritePre",
  keys = {
    { "<leader>cf", format, desc = "Format" },
    { "<leader>cIf", "<cmd>ConformInfo<cr>", desc = "Formatter" },
  },
  opts = {
    formatters_by_ft = formatters_by_ft,
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 500,
    },
  },
}
