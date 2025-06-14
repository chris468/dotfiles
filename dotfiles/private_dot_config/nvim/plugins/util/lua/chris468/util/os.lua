local M = {}

function M.is_windows()
  -- includes 32- and 64-bit
  return vim.fn.has("win32") == 1
end

function M.is_wsl()
  return vim.fn.has("wsl") == 1
end

return M
