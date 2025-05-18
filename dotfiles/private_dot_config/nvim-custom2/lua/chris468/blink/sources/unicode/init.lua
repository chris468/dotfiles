local data = require("chris468.blink.sources.unicode.data")
local notify = require("chris468.util").schedule_notify

---@module "blink.cmp"
---@class blink.cmp.Source
local source = {}

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = opts
  return self
end

function source:get_trigger_characters()
  return { ":" }
end

function source:execute(_, _, callback, default_implementation)
  default_implementation()
  callback()
end

local function set_range(ctx, items)
  local pos, cursor = ctx.bounds.start_col - 1, ctx.cursor
  return vim.tbl_map(function(v)
    return vim.tbl_deep_extend("error", v, {
      textEdit = {
        range = {
          start = { line = cursor[1] - 1, character = pos - 1 },
          ["end"] = { line = cursor[1] - 1, character = cursor[2] },
        },
      },
    })
  end, items)
end

function source:get_completions(ctx, callback)
  local line, pos = ctx.line, ctx.bounds.start_col - 1
  local triggered = vim.list_contains(self:get_trigger_characters(), line:sub(pos, pos))

  ---@type blink.cmp.CompletionResponse
  local result = {
    is_incomplete_backward = true,
    is_incomplete_forward = true,
    items = {},
  }

  if not triggered then
    callback(result)
    ---@diagnostic disable-next-line: return-type-mismatch
    return nil
  end

  local task = data
    .generate_unicode_completions()
    :map(function(items)
      return set_range(ctx, items)
    end)
    :map(function(items)
      result.items = items
      callback(result)
    end)
    :catch(function(err)
      notify("Failed to load unicode completions: " .. err, vim.log.levels.WARN)
      callback(result)
    end)

  ---@diagnostic disable-next-line: return-type-mismatch
  return function()
    task:cancel()
  end
end

return source
