local search = require("chris468.plugins.config.search")

local function format_title(opts)
  return string.format("Recent files %s", opts.cwd_only and "" or "")
end

local function oldfiles(opts)
  local function attach_mappings(_)
    return function(_, map)
      map(
        { "i", "n" },
        "<C-\\>c",
        search.change_opts(oldfiles, function()
          opts.cwd_only = not opts.cwd_only
          return opts
        end)
      )

      return true
    end
  end

  opts = vim.tbl_extend("keep", opts or {}, { cwd_only = true })
  opts.attach_mappings = attach_mappings(opts)
  opts.prompt_title = format_title(opts)

  require("telescope.builtin").oldfiles(opts)
end

return oldfiles
