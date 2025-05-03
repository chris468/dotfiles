local additional_filetypes = #Chris468.options.venv.additional_filetypes ~= 0
    and Chris468.options.venv.additional_filetypes
  or false

return {
  {
    "venv-selector.nvim",
    enabled = true,
    ft = function(_, ft)
      if additional_filetypes and ft then
        ft = type(ft) == "table" and ft or { ft }
        ft = vim.list_extend(ft, additional_filetypes)
      end

      return ft
    end,
    keys = function(_, keys)
      if additional_filetypes then
        for _, key in ipairs(keys) do
          if type(key) == "table" and key.ft then
            local ft = type(key.ft) == "table" and key.ft or { key.ft }
            key.ft = vim.list_extend(ft, additional_filetypes)
          end
        end
      end

      return keys
    end,
    opts = {
      settings = {
        options = {
          require_lsp_activation = false,
        },
        search = {
          pipx = false,
        },
      },
    },
  },
}
