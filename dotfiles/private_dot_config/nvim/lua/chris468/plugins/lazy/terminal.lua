local function toggle_terminal()
  require("chris468.util.terminal").toggle({ count = vim.v.count1 })
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "TermExec", "TermSelect", "ToggleTerm", "ToggleTermToggleAll" },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local t = require("chris468.util.terminal")
      vim.api.nvim_create_autocmd("Filetype", {
        callback = function(arg)
          local bufnr = arg.buf
          if vim.b[bufnr].chris468_terminal_mappings == nil then
            t.enable_mappings(bufnr)
          end
        end,
        group = vim.api.nvim_create_augroup("chris468.toggleterm", { clear = true }),
        pattern = "toggleterm",
      })
    end,
    keys = {
      { "<C-/>", toggle_terminal, desc = "Toggle term", mode = { "n", "i", "t" } },
      { "<C-_>", toggle_terminal, desc = "Toggle term", mode = { "n", "i", "t" } },
      {
        [[<C-\><C-R>]],
        function()
          return [[<C-\><C-N>"]]
            .. vim.fn.nr2char(vim.fn.getchar() --[[@as integer ]])
            .. "pi"
        end,
        desc = "Registers",
        expr = true,
        mode = "t",
      },
    },
    opts = {},
  },
}
