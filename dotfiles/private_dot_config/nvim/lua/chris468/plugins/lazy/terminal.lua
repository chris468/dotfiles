local function toggle()
  require("toggleterm").toggle(vim.v.count1, nil, nil, nil, ("Terminal %s"):format(vim.v.count1))
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "TermExec", "TermSelect", "ToggleTerm", "ToggleTermToggleAll" },
    keys = {
      { "<C-/>", toggle, desc = "Toggle term", mode = { "n", "i", "t" } },
      { "<C-_>", toggle, desc = "Toggle term", mode = { "n", "i", "t" } },
    },
    opts = {},
  },
}
