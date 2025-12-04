local ai_extras = {}

local ai_extras = vim.tbl_map(function(provider)
  return { import = "lazyvim.plugins.extras.ai." .. provider }
end, type(vim.g.chris468_ai_providers) == "table" and vim.g.chris468_ai_providers or { vim.g.chris468_ai_providers })

if #ai_extras > 0 then
  table.insert(ai_extras, {
    { import = "lazyvim.plugins.extras.ai.sidekick" },
  })
end

return ai_extras
