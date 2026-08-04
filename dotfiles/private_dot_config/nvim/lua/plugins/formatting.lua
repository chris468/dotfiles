---@class chris468.plugins.formatting
---@field action "disable"|"only"
---@field formatter string
---@field filetypes string[]

---@type chris468.plugins.formatting[]
local config = {
  {
    action = "disable",
    formatter = "prettier",
    filetypes = {
      "html",
      "htmlangular",
      "css",
      "scss",
      "less",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
    },
  },
  {
    action = "only",
    formatter = "prettier",
    filetypes = {
      "markdown",
    },
  },
}

return {
  {
    "conform.nvim",
    opts = function(_, opts)
      for _, conf in ipairs(config) do
        if conf.action == "disable" then
          for _, ft in ipairs(conf.filetypes) do
            opts.formatters_by_ft[ft] = vim.tbl_filter(function(formatter)
              return formatter ~= conf.formatter
            end, opts.formatters_by_ft[ft] or {})
          end
        elseif conf.action == "only" then
          for _, ft in ipairs(conf.filetypes) do
            opts.formatters_by_ft[ft] = { conf.formatter }
          end
        end
      end
      return opts
    end,
  },
}
