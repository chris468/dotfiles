local config = require("chris468.plugins.config.lualine")

local function remove_border(original, direction)
  if type(original) == "string" then
    original = require("notify.stages")[original]
  end
  return vim.tbl_map(function(v)
    return function(...)
      local result = v(...)
      if result.border then
        result.border = "none"
      else
      end
      return result
    end
  end, original(direction))
end

return {
  {
    "echasnovski/mini.icons",
    config = function(_, opts)
      local mi = require("mini.icons")
      mi.setup(opts)
      mi.mock_nvim_web_devicons()
    end,
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "mini.icons" },
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_a = { { "mode", fmt = config.format.mode } },
        lualine_b = { "filename", "branch", "diff", "diagnostics" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          { "lsp_status", icon = Chris468.ui.icons.lsp_status },
          { "filetype", colored = true },
          "fileformat",
          { "encoding", fmt = config.format.encoding },
        },
        lualine_z = { "progress", "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-notify",
    },
    opts = {
      cmdline = {
        view = "cmdline",
      },
      lsp = {
        progress = {
          enabled = false,
        },
      },
      presets = {
        command_palette = false,
        inc_rename = false,
      },
      routes = {
        {
          filter = {
            any = {
              { error = true },
              { warning = true },
              { event = "notify" },
            },
          },
          opts = { title = "" },
          view = "notify",
        },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        icons = {
          DEBUG = Chris468.ui.icons.debug,
          ERROR = Chris468.ui.icons.error,
          INFO = Chris468.ui.icons.info,
          TRACE = Chris468.ui.icons.trace,
          WARN = Chris468.ui.icons.warning,
        },
        stages = remove_border("fade_in_slide_out", "bottom_up"),
        render = "compact",
        top_down = false,
      })
    end,
    version = "*",
  },
}
