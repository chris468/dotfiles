local icons = require("chris468.config.icons")

local function reveal()
  local buf = vim.bo.filetype == "neo-tree" and "#" or "%"
  local reveal_file = vim.fn.expand(buf .. ":p")
  vim.notify("reveal " .. buf .. ": '" .. reveal_file .. "'")
  require("neo-tree.command").execute({
    reveal_file = vim.fn.expand(buf .. ":p"),
  })
end

local current_source = ""

return {
  "nvim-neo-tree/neo-tree.nvim",
  config = function(_, opts)
    local nesting_rules = require("neotree-file-nesting-config").nesting_rules

    nesting_rules.Dockerfile = {
      pattern = "^Dockerfile$",
      files = {
        "Dockerfile.*",
        ".dockerignore",
      },
    }
    nesting_rules.docker_compose = {
      pattern = "^docker%-compose%.ya?ml",
      files = {
        "docker-compose.*.yml",
        "docker-compose.*.yaml",
      },
    }
    nesting_rules.helm = {
      pattern = "^Chart.yaml$",
      files = {
        "Chart.lock",
        ".helmignore",
      },
    }

    opts.nesting_rules = nesting_rules
    require("neo-tree").setup(opts)
  end,
  cmd = { "Neotree" },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons", optional = true },
    { "MunifTanjim/nui.nvim" },
    { "saifulapm/neotree-file-nesting-config" },
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        opts = opts or {}
        opts.options = opts.options or {}
        opts.options.offsets = opts.options.offsets or {}
        table.insert(opts.options.offsets, {
          filetype = "neo-tree",
          text = function()
            return current_source
          end,
          text_align = "left",
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("let neo-tree hijack netrw", {}),
      callback = function(args)
        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
        if stat and stat.type == "directory" then
          require("neo-tree")
          return true
        end
      end,
    })
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    { "<leader>E", reveal, desc = "Explorer (reveal current file)" },
    { "<leader>be", "<cmd>Neotree toggle source=buffers<cr>", desc = "Explorer" },
  },
  opts = {
    close_if_last_window = true,
    default_component_configs = {
      diagnostics = {
        symbols = {
          error = icons.diagnostic.error .. " ",
          warn = icons.diagnostic.warn .. " ",
          info = "",
          hint = "",
        },
      },
      icon = {
        folder_closed = icons.file.folder_closed,
        folder_open = icons.file.folder_open,
        folder_empty = icons.file.folder_empty,
        folder_empty_open = icons.file.folder_empty_open,
      },
    },
    event_handlers = {
      {
        event = "after_render",
        handler = function(state)
          current_source = (state.display_name or state.name):match("^%s*(.-)%s*$")
        end,
      },
    },
    filesystem = {
      filtered_items = {
        always_show = {
          ".chezmoiexternals",
          ".chezmoiscripts",
          ".chezmoitemplates",
          ".chezmoi.yaml.tmpl",
          ".chezmoi.tmpl",
          ".chezmoiignore",
          ".chezmoiremove",
          ".chezmoiroot",
          ".chezmoiversion",
        },
        -- always_show_by_pattern = { will be introduced in next release after 3.26
        --   ".chezmoi*",
        --   ".chezmoi*/*",
        -- },
      },
      follow_current_file = { enabled = false },
      window = {
        mappings = {
          ["."] = function(state)
            local fs = require("neo-tree.sources.filesystem")
            local id = state.tree:get_node():get_id()
            state.commands.set_root(state)
            fs.navigate(state, nil, id, nil, false)
          end,
        },
      },
    },
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    source_selector = {
      sources = {
        { source = "filesystem" },
        { source = "buffers" },
        { source = "git_status" },
        { source = "document_symbols" },
      },
    },
    window = {
      mappings = {
        ["<space>"] = "nop",
        ["h"] = function(state)
          local node, line = state.tree:get_node()
          if (node.type == "directory" or node:has_children()) and node:is_expanded() then
            state.commands.toggle_node(state, function()
              state.commands.toggle_directory(state)
            end)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        ["l"] = function(state)
          local node, line = state.tree:get_node()
          if (node.type == "directory" or node:has_children()) and not node:is_expanded() then
            state.commands.toggle_node(state, function()
              state.commands.toggle_directory(state)
            end)
          else
            vim.api.nvim_win_set_cursor(state.winid, { line + 1, 0 })
          end
        end,
      },
    },
  },
}
