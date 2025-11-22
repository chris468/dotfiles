return {
  "Ramilito/kubectl.nvim",
  opts = {},
  cmd = { "Kubectl", "Kubectx", "Kubens" },
  keys = {
    {
      "<leader>k",
      function()
        require("kubectl").toggle({})
      end,
      "Kubectl",
    },
  },
}
