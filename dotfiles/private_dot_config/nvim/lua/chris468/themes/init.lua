local M = {}

function M.family(theme)
  local families = {
    ["^base16"] = "base16",
    ["^catppuccin"] = "catppuccin",
    ["^tokyonight"] = "tokyonight",
  }

  for match, family in pairs(families) do
    if theme:find(match) then
      return family
    end
  end

  return theme
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
  if family ~= colorscheme then
    ok, val = pcall(require, "chris468.themes." .. family)
  end
  if ok then
    return val
  end

  vim.notify("No theme data for colorscheme " .. colorscheme)
  return { highlights = {} }
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
  if not colorscheme then
    return
  end

  local theme = M.theme[colorscheme]
  for k, v in pairs(theme.highlights) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

return M
