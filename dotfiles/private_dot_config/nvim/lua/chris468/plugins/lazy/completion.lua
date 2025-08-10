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
  { "rafamadriz/friendly-snippets" },
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "friendly-snippets",
        version = "*",
      },
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
        return not vim.list_contains(Chris468.disabled_filetypes, vim.bo.filetype)
      end,
      fuzzy = { implementation = "prefer_rust" },
      keymap = { preset = "super-tab" },
      signature = {
        enabled = true,
      },
      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
        },
        providers = {
          cmdline = {
            enabled = true,
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
      virtual_text = {
        enabled = Chris468.ai.virtual_text,
      },
    },
    specs = {
      "blink.cmp",
      dependencies = { "windsurf.nvim" },
      opts = {
        sources = {
          default = { "codeium" },
          providers = {
            codeium = {
              enabled = not Chris468.ai.virtual_text,
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
      suggestion = {
        enabled = Chris468.ai.virtual_text,
        auto_trigger = true,
        keymap = {
          accept = "<tab>",
        },
      },
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
                enabled = not Chris468.ai.virtual_text,
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
  {
    "azorng/goose.nvim",
    cond = Chris468.ai.agent == "goose" and vim.fn.executable("goose") == 1,
    cmd = {
      "Goose",
      "GooseOpenInput",
      "GooseOpenInputNewSession",
      "GooseOpenOutput",
      "GooseToggleFocus",
      "GooseClose",
      "GooseToggleFullScreen",
      "GooseSelectSession",
      "GooseConfigureProvider",
      "GooseDiff",
      "GooseDiffNext",
      "GooseDiffPrev",
      "GooseDiffClose",
      "GooseRevertAll",
      "GooseRun",
      "GooseRunNewSession",
      "GooseStop",
    },
    dependencies = {
      "plenary.nvim",
    },
    opts = {
      preferred_picker = "telescope",
      default_global_keymaps = false,
      providers = {
        ollama = {
          "qwen2.5:3b",
          "qwen2.5-coder",
          "qwen2.5-coder:7b-instruct-q4_K_S",
        },
        openai = {
          "gpt-4o",
        },
        ["gemini-cli"] = {
          "gemini-2.5-pro",
        },
      },
    },
  },
}
