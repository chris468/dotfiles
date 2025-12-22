local disable_prettier_for = {
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
}
return {
  {
    "conform.nvim",
    opts = function(_, opts)
      for _, ft in ipairs(disable_prettier_for) do
        if opts.formatters_by_ft and opts.formatters_by_ft[ft] then
          opts.formatters_by_ft[ft] = vim.tbl_filter(function(formatter)
            return formatter ~= "prettier"
          end, opts.formatters_by_ft[ft])
        end
      end
      return opts
    end,
  },
}
