-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

require("chris468.terminal").setup({
  toggle_mapping = [[<C-\><C-\>]],
  overrides = {
    function(cmd, opts)
      if cmd == nil then
        opts.display_name = "Terminal"
      end
    end,
    ["'lazygit'"] = function(_, opts)
      opts.display_name = "lazygit"
    end,
    ["^'lazygit' '([^']*)'"] = function(_, opts, match)
      opts.display_name = "lazygit " .. match[1]
    end,
  },
})
