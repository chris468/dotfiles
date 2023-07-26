vim.o.number = true
vim.o.relativenumber = true

local function temporarily_toggle_relativenumber()
  local win = vim.wo[vim.api.nvim_get_current_win()]
  local old = win.relativenumber
  win.relativenumber = not old
  local timer = vim.loop.new_timer()
  timer:start(
    2000,
    0,
    vim.schedule_wrap(function()
      win.relativenumber = old
    end)
  )
end

vim.keymap.set("n", "<leader>R", temporarily_toggle_relativenumber, { silent = true })
