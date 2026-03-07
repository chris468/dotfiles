local safe_keymap = require("util.safe_keymap")
local vault = require("util.vault")

local M = {}

local last_query = { "status:pending", "list" }
local default_view = "pending"
local task_buf = nil
local task_bin = nil

local function resolve_taskwarrior_bin()
  if task_bin ~= nil then
    return task_bin
  end

  if vim.fn.executable("taskwarrior") == 1 then
    task_bin = "taskwarrior"
    return task_bin
  end

  if vim.fn.executable("task") == 1 then
    local out = vim.fn.systemlist({ "task", "--version" })
    if vim.v.shell_error == 0 and type(out[1]) == "string" and out[1]:lower():find("taskwarrior", 1, true) then
      task_bin = "task"
      return task_bin
    end
  end

  task_bin = false
  return nil
end

local function has_taskwarrior()
  return resolve_taskwarrior_bin() ~= nil
end

---@param cmd string[]
---@return string[]|nil
local function run_task(cmd)
  local bin = resolve_taskwarrior_bin()
  if not bin then
    vim.notify("Taskwarrior CLI is required (`taskwarrior` or Taskwarrior-compatible `task`)", vim.log.levels.ERROR)
    return nil
  end

  local output = vim.fn.systemlist(vim.list_extend({ bin, "rc.color=off", "rc.defaultwidth=0" }, cmd))
  if vim.v.shell_error ~= 0 then
    vim.notify(("Taskwarrior command failed: %s %s"):format(bin, table.concat(cmd, " ")), vim.log.levels.ERROR)
    if #output > 0 then
      vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
    end
    return nil
  end
  return output
end

---@param lines string[]
---@param title string
local function show_output(lines, title)
  if not lines or #lines == 0 then
    vim.notify(("No task results for %s"):format(title), vim.log.levels.INFO)
    return
  end

  if not task_buf or not vim.api.nvim_buf_is_valid(task_buf) then
    vim.cmd("botright split")
    task_buf = vim.api.nvim_get_current_buf()
    vim.bo[task_buf].buftype = "nofile"
    vim.bo[task_buf].bufhidden = "wipe"
    vim.bo[task_buf].swapfile = false
    vim.bo[task_buf].filetype = "taskwarrior"
    vim.bo[task_buf].modifiable = true
  else
    local win = vim.fn.bufwinid(task_buf)
    if win == -1 then
      vim.cmd("botright split")
      vim.api.nvim_win_set_buf(0, task_buf)
    else
      vim.api.nvim_set_current_win(win)
    end
  end

  vim.bo[task_buf].modifiable = true
  vim.api.nvim_buf_set_lines(task_buf, 0, -1, false, lines)
  vim.bo[task_buf].modifiable = false
  vim.bo[task_buf].modified = false
  vim.api.nvim_buf_set_name(task_buf, ("taskwarrior://%s"):format(title))
end

---@param cmd string[]
---@param title string
local function list_tasks(cmd, title)
  last_query = vim.deepcopy(cmd)
  local output = run_task(cmd)
  if not output then
    return
  end
  show_output(output, title)
end

---@param items any[]
---@param opts table
---@param callback fun(choice: any)
local function ui_select(items, opts, callback)
  vim.ui.select(items, opts, callback)
end

---@param opts table
---@param callback fun(value: string|nil)
local function ui_input(opts, callback)
  vim.ui.input(opts, callback)
end

---@return { id: number, description: string, uuid: string }[]
local function load_active_tasks()
  local output = run_task({ "export" })
  if not output then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(output, "\n"))
  if not ok or type(decoded) ~= "table" then
    return {}
  end

  local items = {}
  for _, task in ipairs(decoded) do
    if type(task) == "table" and task.uuid and task.description and task.status ~= "deleted" and task.status ~= "completed" then
      table.insert(items, {
        id = task.id or 0,
        description = task.description,
        uuid = task.uuid,
      })
    end
  end
  return items
end

---@param callback fun(task: { id: number, description: string, uuid: string }|nil)
local function select_task(callback)
  local items = load_active_tasks()
  if #items == 0 then
    vim.notify("No active tasks found", vim.log.levels.INFO)
    callback(nil)
    return
  end

  ui_select(items, {
    prompt = "Select task",
    format_item = function(item)
      return ("%s: %s"):format(item.id, item.description)
    end,
  }, callback)
end

---@param context string
---@param callback fun()
local function with_vault(context, callback)
  vault.resolve_async({
    context = context,
    allow_prompt = true,
  }, function(path)
    if not path then
      return
    end
    callback()
  end)
end

function M.open_hub()
  with_vault("task hub", function()
    if default_view == "pending" then
      list_tasks({ "status:pending", "list" }, "task-list")
      return
    end
    list_tasks({ "status:pending", "due:today", "list" }, "task-today")
  end)
end

function M.add_task()
  with_vault("add task", function()
    ui_input({
      prompt = "Task description: ",
    }, function(text)
      if not text or text == "" then
        vim.notify("Canceled task creation", vim.log.levels.WARN)
        return
      end
      local output = run_task({ "add", text })
      if not output then
        return
      end
      vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
      M.refresh_view()
    end)
  end)
end

function M.today_tasks()
  with_vault("today tasks", function()
    default_view = "today"
    list_tasks({ "status:pending", "due:today", "list" }, "task-today")
  end)
end

function M.pending_tasks()
  with_vault("pending tasks", function()
    default_view = "pending"
    list_tasks({ "status:pending", "list" }, "task-pending")
  end)
end

function M.refresh_view()
  with_vault("refresh tasks", function()
    list_tasks(last_query, "task-refresh")
  end)
end

function M.toggle_view()
  with_vault("toggle task view", function()
    if default_view == "pending" then
      M.today_tasks()
    else
      M.pending_tasks()
    end
  end)
end

function M.mark_done()
  with_vault("complete task", function()
    select_task(function(task)
      if not task then
        return
      end
      local output = run_task({ task.uuid, "done" })
      if not output then
        return
      end
      vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
      M.refresh_view()
    end)
  end)
end

function M.update_task()
  with_vault("update task", function()
    select_task(function(task)
      if not task then
        return
      end

      ui_select({
        "done",
        "start",
        "stop",
        "annotate",
      }, {
        prompt = ("Update task %s"):format(task.id),
      }, function(action)
        if not action then
          vim.notify("Canceled task update", vim.log.levels.WARN)
          return
        end

        local run_action = function(cmd)
          local output = run_task(cmd)
          if not output then
            return
          end
          vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
          M.refresh_view()
        end

        if action == "annotate" then
          ui_input({
            prompt = "Annotation: ",
          }, function(note)
            if not note or note == "" then
              vim.notify("Canceled annotation", vim.log.levels.WARN)
              return
            end
            run_action({ task.uuid, "annotate", note })
          end)
          return
        end

        run_action({ task.uuid, action })
      end)
    end)
  end)
end

local task_mappings = {
  { candidates = { "<leader>Nk", "<leader>NK" }, desc = "Task hub", action = M.open_hub },
  { candidates = { "<leader>Nka", "<leader>NkA" }, desc = "Add task", action = M.add_task },
  { candidates = { "<leader>Nkt", "<leader>NkT" }, desc = "Today tasks", action = M.today_tasks },
  { candidates = { "<leader>Nku", "<leader>NkU" }, desc = "Update task", action = M.update_task },
  { candidates = { "<leader>Nkd", "<leader>NkD" }, desc = "Mark done", action = M.mark_done },
  { candidates = { "<leader>Nkp", "<leader>NkP" }, desc = "Pending tasks", action = M.pending_tasks },
  { candidates = { "<leader>Nkr", "<leader>NkR" }, desc = "Refresh tasks", action = M.refresh_view },
  { candidates = { "<leader>Nkv", "<leader>NkV" }, desc = "Toggle task view", action = M.toggle_view },
}

local function register_task_keymaps()
  for _, item in ipairs(task_mappings) do
    local mapped = safe_keymap.set_first_available("n", item.candidates, item.action, {
      desc = item.desc,
    })
    if not mapped then
      vim.notify(("Could not map task action: %s"):format(item.desc), vim.log.levels.WARN)
    end
  end
end

return {
  {
    "snacks.nvim",
    optional = true,
    init = function()
      register_task_keymaps()
    end,
  },
}
