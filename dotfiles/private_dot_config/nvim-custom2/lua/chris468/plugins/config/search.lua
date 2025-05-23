local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions_state = require("telescope.actions.state")

local M = {}

local defaults = {
  search_hidden_files = false,
  search_ignored_files = false,
  default_globs = {
    "!**/.git/**",
    "!**/node_modules/**",
    "!**/bin/**",
    "!**/obj/**",
    "!**/.venv/**",
  },
}

function M.grep(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)
  opts.cwd = opts.cwd or vim.uv.cwd()

  opts.attach_mappings = function(_, map)
    map({ "i", "n" }, "<C-E>i", function()
      opts.search_ignored_files = not opts.search_ignored_files
      opts.default_text = actions_state.get_current_line()
      M.grep(opts)
    end)

    map({ "i", "n" }, "<C-e>h", function()
      opts.search_hidden_files = not opts.search_hidden_files
      opts.default_text = actions_state.get_current_line()
      M.grep(opts)
    end)

    return true
  end

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local args = { "rg" }

      for _, glob in ipairs(opts.default_globs) do
        vim.list_extend(args, { "--glob", glob })
      end

      local pieces = vim.split(prompt, "  ")
      if pieces[1] then
        vim.list_extend(args, { "-e", pieces[1] })
      end

      if pieces[2] and pieces[2] ~= "" then
        local globs = vim.split(pieces[2], "|")
        for _, glob in ipairs(globs) do
          if glob and glob ~= "" then
            vim.list_extend(args, { "--glob", glob })
          end
        end
      end

      if opts.search_hidden_files then
        vim.list_extend(args, { "--hidden" })
      end

      if not opts.search_ignored_files then
        vim.list_extend(args, { "--no-ignore" }) -- don't respect .gitignore, etc.
      end

      vim.list_extend(
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
      )
      return args
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      prompt_title = string.format(
        "Grep%s%s",
        opts.search_hidden_files and " 󰘓" or "",
        opts.search_ignored_files and " " or ""
      ),
      debounce = 100,
      finder = finder,
      preview = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

return M
