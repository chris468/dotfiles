return {
  {
    "codeium.nvim",
    optional = true,
    opts = {
      virtual_text = {
        key_bindings = {
          clear = "<C-E>",
        },
      },
    },
  },
  {
    "lualine.nvim",
    optional = true,
    opts = function(_, opts)
      LazyVim.on_load("codeium.nvm", function()
        require("codeium.virtual_text").set_statusbar_refresh(require("lualine").refresh)
      end)

      local function codeium_status()
        return {
          function()
            local vt = require("codeium.virtual_text")
            local state = vt.status().state
            return ("%s%s"):format(
              LazyVim.config.icons.kinds.Codeium,
              state == "completions" and vt.status_string() or ""
            )
          end,
          cond = function()
            return LazyVim.is_loaded("codeium.nvim") ~= nil
          end,
          color = function()
            local vt = require("codeium.virtual_text")
            return {
              fg = Snacks.util.color(vt.status().state == "waiting" and "DiagnosticWarn" or "Special"),
            }
          end,
        }
      end

      table.insert(opts.sections.lualine_x, 2, codeium_status())
      return opts
    end,
  },
  {
    "copilot.lua",
    optional = true,
    opts = {
      suggestion = {
        keymap = {
          dismiss = "<C-E>",
        },
      },
    },
  },
}
