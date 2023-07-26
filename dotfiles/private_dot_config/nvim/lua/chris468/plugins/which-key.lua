local function find_git_files()
  local ok, tbi = pcall(require, "telescope.builtin")
  if not ok then return end

  ok = pcall(tbi.git_files)
  if not ok then
    tbi.find_files()
  end
end

local function setup(_)
  local wk = require("which-key")
  wk.setup {}
  wk.register({
    f = {
      name = "Find",
      F = { ":Telescope find_files<CR>", "Files" },
      b = { ":Telescope buffers<CR>", "Buffer"},
      f = { find_git_files, "Git files (if in git repo)" },
      r = { ":Telescope oldfiles<CR>", "Recent files" },
    },
    e = { ":NvimTreeToggle<CR>", "Explorer" },
  }, { prefix = "<leader>", silent = true })
end

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 1000
  end,
  config = setup
}
