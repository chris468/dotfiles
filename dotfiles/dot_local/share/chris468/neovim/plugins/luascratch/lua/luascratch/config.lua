local M = {}

---@class chris468.luascratch.config
local defaults = {
  ---@type { input?: snacks.win.Keys[], output?: snacks.win.Keys[] }
  mappings = {
    input = {
      ["<C-J>"] = "output",
      ["<C-K>"] = "output",
      ["<localleader><localleader>"] = { "run", mode = { "n", "v" } },
      ["<localleader><cr>"] = "run_current_line",
      ["<localleader>c"] = { "clear_output", mode = { "n", "v" } },
    },
    output = {
      ["<C-J>"] = "input",
      ["<C-K>"] = "input",
      ["<localleader><localleader>"] = { "run", mode = { "n", "v" } },
      ["<localleader><cr>"] = "run_current_line",
      ["<localleader>c"] = { "clear_output", mode = { "n", "v" } },
      q = "hide_output",
    },
  },
}

M.opts = vim.deepcopy(defaults)

---@param opts chris468.luascratch.config
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)
end

return M
