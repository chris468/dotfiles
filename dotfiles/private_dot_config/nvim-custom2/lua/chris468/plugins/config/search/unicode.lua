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
      entry.value.char,
      entry.value.code,
      entry.value.name,
    })
  end

  return function(item)
    return {
      value = item,
      ordinal = item.char .. item.code .. item.name,
      display = make_display,
    }
  end
end

local function create_finder()
  return require("telescope.finders").new_table({
    results = require("chris468.util.unicode").data(),
    entry_maker = gen_from_item(),
  })
end

return function(opts)
  opts = opts or {}
  return require("telescope.pickers")
    .new(opts, {
      finder = create_finder(),
      prompt_title = "Unicode symbols",
      sorter = require("telescope.config").values.generic_sorter(),
    })
    :find()
end
