return {
  "lualine.nvim",
  opts = function(_, opts)
    opts.sections.lualine_a = {
      { "fileformat", separator = "", padding = { left = 1, right = 1 } },
      {
        "encoding",
        cond = function()
          return vim.bo.fileencoding ~= "utf-8"
        end,
        padding = { left = 0, right = 1 },
      },
    }
    opts.sections.lualine_x = vim.tbl_filter(function(v)
      if v[1] == require("lazy.status").updates then
        opts.sections.lualine_y = { v }
        return false
      end

      return true
    end, opts.sections.lualine_x)
    opts.sections.lualine_z = {
      { "progress", separator = "", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }
  end,
}
