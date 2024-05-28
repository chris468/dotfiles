local M = {}

function M.highlight(name, opts)
  opts = opts or {}

  local cmd = "highlight"
  if opts.force then
    cmd = cmd .. "!"
  end
  cmd = cmd .. " " .. name
  for k, v in pairs(opts) do
    if k ~= "force" then
      cmd = cmd .. " " .. k .. "=" .. v
    end
  end

  vim.cmd(cmd)
end

function M.regisiter_highlights(augroupname, highlights)
  vim.api.nvim_create_autocmd({ "BufEnter", "ColorScheme" }, {
    group = vim.api.nvim_create_augroup(augroupname, {}),
    callback = function()
      local h = highlights
      for n, o in pairs(h) do
        M.highlight(n, o)
      end
    end,
  })
end

M.trouble = require("chris468.util.trouble")

return M
