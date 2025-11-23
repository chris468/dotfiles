if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end

---@type LazyPluginSpec[]
return {
  {
    "telescope.nvim",
    opts = {},
  },
  {
    "tsakirist/telescope-lazy.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("lazy")
      end)
    end,
  },
}
