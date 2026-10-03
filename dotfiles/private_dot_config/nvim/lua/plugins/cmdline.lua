return {
  {
    "noice.nvim",
    opts = function(_, opts)
      opts.routes = vim.list_extend(opts.routes or {}, {
        -- Output from commands typed on the cmdline goes to a split
        {
          view = "cmdline_output",
          filter = {
            event = "msg_show",
            cmdline = "^:",
            kind = { "shell_cmd", "shell_out", "shell_err", "shell_ret", "echo", "echomsg", "lua_print", "list_cmd" },
          },
        },
        -- Anything else long enough to be truncated in a notification also goes to a split
        { view = "split", filter = { event = "msg_show", min_height = 10 } },
      })
    end,
  },
}
