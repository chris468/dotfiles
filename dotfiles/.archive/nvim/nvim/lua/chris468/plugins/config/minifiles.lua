local M = {
  arrow_navigation = false,
  show_hidden = false,
}

local mini_files_action = {
  right = function()
    MiniFiles.go_in({ close_on_file = true })
  end,
  shift_right = function()
    MiniFiles.go_in()
  end,
  left = function()
    MiniFiles.go_out()
  end,
  shift_left = function()
    for _ = 1, vim.v.count1 do
      MiniFiles.go_out()
    end
    MiniFiles.trim_right()
  end,
}

local mini_files_navigation = {
  [false] = {
    ["h"] = mini_files_action.left,
    ["H"] = mini_files_action.shift_left,
    ["l"] = mini_files_action.right,
    ["L"] = mini_files_action.shift_right,
  },
  [true] = {
    ["<Left>"] = mini_files_action.left,
    ["<S-Left>"] = mini_files_action.shift_left,
    ["<Right>"] = mini_files_action.right,
    ["<S-Right>"] = mini_files_action.shift_right,
  },
}

function M.mini_files_filter()
  return function(fs_entry)
    return M.show_hidden or not vim.startswith(fs_entry.name, ".")
  end
end

function M.mini_files_split(direction)
  return function()
    local fs_entry = MiniFiles.get_fs_entry() or {}
    if fs_entry.fs_type ~= "file" then
      return
    end

    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)

    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
end

function M.update_keymaps(buf)
  buf = buf or 0
  if vim.bo[buf].filetype ~= "minifiles" then
    return
  end

  local b = vim.b[buf]
  if b.chris468_mini_files_arrow_navigation == M.arrow_navigation then
    return
  end

  b.chris468_mini_files_arrow_navigation = M.arrow_navigation
  for key, action in pairs(mini_files_navigation[M.arrow_navigation]) do
    vim.keymap.set("n", key, action, { buffer = buf })
  end
  for key, _ in pairs(mini_files_navigation[not M.arrow_navigation]) do
    vim.keymap.set("n", key, key, { buffer = buf, remap = false })
  end
end

function M.toggle_arrow_navigation()
  M.arrow_navigation = not M.arrow_navigation
  M.update_keymaps()
end

function M.toggle_show_hidden()
  M.show_hidden = not M.show_hidden
  MiniFiles.refresh({ content = { filter = M.mini_files_filter() } })
end

return M
