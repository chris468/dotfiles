return {
  "echasnovski/mini.bufremove",
  config = true,
  keys = {
    {
      "<leader>bd",
      function()
        require("mini.bufremove").delete()
      end,
      desc = "Delete current",
    },
  },
}
