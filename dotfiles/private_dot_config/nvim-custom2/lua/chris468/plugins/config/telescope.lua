local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions_state = require("telescope.actions.state")

local M = {}

local defaults = {
  hidden = true,
  ignored = false,
}

function M.grep(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)
  opts.cwd = opts.cwd or vim.uv.cwd()

  opts.attach_mappings = function(_, map)
    map({ "i", "n" }, "<C-E>i", function()
      opts.ignored = not opts.ignored
      opts.default_text = actions_state.get_current_line()
      M.grep(opts)
    end)

    map({ "i", "n" }, "<C-e>h", function()
      opts.hidden = not opts.hidden
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

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        vim.list_extend(args, { "-e", pieces[1] })
      end

      if pieces[2] and pieces[2] ~= "" then
        vim.list_extend(args, { "-g", pieces[2] })
      end

      if opts.hidden then
        vim.list_extend(args, { "--hidden" })
      end

      if not opts.ignored then
        vim.list_extend(args, { "--no-ignore" })
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
      prompt_title = string.format("Grep%s%s", opts.hidden and " 󰘓" or "", opts.ignored and "" or " "),
      -- prompt_prefix = string.format("%s%s > ", opts.hidden and "󰘓" or " ", opts.ignored and " " or ""),
      debounce = 100,
      finder = finder,
      preview = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

return M
