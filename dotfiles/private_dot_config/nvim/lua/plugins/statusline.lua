local function refresh_lualine()
  require("lualine").refresh()
end

local function codeium_status_components()
  local vt = require("lazy-require").require_on_index("codeium.virtual_text")

  LazyVim.on_load("codeium.nvim", function()
    return vt.set_statusbar_refresh(refresh_lualine)
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

local function lsp_status_components()
  local ignore_clients = { "copilot" }
  local function current_buffer_has_clients()
    local clients = vim.tbl_filter(function(client)
      return not vim.list_contains(ignore_clients, client.name)
    end, vim.lsp.get_clients({ buf = vim.api.nvim_get_current_buf() }))
    return #clients > 0
  end

  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    group = vim.api.nvim_create_augroup("chris468.lsp_status", { clear = true }),
    callback = refresh_lualine,
  })

  return {
    {
      function()
        return current_buffer_has_clients() and "" or ""
      end,
      color = function()
        ---@module "mini.icons"
        local _, hl = MiniIcons.get("file", vim.api.nvim_buf_get_name(0))
        return hl
      end,
      padding = { left = 1, right = 0 },
      separator = "",
    },
  }
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

local function find_component(section, name)
  for pos, c in ipairs(section) do
    if c[1] == name then
      return pos
    end
  end
  return false
end

return {
  {
    "lualine.nvim",
    dependencies = {
      { "tjdevries/lazy-require.nvim", lazy = true, version = false },
      { "mini.icons" },
    },
    optional = true,
    opts = function(_, opts)
      local filetype_pos = find_component(opts.sections.lualine_c, "filetype")
      local path_pos = filetype_pos + 1
      local root_path_pos = 1

      -- fix some spacing
      opts.sections.lualine_c[path_pos].padding = { left = 0, right = 1 }
      local original_root_path = opts.sections.lualine_c[root_path_pos][1]
      opts.sections.lualine_c[root_path_pos][1] = function()
        local spaces_removed, _ = original_root_path():gsub("(.)(%s)(.*)", "%1%3")
        return spaces_removed
      end

      -- insert components last to avoid having existing ones move around
      insert_components(opts.sections.lualine_c, lsp_status_components(), filetype_pos)
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
