local search = require("chris468.plugins.config.search")

local explore

local function format_prompt_prefix(opts)
  return string.format("%s%s  ", opts.hidden and "󰘓" or " ", opts.no_ignore and "" or " ")
end

local function attach_mappings(opts)
  return function(_, map)
    map({ "i", "n" }, "<C-E>i", function(bufnr)
      local picker = require("telescope.actions.state").get_current_picker(bufnr)
      local finder = picker.finder
      local no_ignore = not finder.no_ignore
      finder.no_ignore = no_ignore
      picker.prompt_title = format_prompt_prefix(finder)
      picker:refresh(finder, { reset_prompt = true, multi = picker._multi })
    end)

    map({ "i", "n" }, "<C-E>h", function(bufnr)
      local picker = require("telescope.actions.state").get_current_picker(bufnr)
      local finder = picker.finder
      local hidden = not finder.hidden
      finder.hidden = hidden
      picker.prompt_prefix = format_prompt_prefix(finder)
      picker:refresh(finder, { reset_prompt = true, multi = picker._multi })
    end)

    return true
  end
end

explore = function(opts)
  local defaults = {
    hidden = false,
    no_ignore = false,
  }

  opts = vim.tbl_deep_extend("keep", opts or {}, defaults)

  local file_browser = require("telescope").extensions.file_browser.file_browser

  file_browser({
    attach_mappings = attach_mappings(opts),
    prompt_title = "Explore",
    prompt_prefix = format_prompt_prefix(opts),
  })
end

return explore
