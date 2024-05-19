local function telescope_builtin(builtin)
  return function()
    require("telescope.builtin")[builtin]()
  end
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader><leader>", telescope_builtin("find_files"), desc = "Find files" },
    { "<leader>/", telescope_builtin("live_grep"), desc = "Grep" },
    { "<leader>r", telescope_builtin("resume"), desc = "Resume last search " },
    { "<leader>fr", telescope_builtin("oldfiles"), desc = "Recent files" },
    { "<leader>fb", telescope_builtin("buffers"), desc = "Buffers" },
    { "<leader>f:", telescope_builtin("command_history"), desc = "Recent commands" },
  },
  lazy = true,
  version = "0.1.x",
}
