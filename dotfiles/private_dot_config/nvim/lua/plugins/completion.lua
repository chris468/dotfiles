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

return {
  "nvim-cmp",
  dependencies = {
    "chrisgrieser/cmp-nerdfont",
    "plenary.nvim",
  },
  opts = function(_, opts)
    local cmp = require("cmp")

    table.insert(opts.sources, {
      name = "nerdfont",
      group_index = 1,
    })
    opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
      completion = {
        border = "rounded",
        winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
      },
      documentation = {
        border = "rounded",
        winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
      },
    })

    local original_format = opts.formatting.format
    opts.formatting.format = function(entry, item)
      item = original_format(entry, item)
      item = format[entry.source.name] and format[entry.source.name](entry, item) or item
      return item
    end
  end,
}
