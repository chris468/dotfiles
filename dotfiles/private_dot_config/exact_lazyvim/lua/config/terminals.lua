local M = {}

local terminals = {
  float = {
    opts = { direction = "float", display_name = "Terminal" },
  },
  horizontal = {
    opts = { direction = "horizontal", display_name = "Terminal" },
  },
  vertical = {
    opts = { direction = "vertical", display_name = "Terminal" },
  },
  chezmoi_apply = {
    cmd = "chezmoi apply",
    opts = { direction = "horizontal", display_name = "Chezmoi", remain_on_error = true, warn_on_unsaved = true },
  },
  chezmoi_add = {
    cmd = function()
      return { "chezmoi", "add", vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) }
    end,
    opts = { direction = "horizontal", display_name = "Chezmoi", remain_on_error = true, warn_on_unsaved = true },
  },
}

local function open_terminal(terminal)
  return function()
    require("chris468.terminal").open(terminal.cmd, terminal.opts)
  end
end

for k, v in pairs(terminals) do
  M[k] = open_terminal(v)
end

return M
