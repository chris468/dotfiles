local function gen_from_item()
  local displayer = require("telescope.pickers.entry_display").create({
    separator = " ",
    items = {
      { width = 1 },
      { width = 7, right_justify = true },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.value.icon,
      entry.value.code,
      entry.value.name,
    })
  end

  return function(item)
    return {
      value = item,
      ordinal = item.icon .. (item.code or "-") .. item.name,
      display = make_display,
    }
  end
end

local function create_finder()
  local make_entry = gen_from_item()
  local data = require("chris468-utils.unicode").data()
  local results = {}
  for _, inner in ipairs(data) do
    for _, item in ipairs(inner) do
      table.insert(results, make_entry(item))
    end
  end

  return require("telescope.finders").new_table({
    results = results,
    entry_maker = function(v)
      return v
    end,
  })
end

return function(opts)
  opts = opts or {}
  opts.mode = opts.mode or "n"
  return require("telescope.pickers")
    .new(opts, {
      finder = create_finder(),
      prompt_title = "Unicode symbols",
      sorter = require("telescope.config").values.generic_sorter(),
      attach_mappings = function(bufnr)
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")
        actions.select_default:replace(function()
          local entry = actions_state.get_selected_entry()
          actions.close(bufnr)
          -- require("chris468.util").insert_at_cursor(entry.value.char)
          vim.api.nvim_paste(entry.value.char, false, -1)
          if opts.mode == "i" then
            -- FIXME: doesn't work at end of line
            vim.cmd([[ call cursor(line('.'), col('.') + 1) ]])
            vim.cmd([[ normal! i]])
          elseif opts.mode ~= "n" then
            vim.notify("Unsupported mode", vim.log.levels.WARN)
          end
        end)
        return true
      end,
    })
    :find()
end
