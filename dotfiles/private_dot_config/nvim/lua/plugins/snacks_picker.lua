return {
  {
    "snacks.nvim",
    enabled = LazyVim.has_extra("editor.snacks_picker"),
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
