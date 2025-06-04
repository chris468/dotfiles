local M = {}

M.default_globs = {
  "!**/.git/**",
  "!**/node_modules/**",
  "!**/bin/**",
  "!**/obj/**",
  "!**/.venv/**",
}

---@param args string[]
---@param new_args string|string[]
---@param opts? { append?: boolean, flag?: string }
function M.append_args(args, new_args, opts)
  opts = opts or {}
  if opts.append == false then
    return
  end

  new_args = type(new_args) == "table" and new_args or { new_args }
  vim.list_extend(
    args,
    vim
      .iter(new_args)
      :filter(function(v)
        return v and v ~= ""
      end)
      :map(function(v)
        return opts.flag and { opts.flag, v } or v
      end)
      :flatten()
      :totable()
  )
end

---@param find fun(opts: table)
---@param update_opts fun(): table opts
---@return fun()
function M.change_opts(find, update_opts)
  return function()
    local opts = update_opts()
    opts.default_text = require("telescope.actions.state").get_current_line()
    find(opts)
  end
end

return M
