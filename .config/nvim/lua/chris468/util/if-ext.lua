return function(ext_names, callback, fail_callback)

  local single = type(ext_names) == 'string'
  if single then ext_names = { ext_names } end

  local exts = {}

  for _, ext_name in ipairs(ext_names) do
    local status_ok, ext = pcall(require, ext_name)
    if not status_ok then
      local f = fail_callback or function(_) end
      return f()
    end
    exts[#exts + 1] = ext
  end

  local unpack = unpack or table.unpack
  return callback(unpack(exts))
end
