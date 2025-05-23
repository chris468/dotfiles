local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions_state = require("telescope.actions.state")

local M = {}

local default_globs = {
  "!**/.git/**",
  "!**/node_modules/**",
  "!**/bin/**",
  "!**/obj/**",
  "!**/.venv/**",
}

---@param args string[]
---@param new_args string|string[]
---@param opts? { append?: boolean, flag?: string }
local function append_args(args, new_args, opts)
  opts = opts or {}
  if opts.append == false then
    return
  end

  new_args = type(new_args) == "table" and new_args or { new_args }
  vim.list_extend(
    args,
    vim
      .iter(new_args)
      :filter(function(v)
        return v and v ~= ""
      end)
      :map(function(v)
        return opts.flag and { opts.flag, v } or v
      end)
      :flatten()
      :totable()
  )
end

---@param find fun(opts: table)
---@param update_opts fun(): table opts
---@return fun()
function M.change_opts(find, update_opts)
  return function()
    local opts = update_opts()
    opts.default_text = actions_state.get_current_line()
    find(opts)
  end
end

function M.grep(opts)
  local defaults = {
    search_hidden_files = false,
    search_ignored_files = false,
    default_globs = default_globs,
  }

  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)
  opts.cwd = opts.cwd or vim.uv.cwd()

  opts.attach_mappings = function(_, map)
    map(
      { "i", "n" },
      "<C-E>i",
      M.change_opts(M.grep, function()
        opts.search_ignored_files = not opts.search_ignored_files
        return opts
      end)
    )

    map(
      { "i", "n" },
      "<C-E>h",
      M.change_opts(M.grep, function()
        opts.search_hidden_files = not opts.search_hidden_files
        return opts
      end)
    )

    return true
  end

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local args =
        { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }

      append_args(args, opts.default_globs, { flag = "--glob" })

      local pieces = vim.split(prompt, "  ")
      append_args(args, pieces[1])

      if pieces[2] and pieces[2] ~= "" then
        local globs = vim.split(pieces[2], "|")
        append_args(args, globs, { flag = "--glob" })
      end

      append_args(args, "--hidden", { append = opts.search_hidden_files })

      -- --no-ignore means don't respect .gitignore, etc. - double negative
      append_args(args, "--no-ignore", { append = not opts.search_ignored_files })

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
