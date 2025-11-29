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

---@param force? boolean
---@param buf? number
local function notify_if_modified_buffers(force, buf)
  local buffers = buf and { buf } or vim.api.nvim_list_bufs()
  for _, buffer in ipairs(buffers) do
    if vim.bo[buffer].modified then
      vim.notify(
        force and "Unsaved files will not be applied" or "Save files before applying",
        force and vim.log.levels.WARN or vim.log.levels.ERROR
      )
      return force
    end
  end

  return true
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
---@param force? boolean
function M.apply(what, force)
  local path, display_name, buf
  if what == "current_file" then
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name or buf_name == "" then
      vim.notify("Can't chezmoi apply file never saved", vim.log.levels.ERROR)
      return
    end

    path = vim.fn.fnamemodify(buf_name, ":p")
    display_name = vim.fn.fnamemodify(buf_name, ":t")
    buf = vim.api.nvim_get_current_buf()
  elseif what == "current_dir" then
    path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
    display_name = #path > 30 and "…" .. path:sub(-30) or path
  end

  if not notify_if_modified_buffers(force, buf) then
    return
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
