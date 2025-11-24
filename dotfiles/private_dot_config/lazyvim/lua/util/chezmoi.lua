local M = {}

---@param source_path? string Source path to apply, or nil to apply all
---@return string
local function chezmoi_apply_command(source_path)
  local command = "apply --no-tty --color=false"
  if source_path then
    command = string.format('%s "$(chezmoi target-path "%s")"', command, source_path)
  end
  return command
end

local function notify_if_modified_buffers()
  local buffers = vim.api.nvim_list_bufs()
  for _, buffer in ipairs(buffers) do
    if vim.bo[buffer].modified then
      vim.notify("Unsaved files will not be applied", vim.log.levels.WARN)
    end
  end
end

local function chezmoi(command, display)
  Snacks.terminal("chezmoi " .. command, {
    win = {
      title = display,
      border = "rounded",
      height = 0.3,
      row = -0.4,
    },
  })
end

---@param what "all"|"current_file"|"current_dir"
function M.apply(what)
  local path, display_name
  if what == "current_file" then
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name or buf_name == "" then
      vim.notify("Can't chezmoi apply file never saved", vim.log.levels.ERROR)
      return
    end

    -- warn if the file was modified
    if vim.bo.modified then
      vim.notify("File has not been saved", vim.log.levels.WARN)
    end

    path = vim.fn.fnamemodify(buf_name, ":p")
    display_name = vim.fn.fnamemodify(buf_name, ":t")
  elseif what == "current_dir" then
    path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
    display_name = #path > 30 and "…" .. path:sub(-30) or path
    notify_if_modified_buffers()
  else
    notify_if_modified_buffers()
  end

  local title = ("Chezmoi apply%s%s"):format(display_name and " " or "", display_name or "")
  chezmoi(chezmoi_apply_command(path), title)
end

---@param apply? boolean
function M.update(apply)
  local command = "update --no-tty --color=false" .. (apply and " --init --apply" or "")
  local title = "Chezmoi update" .. (apply and " and apply" or "")
  print(command)
  chezmoi(command, title)
end

return M
