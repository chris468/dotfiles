return function(parent)
  local libs = {}
  local parent_path = vim.fn.stdpath('config') .. '/lua/' .. string.gsub(parent, '%.', '/')
  for file in vim.fs.dir(parent_path) do
    local lib_name, is_lib = string.gsub(file, '.lua', '')
    if is_lib > 0 then
      libs[lib_name] = require(parent .. '.' .. lib_name)
    end
  end
  return libs
end
