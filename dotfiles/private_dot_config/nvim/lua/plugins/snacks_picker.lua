return {
  {
    "snacks.nvim",
    enabled = LazyVim.pick.want() == "snacks",
    keys = {
      {
        "<leader>sR",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
    },
  },
}
