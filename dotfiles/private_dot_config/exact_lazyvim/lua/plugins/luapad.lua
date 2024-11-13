return {
  "rafcamlet/nvim-luapad",
  cmd = {
    "Luapad",
    "LuaRun",
    "Lua",
  },
  config = function(_, opts)
    require("luapad").setup(opts)
    vim.api.nvim_create_user_command("Luapad", function()
      require("chris468.luapad").toggle()
    end, { force = true })
  end,
  keys = {
    {
      "<leader>ml",
      "<cmd>Luapad<cr>",
      desc = "Lua REPL",
    },
  },
  opts = {
    eval_on_change = false,
    eval_on_move = false,
  },
  version = false,
}
