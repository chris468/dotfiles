local packages = require("tests.utils.lua_registry._packages").names

local index = vim.iter(packages):fold({}, function(result, pkg)
  result[pkg] = "tests.utils.lua_registry." .. pkg
  return result
end)

return index
