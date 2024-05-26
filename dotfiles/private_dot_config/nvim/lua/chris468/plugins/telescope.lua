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
    { "<leader>r", telescope_builtin("resume"), desc = "Resume last search " },
    { "<leader>/", telescope_builtin("live_grep"), desc = "Grep" },
    { '<leader>f"', telescope_builtin("registers"), desc = "Registers" },
    { "<leader>fb", telescope_builtin("buffers"), desc = "Buffers" },
    { "<leader>fg", telescope_builtin("git_files"), desc = "Git files" },
    { "<leader>fh", telescope_builtin("help_tags"), desc = "Help" },
    { "<leader>fr", telescope_builtin("oldfiles"), desc = "Recent files" },
    { "<leader>fT", "<cmd>Telescope<cr>", desc = "Search" },
    { "<leader>f/", telescope_builtin("current_buffer_fuzzy_find"), desc = "Search current buffer" },
    { "<leader>f:", telescope_builtin("command_history"), desc = "Recent commands" },
  },
  lazy = true,
  version = "0.1.x",
}
