---@param kind string
---@return string
local function get_icon(kind)
  if kind == "Codeium" then
    return Chris468.ui.icons.windsurf
  end
  local icon, _, _ = require("mini.icons").get("lsp", kind)
  return icon
end

---@param kind string
---@return string
local function get_highlight(kind)
  if kind == "Codeium" then
    return "BlinkCmpKindCopilot"
  end

  local _, hl, _ = require("mini.icons").get("lsp", kind)
  return hl
end

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      { "codeium.nvim", optional = true },
    },
    event = { "CmdLineEnter", "InsertEnter" },
    opts = {
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
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
      enabled = function()
        return not vim.list_contains(Chris468.tools.disable_filetypes, vim.bo.filetype)
      end,
      fuzzy = { implementation = "prefer_rust" },
      keymap = { preset = "super-tab" },
      signature = {
        enabled = true,
      },
      sources = {
        default = {
          "buffer",
          "codeium",
          "lsp",
          "path",
          "snippets",
        },
        providers = {
          codeium = {
            enabled = Chris468.tools.ai.provider == "codeium",
            name = "Codeium",
            module = "codeium.blink",
            async = true,
          },
          cmdline = {
            enabled = function()
              -- Avoid hangs on windows.
              -- Suggested by https://cmp.saghen.dev/recipes.html#disable-completion-in-only-shell-command-mode
              local os = require("chris468.util.os")
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
  },
  {
    "Exafunction/windsurf.nvim",
    cmd = "Codeium",
    dependencies = { "plenary.nvim" },
    enabled = Chris468.tools.ai.provider == "codeium",
    main = "codeium",
    opts = {
      enable_cmp_source = false,
    },
    version = false,
  },
}
