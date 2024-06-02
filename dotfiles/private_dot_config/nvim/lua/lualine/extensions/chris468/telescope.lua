return {
  filetypes = { "TelescopePrompt" },
  sections = {
    lualine_a = {
      function()
        local state = require("telescope.actions.state")
        local buf = vim.api.nvim_get_current_buf()
        local picker = state.get_current_picker(buf)
        local name = vim.trim(picker.prompt_prefix or "")
        name = name .. (#name and " " or "") .. (picker.prompt_title or " ")

        return name
      end,
    },
    lualine_b = {
      function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:~")
      end,
    },
    lualine_z = {
      function()
        return " Telescope"
      end,
    },
  },
}
