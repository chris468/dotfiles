local M = {}

function M.family(theme)
  return theme:find("^base16") and "base16" or (theme:find("^catppuccin") and "catppuccin" or theme)
end

--- @class chris468.ThemeHighlights
--- @field IblIndent? vim.api.keyset.highlight
--- @field IblScope? vim.api.keyset.highlight
--- @field BreakpointLine? vim.api.keyset.highlight
--- @field StoppedLine? vim.api.keyset.highlight
--- @field StoppedIcon? vim.api.keyset.highlight
--- @field DapBreakpoint? vim.api.keyset.highlight
--- @field DapLogPoint? vim.api.keyset.highlight

--- @class chris468.Theme
--- @field highlights chris468.ThemeHighlights

local function load_theme(colorscheme)
  local ok, val = pcall(require, "chris468.themes." .. colorscheme)
  if ok then
    return val
  end

  local family = M.family(colorscheme)
  if family ~= key then
    ok, val = pcall(require, "chris468.themes." .. family)
  end
  if ok then
    return val
  end

  vim.notify("No theme data for colorscheme " .. colorscheme)
  return {}
end

M.theme = setmetatable({}, {
  __index = function(table, key)
    --- @type chris468.Theme?
    local val = rawget(table, key)

    if not val then
      val = load_theme(key)
      rawset(table, key, val)
    end

    return val
  end,
})

function M.configure_highlights(colorscheme)
  local theme = M.theme[colorscheme]
  for k, v in pairs(theme.highlights) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

return M
