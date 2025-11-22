local M = {}

---@param overrides {[string]: string}
function M.override_keys(overrides)
  ---@module 'lazy'
  ---@param specs LazyKeysSpec[]
  return function(_, specs)
    for _, spec in ipairs(specs) do
      spec[1] = overrides[spec[1]] or spec[1]
      return specs
    end
  end
end

return M
