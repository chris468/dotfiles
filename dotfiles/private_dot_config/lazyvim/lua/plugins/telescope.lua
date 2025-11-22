if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end

---@type LazyPluginSpec[]
return {
  {
    "telescope.nvim",
    keys = function(_, keys)
      vim.tbl_filter(function(v)
        return v[1] ~= "<leader>sl"
      end, keys)

      table.insert(keys, { "<leader>sL", "<cmd>Telescope loclist<cr>", desc = "Location List" })

      return keys
    end,
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
