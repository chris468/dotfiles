local function restart_last()
  local overseer = require("overseer")
  local task_list = require("overseer.task_list")
  local tasks = overseer.list_tasks({
    status = {
      overseer.STATUS.SUCCESS,
      overseer.STATUS.FAILURE,
      overseer.STATUS.CANCELED,
    },
    sort = task_list.sort_finished_recently,
  })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks have been run yet", vim.log.levels.INFO)
    vim.cmd.OverseerRun()
  else
    local most_recent = tasks[1]
    overseer.run_action(most_recent, "restart")
  end
end

return {
  {
    "overseer.nvim",
    optional = true,
    keys = {
      {
        "<leader>oO",
        restart_last,
        desc = "Restart last task",
      },
    },
    opts = function(_, opts)
      local task_list = opts.task_list or {}
      opts.task_list = task_list
      if task_list.bindings and not task_list.keymaps then
        task_list.keymaps = task_list.bindings
      end

      task_list.keymaps = vim.tbl_extend("keep", {
        R = { "keymap.run_action", opts = { action = "restart" }, desc = "Restart task" },
      }, task_list.keymaps or {})

      task_list.min_height = { 8, 0.2 }
    end,
  },
}
