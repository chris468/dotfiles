return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.messages = {
        view = "mini",
      }
      opts.notify = {
        view = "mini",
      }
    end,
  },
}
