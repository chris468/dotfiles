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

local function get_oldfiles_ignore_patterns()
  local path_separator = require("plenary.path").path.sep

  local current_rtp = vim.o.rtp
  if last_rtp ~= vim.o.rtp then
    local patterns = { ".git/" }
    local count = #patterns
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
    file_ignore_patterns = get_oldfiles_ignore_patterns(),
  }
end

--- @param ignore boolean
--- @param default_text string?
local function live_grep(ignore, default_text)
  return telescope_builtin("live_grep", {
    additional_args = ignore and { "--no-ignore" } or {},
    attach_mappings = function(_, map)
      local function toggle_search_all()
        local actions_state = require("telescope.actions.state")
        local current_line = actions_state.get_current_line()
        return live_grep(not ignore, current_line)()
      end

      map({ "i", "n" }, "<C-g>", toggle_search_all)

      return true
    end,
    default_text = default_text,
    prompt_title = "Live Grep" .. (ignore and " (all files)" or ""),
  })
end

local config_path = vim.fn.stdpath("config")
local chezmoi_path = vim.fn.expand("~/.local/share/chezmoi")

return {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "tsakirist/telescope-lazy.nvim", config = true },
  },
  keys = {
    { "<leader><leader>", telescope_builtin("find_files"), desc = "Find files" },
    { "<leader>r", telescope_builtin("resume"), desc = "Resume last search " },
    { "<leader>/", live_grep(false), desc = "Grep" },
    { '<leader>f"', telescope_builtin("registers"), desc = "Registers" },
    { "<leader>fb", telescope_builtin("buffers"), desc = "Buffers" },
    { "<leader>fc", telescope_builtin("find_files", { cwd = config_path }), desc = "Configuration" },
    {
      "<leader>fd",
      telescope_builtin("find_files", { cwd = chezmoi_path, hidden = true, file_ignore_patterns = { ".git/" } }),
      desc = "Chezmoi dotfiles",
    },
    { "<leader>fg", telescope_builtin("git_files"), desc = "Git files" },
    { "<leader>fh", telescope_builtin("highlights"), desc = "Highlights" },
    { "<leader>fH", telescope_builtin("help_tags"), desc = "Help" },
    { "<leader>fk", telescope_builtin("keymaps"), desc = "Key mappings" },
    { "<leader>fL", "<cmd>Telescope lazy<CR>", desc = "Lazy plugins" },
    { "<leader>fo", telescope_builtin("vim_options"), desc = "Options" },
    { "<leader>fr", telescope_builtin("oldfiles", oldfiles_opts), desc = "Recent files" },
    { "<leader>fT", "<cmd>Telescope<cr>", desc = "Search" },
    { "<leader>f/", telescope_builtin("current_buffer_fuzzy_find"), desc = "Search current buffer" },
    { "<leader>f?c", telescope_builtin("live_grep", { cwd = config_path }), desc = "Configuration" },
    {
      "<leader>f?d",
      telescope_builtin(
        "live_grep",
        { cwd = chezmoi_path, additional_args = { "--hidden" }, file_ignore_patterns = { ".git/" } }
      ),
      desc = "Chezmoi dotfiles",
    },
    { "<leader>f:", telescope_builtin("command_history"), desc = "Recent commands" },
  },
  lazy = true,
  opts = {
    defaults = {
      layout_strategy = "vertical",
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
          ["<C-b>"] = "results_scrolling_up",
          ["<C-f>"] = "results_scrolling_down",
        },
        n = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
          ["<C-b>"] = "results_scrolling_up",
          ["<C-f>"] = "results_scrolling_down",
        },
      },
    },
    extensions = {
      lazy = {
        mappings = {
          change_cwd_to_plugin = "<C-w>",
          open_plugins_picker = "<C-o>",
        },
        actions_opts = {
          change_cwd_to_plugin = {
            auto_close = true,
          },
        },
      },
    },
  },
}
