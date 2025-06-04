local search = require("chris468.plugins.config.search")

local fd

local function attach_mappings(opts)
  return function(_, map)
    map(
      { "i", "n" },
      "<C-E>i",
      search.change_opts(fd, function()
        opts.search_ignored_files = not opts.search_ignored_files
        return opts
      end)
    )

    map(
      { "i", "n" },
      "<C-E>h",
      search.change_opts(fd, function()
        opts.search_hidden_files = not opts.search_hidden_files
        return opts
      end)
    )

    return true
  end
end

---@param opts table
---@param include_prompt boolean? Defaults true. Exclude the prompt for oneshot jobs.
local function get_command_generator(opts, include_prompt)
  return function(prompt)
    local args = { "fd", "--color", "never", "--type", "f", "--full-path" }

    search.append_args(args, "--hidden", { append = opts.search_hidden_files })

    search.append_args(args, "--no-ignore", { append = opts.search_ignored_files })

    search.append_args(args, prompt, { append = include_prompt ~= false and prompt and prompt ~= "" })

    return args
  end
end

local function create_finder(opts)
  return require("telescope.finders").new_oneshot_job(get_command_generator(opts, false)(), {
    entry_maker = require("telescope.make_entry").gen_from_file(opts),
    cwd = opts.cwd,
  })
end

local function format_title(opts)
  return string.format(
    "Files%s%s",
    opts.search_hidden_files and " 󰘓" or "",
    opts.search_ignored_files and " " or ""
  )
end

fd = function(opts)
  local defaults = {
    search_hidden_files = false,
    search_ignored_files = false,
  }

  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)
  opts.cwd = opts.cwd or vim.uv.cwd()

  local conf = require("telescope.config").values

  require("telescope.pickers")
    .new(opts, {
      attach_mappings = attach_mappings(opts),
      finder = create_finder(opts),
      previewer = conf.grep_previewer(opts),
      prompt_title = format_title(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

return fd
