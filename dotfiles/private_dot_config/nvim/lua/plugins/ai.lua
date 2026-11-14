return {
  {
    "copilot.lua",
    optional = true,
    opts = {
      suggestion = {
        keymap = {
          dismiss = "<C-E>",
        },
      },
      filetypes = {
        yaml = true,
      },
    },
  },
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",
    opts = {
      notify = "debug",
      provider = "openai_fim_compatible",
      n_completions = 1, -- Keeps inference fast and RAM low on 8 GB M1
      context_window = 1024,
      request_timeout = 8,
      throttle = 300,
      debounce = 200,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:1.5b",
          optional = {
            max_tokens = 64,
            top_p = 0.9,
          },
        },
      },
      -- provider_options = {
      --   openai_fim_compatible = {
      --     -- minuet requires an env var name here; TERM always exists and Ollama ignores it
      --     api_key = "TERM",
      --     name = "Ollama",
      --     end_point = "http://localhost:11434/v1/completions",
      --     model = "qwen2.5-coder:1.5b",
      --     optional = {
      --       max_tokens = 64,
      --       top_p = 0.9,
      --       options = {
      --         num_ctx = 2048,
      --       },
      --     },
      --   },
      -- },
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<Tab>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-E>",
        },
      },
    },
  },
}
