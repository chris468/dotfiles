local M = {}

---@generic TConfig
---@generic TTool : Tool
---@param opts  { [string]: { [string]: TConfig } }
---@param Tool TTool
---@return { [string]: TTool[] } tools_by_ft, { [string] : string[] } names_by_ft
function M.map_tools_by_filetype(opts, Tool)
  local function empty()
    return {}
  end
  local tools_by_ft = vim.defaulttable(empty)
  local names_by_ft = vim.defaulttable(empty)

  for _, configs in pairs(opts) do
    for name, config in pairs(configs) do
      local tool = Tool:new(name, config)
      if tool.enabled then
        for _, ft in ipairs(tool:filetypes()) do
          table.insert(tools_by_ft[ft], tool)
          table.insert(names_by_ft[ft], tool:name())
        end
      end
    end
  end

  return tools_by_ft, names_by_ft
end

return M
