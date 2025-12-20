return {
  {
    "overseer.nvim",
    optional = true,
    opts = function(_, opts)
      local task_list = opts.task_list or {}
      if task_list.bindings and not task_list.keymaps then
        task_list.keymaps = task_list.bindings
      end
    end,
  },
}
