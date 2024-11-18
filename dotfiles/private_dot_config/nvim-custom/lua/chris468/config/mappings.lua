local M = {}

--- @param modes string|string[]
--- @param lhs string
--- @param rhs string|function
--- @param opts table?
function M.set_keymap(modes, lhs, rhs, opts)
  opts = opts or {}
  if opts.callbaack ~= nil then
    error("use rhs, not opts.callback")
  end

  if type(modes) == "string" then
    modes = { modes }
  end

  local callback
  if type(rhs) == "function" then
    callback = rhs
    rhs = ""
  end

  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend("error", opts, { callback = callback }))
  end
end

local set_keymap = M.set_keymap

function M.setup()
  set_keymap("n", "<C-a>", "<nop>")

  set_keymap({ "n", "v" }, "j", "gj", { desc = "Down", noremap = true })
  set_keymap({ "n", "v" }, "k", "gk", { desc = "Up", noremap = true })
  set_keymap("n", "<leader><Esc>", function()
    vim.cmd("noh")
    vim.cmd("silent! Noice dismiss")
  end, { desc = "Clear" })
end

return M
