return {
  "folke/which-key.nvim",
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    local register = opts.register
    if register[1] == nil or register.opts ~= nil then
      register = { register }
    end

    for _, r in ipairs(register) do
      local m, o = r[1] or r.mappings or r, r.opts
      wk.register(m, o)
    end
  end,
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    register = {
      {
        j = { "gj", "Down", opts = { noremap = true } },
        k = { "gk", "Up", opts = { noremap = true } },
        gp = { "Preview" },
        ["<C-A>"] = { "<nop>", "which_key_ignore" }, -- Disable increment, I never use it on purpose
        ["<leader>"] = {
          ["<Esc>"] = {
            function()
              vim.cmd("noh")
              vim.cmd("silent! Noice dismiss")
            end,
            "Clear",
          },
          b = { "Buffer" },
          c = {
            "Code",
            I = { "Info" },
          },
          f = {
            "Find",
            ["?"] = "Grep",
            l = "LSP",
          },
          g = {
            "Git",
            t = { "Toggle" },
          },
          L = { "<cmd>Lazy<cr>", "Lazy" },
          m = { "Ter[m]inal" },
          n = { "Notifications" },
          D = { "Dotfiles" },
        },
      },
      {
        {
          ["<leader>"] = {
            g = { "Git" },
          },
        },
        opts = { mode = "v" },
      },
    },
  },
}
