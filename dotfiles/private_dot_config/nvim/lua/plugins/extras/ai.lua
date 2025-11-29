local ai_extras = {}

local providers = vim.g.chris468_ai_providers
providers = type(providers) == "table" and providers or { providers }
for _, provider in ipairs(providers) do
  table.insert(ai_extras, {
    { import = "lazyvim.plugins.extras.ai." .. provider },
  })
end

return ai_extras
