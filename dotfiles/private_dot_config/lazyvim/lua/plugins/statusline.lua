local function codeium_status_components()
  local vt = require("lazy-require").require_on_index("codeium.virtual_text")

  LazyVim.on_load("codeium.nvim", function()
    return vt.set_statusbar_refresh(require("lualine").refresh)
  end)

  local icon_component = LazyVim.lualine.status(LazyVim.config.icons.kinds.Codeium, function()
    if not LazyVim.is_loaded("codeium.nvim") then
      return
    end
    return vt.status().state == "waiting" and "pending" or "ok"
  end)
  icon_component.separator = ""
  icon_component.padding = { left = 1, right = 0 }

  local completions_component = {
    function()
      if vt.status().state == "completions" then
        return vt.status_string()
      else
        return ""
      end
    end,
    cond = icon_component.cond,
    color = icon_component.color,
    padding = { left = 0, right = 1 },
    draw_empty = true,
  }

  return { icon_component, completions_component }
end

local function insert_components(section, components, pos)
  if type(components) == "table" then
    local iter = vim.iter(components)
    if pos then
      iter:rev()
    end
    iter:each(function(c)
      table.insert(section, pos, c)
    end)
  end
end

return {
  {
    "lualine.nvim",
    dependencies = {
      { "tjdevries/lazy-require.nvim", lazy = true, version = false },
    },
    optional = true,
    opts = function(_, opts)
      LazyVim.on_load("codeium.nvm", function()
        require("codeium.virtual_text")
      end)

      insert_components(opts.sections.lualine_x, codeium_status_components(), 2)
      return opts
    end,
  },
  {
    "noice.nvim",
    opts = {
      status = {
        command = { has = false },
      },
    },
  },
}
