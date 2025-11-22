if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end

local override_keys = require("util.lazy").override_keys

---@type LazyPluginSpec[]
return {
  {
    "telescope.nvim",
    keys = override_keys({
      ["<leader>sl"] = "<leader>sL",
    }),
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
