---@param kind string
---@return string
local function get_icon(kind)
  local icon, _, _ = require("mini.icons").get("lsp", kind)
  return icon
end

---@param kind string
---@return string
local function get_highlight(kind)
  local _, hl, _ = require("mini.icons").get("lsp", kind)
  return hl
end

return {
  "saghen/blink.cmp",
  event = { "CmdLineEnter", "InsertEnter" },
  opts = {
    keymap = { preset = "super-tab" },
    fuzzy = { implementation = "prefer_rust" },
    completion = {
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                return get_icon(ctx.kind)
              end,
              highlight = function(ctx)
                return get_highlight(ctx.kind)
              end,
            },
            kind = {
              highlight = function(ctx)
                return get_highlight(ctx.kind)
              end,
            },
          },
        },
      },
      trigger = {
        show_on_keyword = false,
      },
    },
    signature = {
      enabled = true,
    },
    sources = {
      providers = {
        cmdline = {
          enabled = function()
            -- Avoid hangs on windows.
            -- Suggested by https://cmp.saghen.dev/recipes.html#disable-completion-in-only-shell-command-mode
            local os = require("chris468.os")
            if os.is_windows() or os.is_wsl() then
              return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
            end

            return true
          end,
        },
        snippets = {
          -- Hide snippets after trigger character
          -- https://cmp.saghen.dev/recipes#hide-snippets-after-trigger-character
          should_show_items = function(ctx)
            return ctx.trigger.initial_kind ~= "trigger-character"
          end,
        },
      },
    },
  },
  version = "*",
}
