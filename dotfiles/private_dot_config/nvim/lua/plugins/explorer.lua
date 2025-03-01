return LazyVim.has_extra("editor.telescope")
    and {
      { "saifulapm/neotree-file-nesting-config", lazy = true },
      {
        "neo-tree.nvim",
        opts = function(_, opts)
          local overrides = {
            nesting_rules = vim.tbl_deep_extend("force", require("neotree-file-nesting-config").nesting_rules, {
              Dockerfile = {
                pattern = "^Dockerfile$",
                files = {
                  "Dockerfile.*",
                  ".dockerignore",
                },
              },
              docker_compose = {
                pattern = "^docker%-compose%.ya?ml",
                files = {
                  "docker-compose.*.yml",
                  "docker-compose.*.yaml",
                },
              },
              helm = {
                pattern = "^Chart.yaml$",
                files = {
                  "Chart.lock",
                  ".helmignore",
                },
              },
            }),

            window = {
              mappings = {
                ["<space>"] = "nop",
                ["h"] = function(state)
                  local node, _ = state.tree:get_node()
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
          }

          return vim.tbl_deep_extend("force", opts, overrides)
        end,
      },
    }
  or {}
