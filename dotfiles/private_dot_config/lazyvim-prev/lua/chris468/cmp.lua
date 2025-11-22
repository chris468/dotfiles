local M = {}

local format = {}

function format.path(entry, item)
  local ok, mi = pcall(require, "mini.icons")
  if not ok then
    return
  end

  local data = entry.completion_item.data or {}
  local path, type = data.path, data.type
  if not path or not type then
    return item
  end

  local icon, hl = mi.get(type, path)

  item.kind = icon .. " " .. type:gsub("^%a", string.upper)
  item.kind_hl_group = hl
  return item
end

function format.cmdline(_, item)
  item.kind = " Command"
  return item
end

function format.cmdline_history(_, item)
  item.kind = " History"
  return item
end

function format.buffer(_, item)
  item.kind = " Buffer"
end

function M.format(entry, item)
  return format[entry.source.name] and format[entry.source.name](entry, item) or item
end

return M
