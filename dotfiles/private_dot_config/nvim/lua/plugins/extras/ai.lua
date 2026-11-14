local ai_extras = vim.tbl_map(function(provider)
  return { import = "lazyvim.plugins.extras.ai." .. provider }
end, type(vim.g.chris468_ai_providers) == "table" and vim.g.chris468_ai_providers or { vim.g.chris468_ai_providers })

return ai_extras
