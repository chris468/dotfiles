return {
  "christoomey/vim-tmux-navigator",
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
  },
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
