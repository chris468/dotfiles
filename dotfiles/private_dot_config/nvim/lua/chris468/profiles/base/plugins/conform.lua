return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts["yaml.ansible"] = { "prettier" }
  end,
}
