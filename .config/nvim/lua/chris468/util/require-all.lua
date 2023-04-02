local function filter_libs(files_iter, initial_state)
  local function iter(state)
    while true do
      local name, _ = files_iter(state)
      if name == nil then break end
      local lib_name, is_lib = string.gsub(name, '.lua', '')
      if is_lib > 0 then return lib_name end
    end
  end
  return iter, initial_state
end

local function enumerate_libs(parent)
  local libs = {}
  local parent_path = vim.fn.stdpath('config') .. '/lua/' .. string.gsub(parent, '%.', '/')
  for lib in filter_libs(vim.fs.dir(parent_path)) do
    table.insert(libs, lib)
  end
  table.sort(libs)
  return libs
end

local function load_libs(parent)
  local libs = enumerate_libs(parent)
  local loaded = {}
  for _, lib in ipairs(libs) do
    loaded[lib] = require(parent .. '.' .. lib)
  end
  return loaded
end

return load_libs
