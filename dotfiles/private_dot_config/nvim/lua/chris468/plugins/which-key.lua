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
        ["<C-A>"] = { "<nop>", "which_key_ignore" }, -- Disable increment, I never use it on purpose
        ["<leader>"] = {
          b = { "Buffer" },
          c = {
            "Code",
            i = { "Info" },
          },
          f = { "Find" },
          g = {
            "Git",
            t = { "Toggle" },
          },
          i = { "Icons" },
          m = { "Ter[m]inal" },
          n = { "Notifications" },
          p = {
            "Packages",
            l = { "<cmd>Lazy<cr>", "Lazy" },
          },
          D = {
            "Dotfiles",
            a = { "<cmd>!chezmoi apply<CR>", "Apply dotfiles" },
            A = { "<cmd>!chezmoi add %<CR>", "Add current file to dotfiles" },
          },
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
