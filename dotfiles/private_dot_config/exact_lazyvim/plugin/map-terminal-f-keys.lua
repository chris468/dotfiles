local function F(n)
  return "F" .. n
end

local function Shift(k)
  return "S-" .. k
end

local function Control(k)
  return "C-" .. k
end

local function Wrap(k)
  return "<" .. k .. ">"
end

for k = 1, 12 do
  -- s-f10: <F22>
  -- c-f10: <F34>
  -- c-s-f10: <F46>

  vim.api.nvim_set_keymap("", Wrap(F(k + 12)), Wrap(Shift(F(k))), { desc = "which_key_ignore" })
  vim.api.nvim_set_keymap("", Wrap(F(k + 24)), Wrap(Control(F(k))), { desc = "which_key_ignore" })
  vim.api.nvim_set_keymap("", Wrap(F(k + 36)), Wrap(Control(Shift(F(k)))), { desc = "which_key_ignore" })
end
