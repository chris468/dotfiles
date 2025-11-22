if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end

---@type LazyPluginSpec[]
return {
  {
    "telescope.nvim",
    keys = {
      { "<leader>sL", "<cmd>Telescope loclist<cr>", desc = "Location List" },
    },
  },
  {
    "tsakirist/telescope-lazy.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("lazy")
      end)
    end,
    keys = {
      { "<leader>sl", "<cmd>Telescope lazy<CR>", desc = "Lazy" },
    },
  },
}
