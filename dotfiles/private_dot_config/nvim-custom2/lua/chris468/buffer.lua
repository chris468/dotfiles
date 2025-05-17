local M = {}

---@param bufnr integer
---@return boolean
function M.valid_normal(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ""
end

return M
