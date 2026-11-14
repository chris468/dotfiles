local function refresh_lualine()
  require("lualine").refresh()
end

---@param section {[string]: table}
---@param text string|fun()
---@return number|false, table?
local function find_component(section, text)
  for pos, c in ipairs(section) do
    if c[1] == text then
      return pos, c
    end
  end
  return false, nil
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
      do -- reoove extra space from root path
        local root_path_pos = 1
        local root_path_component = opts.sections.lualine_c[root_path_pos]
        local original_root_path = root_path_component[1]
        root_path_component[1] = function()
          local spaces_removed, _ = original_root_path():gsub("(.)(%s)(.*)", "%1%3")
          return spaces_removed
        end
      end

      do -- reoove extra space from file path
        local path_pos = find_component(opts.sections.lualine_c, "filetype") + 1
        opts.sections.lualine_c[path_pos].padding = { left = 0, right = 1 }
      end

      do -- add icon indicating lsp presence next to diagnostics
        local _, diagnostics = find_component(opts.sections.lualine_c, "diagnostics")
        diagnostics[1] = "chris468.diagnostics_with_lsp"
      end

      do -- replace lazy updates w/ a component that includes both lazy and mason
        local updates_pos = find_component(opts.sections.lualine_x, require("lazy.status").updates)
        if updates_pos then
          opts.sections.lualine_x[updates_pos] = "chris468.updates"
        end
      end

      table.insert(opts.sections.lualine_x, "overseer")

      return opts
    end,
  },
  {
    "noice.nvim",
    opts = {
      status = {
        -- Remove command section from status line
        command = { has = false },
      },
    },
  },
}
