return {
  filetypes = { "toggleterm" },
  sections = {
    lualine_a = { "chris468.mode" },
    lualine_b = {
      function()
        local t = require("toggleterm.terminal")
        local terminal = t.get(vim.b.toggle_number)

        if not terminal then
          return "Terminal"
        end

        return " " .. terminal.display_name or ("Terminal #" .. vim.b.toggle_number)
      end,
    },
  },
}
