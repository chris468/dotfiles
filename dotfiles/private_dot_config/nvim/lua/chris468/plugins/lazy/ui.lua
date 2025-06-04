local cmd = require("chris468.util.keymap").cmd
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
    keys = {
      { "<leader>sn", cmd("Noice telescope"), desc = "Notifications" },
      { "<leader>sN", cmd("Noice all"), desc = "Noice" },
      { "<leader>ud", cmd("Noice dismiss"), desc = "Dismiss notifications" },
    },
    opts = {
      extensions = {
        {
          filetypes = { "toggleterm" },
          sections = {
            lualine_a = { { "mode", fmt = config.format.mode } },
            lualine_b = {
              function()
                local t = require("toggleterm.terminal")
                local terminal = t.get(vim.b.toggle_number)

                if not terminal then
                  return "Terminal"
                end

                return " " .. terminal.display_name or ("Terminal #" .. vim.b.toggle_number)
              end,
            },
          },
        },
        {
          filetypes = { "TelescopePrompt" },
          sections = {
            lualine_a = {
              function()
                local state = require("telescope.actions.state")
                local buf = vim.api.nvim_get_current_buf()
                local picker = state.get_current_picker(buf)
                local name = vim.trim(picker.prompt_prefix or "")
                name = name .. (#name and " " or "") .. (picker.prompt_title or " ")

                return name
              end,
            },
            lualine_b = {
              function()
                return string.format(" %s", vim.fn.fnamemodify(vim.fn.getcwd(), ":p:~"))
              end,
            },
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
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
    },
    version = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-notify",
    },
    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        desc = "Redirect",
        mode = "c",
      },
    },
    opts = {
      cmdline = {
        view = "cmdline",
      },
      lsp = {
        progress = {
          format_done = { "" },
        },
      },
      messages = {
        view = "mini",
      },
      presets = {
        command_palette = false,
        inc_rename = false,
        long_message_to_split = true,
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
    opts = {
      icons = {
        DEBUG = Chris468.ui.icons.debug,
        ERROR = Chris468.ui.icons.error,
        INFO = Chris468.ui.icons.info,
        TRACE = Chris468.ui.icons.trace,
        WARN = Chris468.ui.icons.warning,
      },
      timeout = 1000,
      render = "compact",

      -- custom option, handled below
      remove_border = true,
    },
  },
  {
    "nvim-notify",
    opts = function(_, opts)
      if not opts.remove_border then
        return
      end
      if opts.stages == nil then
        opts.stages = "fade_in_slide_out"
      end
      if opts.top_down == nil then
        opts.top_down = true
      end
      opts.stages = remove_border(opts.stages, opts.top_down and "top_down" or "bottom_up")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "mini.icons" },
    event = "VeryLazy",
    keys = {
      { "[b", cmd("BufferLineCyclePrev"), desc = "Previous buffer" },
      { "]b", cmd("BufferLineCycleNext"), desc = "Next buffer" },
    },
    opts = {
      options = {
        close_command = function(bufnr)
          require("snacks").bufdelete(bufnr)
        end,
        right_mouse_command = function(bufnr)
          require("snacks").bufdelete(bufnr)
        end,
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
    },
  },
}
