---@param old string
---@return fun()
local function callback(old)
  return function()
    vim.notify("Use " .. old, vim.log.levels.WARN)
  end
end

---@param old string
---@param new string
local function deprecated(old, new)
  return { old, callback(new), desc = "which_key_ignore" }
end

return {
  "project.nvim",
  keys = {
    { "<leader>fP", "<cmd>ProjectRoot<cr>", desc = "Set project for current file" },
    deprecated("<leader>p", "<leader>fp"),
    deprecated("<leader>P", "<leader>fP"),
  },
  main = "project_nvim",
  opts = {
    manual_mode = true,
    silent_chdir = false,
    scope_chdir = "tab",
  },
}
