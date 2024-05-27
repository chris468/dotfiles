--- @param builtin string
--- @param opts table|function|nil
local function telescope_builtin(builtin, opts)
  return function()
    if type(opts) == "function" then
      opts = opts()
    end
    require("telescope.builtin")[builtin](opts or {})
  end
end

local last_rtp = nil
local ignore_docs_patterns = {}

local function get_ignore_docs_patterns()
  local path_separator = require("plenary.path").path.sep

  local current_rtp = vim.o.rtp
  if last_rtp ~= vim.o.rtp then
    local patterns, count = {}, 0
    for _, rtp in ipairs(vim.opt.rtp:get()) do
      count = count + 1
      patterns[count] = table.concat({ rtp, "doc", "" }, path_separator)
    end

    ignore_docs_patterns = patterns
    last_rtp = current_rtp
  end

  return ignore_docs_patterns
end

local function oldfiles_opts()
  return {
    file_ignore_patterns = get_ignore_docs_patterns(),
  }
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader><leader>", telescope_builtin("find_files"), desc = "Find files" },
    { "<leader>r", telescope_builtin("resume"), desc = "Resume last search " },
    { "<leader>/", telescope_builtin("live_grep"), desc = "Grep" },
    { '<leader>f"', telescope_builtin("registers"), desc = "Registers" },
    { "<leader>fb", telescope_builtin("buffers"), desc = "Buffers" },
    { "<leader>fg", telescope_builtin("git_files"), desc = "Git files" },
    { "<leader>fh", telescope_builtin("help_tags"), desc = "Help" },
    { "<leader>fo", telescope_builtin("vim_options"), desc = "Options" },
    { "<leader>fr", telescope_builtin("oldfiles", oldfiles_opts), desc = "Recent files" },
    { "<leader>fT", "<cmd>Telescope<cr>", desc = "Search" },
    { "<leader>f/", telescope_builtin("current_buffer_fuzzy_find"), desc = "Search current buffer" },
    { "<leader>f:", telescope_builtin("command_history"), desc = "Recent commands" },
  },
  lazy = true,
  version = "0.1.x",
}
