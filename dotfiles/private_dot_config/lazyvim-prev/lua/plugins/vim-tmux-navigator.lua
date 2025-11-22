---@param key string
---@param cmd_when_split string|fun(terminal: snacks.terminal)
---@param desc string
---@return snacks.win.Keys
local function split_term_mapping(key, cmd_when_split, desc)
  local function callback(terminal)
    return terminal:is_floating() and key or cmd_when_split
  end

  return { key, callback, desc = desc, expr = true, mode = "t" }
end

return {
  {
    "christoomey/vim-tmux-navigator",
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
  },
  {
    "snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_h = split_term_mapping("<C-h>", "<cmd>TmuxNavigateLeft<cr>", "Move to window on left"),
            nav_j = split_term_mapping("<C-j>", "<cmd>TmuxNavigateDown<cr>", "Move to window below"),
            nav_k = split_term_mapping("<C-k>", "<cmd>TmuxNavigateUp<cr>", "Move to window above"),
            nav_l = split_term_mapping("<C-l>", "<cmd>TmuxNavigateRight<cr>", "Move to window on right"),
          },
        },
      },
    },
  },
}
