local kind_icons = {
  Copilot = { icon = Chris468.ui.icons.copilot, hl = "BlinkCmpKindCopilot" },
  Codeium = { icon = Chris468.ui.icons.windsurf, hl = "BlinkCmpKindCopilot" },
  Windsurf = { icon = Chris468.ui.icons.windsurf, hl = "BlinkCmpKindCopilot" },
}

---@param kind string
---@return string
local function get_icon(kind)
  if kind_icons[kind] then
    return kind_icons[kind].icon
  end

  local icon, _, _ = require("mini.icons").get("lsp", kind)
  return icon
end

---@param kind string
---@return string
local function get_highlight(kind)
  if kind_icons[kind] then
    return kind_icons[kind].hl
  end

  local _, hl, _ = require("mini.icons").get("lsp", kind)
  return hl
end

return {
  {
    "saghen/blink.cmp",
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
        return not vim.list_contains(Chris468.disable_filetypes, vim.bo.filetype)
      end,
      fuzzy = { implementation = "prefer_rust" },
      keymap = { preset = "super-tab" },
      signature = {
        enabled = true,
      },
      sources = {
        default = {
          "buffer",
          "lsp",
          "path",
          "snippets",
        },
        providers = {
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
    opts_extend = { "sources.default" },
  },
  {
    "Exafunction/windsurf.nvim",
    cond = Chris468.ai.provider == "codeium",
    cmd = "Codeium",
    dependencies = { "plenary.nvim" },
    main = "codeium",
    opts = {
      enable_cmp_source = false,
    },
    specs = {
      "blink.cmp",
      dependencies = { "windsurf.nvim" },
      opts = {
        sources = {
          default = { "codeium" },
          providers = {
            codeium = {
              name = "Codeium",
              module = "codeium.blink",
              async = true,
            },
          },
        },
      },
    },
    version = false,
  },
  {
    "zbirenbaum/copilot.lua",
    cond = Chris468.ai.provider == "copilot",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
    specs = {
      {
        "blink.cmp",
        dependencies = {
          {
            "giuxtaposition/blink-cmp-copilot",
            cond = Chris468.ai.provider == "copilot",
            dependencies = "copilot.lua",
          },
        },
        opts = {
          sources = {
            default = { "copilot" },
            providers = {
              copilot = {
                async = true,
                module = "blink-cmp-copilot",
                name = "Copilot",
                score_offset = 100,
              },
            },
          },
        },
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = Chris468.ai.provider == "copilot",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatStop",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatPrompts",
      "CopilotChatModels",
      "CopilotChatAgents",
    },
    opts = {},
  },
}
