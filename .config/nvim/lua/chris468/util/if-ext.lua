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
    exts[ext_name] = ext
  end

  if single then exts = exts[ext_names[1]] end

  return callback(exts)
end
