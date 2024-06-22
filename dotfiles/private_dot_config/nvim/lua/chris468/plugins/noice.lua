local function redirect_cmdline()
  require("cmp").close()
  require("noice").redirect(vim.fn.getcmdline(), {
    {
      view = "split",
      filter = { event = "msg_show" },
    },
  })
end

return {
  "folke/noice.nvim",
  cond = require("chris468.config").enable_noice,
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    {
      "nvim-telescope/telescope.nvim",
      optional = true,
      keys = {
        { "<leader>fn", "<cmd>NoiceTelescope<cr>", desc = "Recent notifications" },
      },
    },
  },
  keys = {
    "<leader>fn",
    { "<leader>nl", "<cmd>NoiceLast<cr>", desc = "Last" },
    { "<leader>nh", "<cmd>NoiceTelescope<cr>", desc = "History" },
    { "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss" },
    { "<S-CR>", redirect_cmdline, mode = "c", desc = "Redirect command line" },
  },
  opts = {
    cmdline = {
      view = "cmdline",
      format = {
        IncRename = {
          pattern = "^:%s*IncRename%s+",
          icon = "",
          conceal = true,
        },
      },
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "notify",
      view_warn = "mini",
      view_history = "messages",
      view_search = "virtualtext",
    },
    notify = {
      enabled = true,
      view = "mini",
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = false, -- position the cmdline and popupmenu together
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      long_message_to_split = true, -- long messages will be sent to a split
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    routes = {
      {
        filter = {
          any = {
            { event = "msg_show", find = "%d+L, %d+B" },
            { event = "msg_show", find = "; after #%d+" },
            { event = "msg_show", find = "; before #%d+" },
            { event = "msg_show", find = "^Already at oldest change" },
            { event = "msg_show", find = "^search hit .+, continuing at .+$" },
            { event = "msg_show", find = "^E486" },
          },
        },
        view = "mini",
      },
      {
        filter = { event = "notify.warn" },
        view = "notify",
      },
    },
  },
}
