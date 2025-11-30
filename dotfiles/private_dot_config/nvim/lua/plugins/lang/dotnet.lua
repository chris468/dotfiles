return {
  "conform.nvim",
  opts = function(_, opts)
    if opts.formatters_by_ft or not opts.formatters_by_ft.cs then
      opts.formatters_by_ft.cs = vim.tbl_filter(function(formatter)
        return formatter ~= "csharpier"
      end, opts.formatters_by_ft.cs)
    end
    return opts
  end,
}
