---@module "snacks.picker.core.actions"
---@type table<string, snacks.picker.Action.spec>
local snacks_explorer_actions = {
  open_in_oil = function(_, item)
    if not item.file then
      return
    end

    local Path = require("plenary").path
    local dir = Path:new(item.file)
    if not dir:is_dir() then
      dir = dir:parent()
    end

    require("oil").open_float(dir:absolute())
  end,
}

local snacks_explorer_keys = {
  ["<Esc>"] = false,
  ["<C-O>"] = "open_in_oil",
}

return {
  {
    -- TODO: snacks-rename integration
    "stevearc/oil.nvim",
    dependencies = { "mini.icons", "plenary.nvim" },
    cmd = "Oil",
    keys = {
      {
        "<leader>fo",
        function()
          local root = LazyVim.root({ normalize = true })
          require("oil").toggle_float(root)
        end,
        desc = "Oil explorer (root dir) ",
      },
      {
        "<leader>fO",
        function()
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          require("oil").toggle_float(cwd)
        end,
        desc = "Oil explorer (cwd) ",
      },
      {
        "<leader><C-O>",
        function()
          local Path = require("plenary").path
          local p = Path:new(vim.api.nvim_buf_get_name(0))
          if not p:is_dir() then
            p = p:parent()
          end

          require("oil").toggle_float(p:absolute())
        end,
        desc = "Oil explorer (current buffer's dir) ",
      },
    },
    opts = {
      float = {
        border = "rounded",
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = false,
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
        q = "actions.close",
      },
    },
  },
  {
    "snacks.nvim",
    dependencies = { "plenary.nvim" },
    opts = {
      picker = {
        sources = {
          explorer = {
            actions = snacks_explorer_actions,
            win = {
              input = {
                keys = snacks_explorer_keys,
              },
              list = {
                keys = snacks_explorer_keys,
              },
            },
          },
        },
      },
    },
  },
}
