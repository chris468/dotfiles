return {
  filetypes = { "toggleterm" },
  sections = {
    lualine_a = {
      function()
        local t = require("toggleterm.terminal")
        local terminal = t.get(vim.b.toggle_number)
        return " " .. terminal.display_name or ("Terminal #" .. vim.b.toggle_number)
      end,
    },
  },
}
