local search = require("chris468.plugins.config.search")

local rg

local function attach_mappings(opts)
  return function(_, map)
    map(
      { "i", "n" },
      "<C-E>i",
      search.change_opts(rg, function()
        opts.search_ignored_files = not opts.search_ignored_files
        return opts
      end)
    )

    map(
      { "i", "n" },
      "<C-E>h",
      search.change_opts(rg, function()
        opts.search_hidden_files = not opts.search_hidden_files
        return opts
      end)
    )

    return true
  end
end

local function create_finder(opts)
  return require("telescope.finders").new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local args =
        { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }

      search.append_args(args, opts.default_globs, { flag = "--glob" })

      local pieces = vim.split(prompt, "  ")
      search.append_args(args, pieces[1])

      if pieces[2] and pieces[2] ~= "" then
        local globs = vim.split(pieces[2], "|")
        search.append_args(args, globs, { flag = "--glob" })
      end

      search.append_args(args, "--hidden", { append = opts.search_hidden_files })

      -- --no-ignore means don't respect .gitignore, etc. - double negative
      search.append_args(args, "--no-ignore", { append = not opts.search_ignored_files })

      return args
    end,
    entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })
end

local function format_title(opts)
  return string.format(
    "Grep%s%s",
    opts.search_hidden_files and " 󰘓" or "",
    opts.search_ignored_files and " " or ""
  )
end

rg = function(opts)
  local defaults = {
    search_hidden_files = false,
    search_ignored_files = false,
    default_globs = search.default_globs,
  }

  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)
  opts.cwd = opts.cwd or vim.uv.cwd()

  require("telescope.pickers")
    .new(opts, {
      attach_mappings = attach_mappings(opts),
      debounce = 100,
      finder = create_finder(opts),
      previewer = require("telescope.config").values.grep_previewer(opts),
      prompt_title = format_title(opts),
      sorter = require("telescope.sorters").highlighter_only(opts),
    })
    :find()
end

return rg
