return function(ext_name, callback, fail_callback)
  local status_ok, ext = pcall(require, ext_name)
  if not status_ok then
    local f = fail_callback or function(_) end
    return f()
  end
  return callback(ext)
end
