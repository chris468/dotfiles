---@param show_hidden boolean
local function mini_files_filter(show_hidden)
  return function(fs_entry)
    return show_hidden or not vim.startswith(fs_entry.name, ".")
  end
end

local function update_keymaps(buf)
  buf = buf or 0
  if vim.bo[buf].filetype ~= "minifiles" then
    return
  end

  print("updating for " .. vim.inspect(buf) .. " " .. vim.api.nvim_buf_get_name(buf))
  local arrow_navigation = vim.g.chris468_mini_files_arrow_navigation or false
  local b = vim.b[buf]
  if b.chris468_mini_files_arrow_navigation == arrow_navigation then
    print("bailing " .. vim.inspect({
      buffer_setting = (b.chris468_mini_files_arrow_navigation == nil and "nil")
        or b.chris468_mini_files_arrow_navigation,
      global_setting = (vim.g.chris468_mini_files_arrow_navigation == nil and "nil")
        or vim.g.chris468_mini_files_arrow_navigation,
    }))

    return
  end

  local mini_files_action = {
    right = function()
      MiniFiles.go_in({ close_on_file = true })
    end,
    shift_right = MiniFiles.go_in,
    left = MiniFiles.go_out,
    shift_left = function()
      for _ = 1, vim.v.count1 do
        MiniFiles.go_out()
      end
      MiniFiles.trim_right()
    end,
  }

  local mini_files_navigation = {
    [false] = {
      ["h"] = mini_files_action.left,
      ["H"] = mini_files_action.shift_left,
      ["l"] = mini_files_action.right,
      ["L"] = mini_files_action.shift_right,
    },
    [true] = {
      ["<Left>"] = mini_files_action.left,
      ["<S-Left>"] = mini_files_action.shift_left,
      ["<Right>"] = mini_files_action.right,
      ["<S-Right>"] = mini_files_action.shift_right,
    },
  }

  print("setting to " .. vim.inspect(arrow_navigation))
  b.chris468_mini_files_arrow_navigation = arrow_navigation
  for key, action in pairs(mini_files_navigation[arrow_navigation]) do
    vim.keymap.set("n", key, action, { buffer = buf })
  end
  for key, _ in pairs(mini_files_navigation[not arrow_navigation]) do
    vim.keymap.set("n", key, key, { buffer = buf, remap = false })
  end
end

local mini_files_split = function(direction)
  return function()
    local fs_entry = MiniFiles.get_fs_entry() or {}
    if fs_entry.fs_type ~= "file" then
      return
    end

    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)

    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("chris468_mini_files_toggle_navigation", { clear = true }),
  callback = function(args)
    update_keymaps(args.buf)
  end,
})

return {
  {
    "echasnovski/mini.surround",
    keys = {
      "gsa",
      "gsd",
      "gsf",
      "gsF",
      "gsh",
      "gsr",
      "gsn",
    },
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
    verion = "*",
  },
  {
    "stevearc/oil.nvim",
    cond = Chris468.ui.explorer.plugin == "oil",
    dependencies = { "mini.icons" },
    keys = {
      {
        "<leader>e",
        function()
          require("oil").toggle_float(vim.uv.cwd())
        end,
        desc = "Explore",
      },
      {
        "<leader>E",
        function()
          require("oil").toggle_float()
        end,
        desc = "Explore buffer directory",
      },
    },
    opts = {},
    lazy = false,
  },
  {
    "echasnovski/mini.files",
    cond = Chris468.ui.explorer.plugin == "mini.files",
    dependencies = { "mini.icons" },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open()
        end,
        desc = "Explore",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0))
        end,
        desc = "Explore buffer directory",
      },
      {
        "g.",
        function()
          vim.g.chris468_mini_files_show_hidden = not vim.g.chris468_mini_files_show_hidden
          MiniFiles.refresh({ content = { filter = mini_files_filter(vim.g.chris468_mini_files_show_hidden) } })
        end,
        desc = "Toggle hidden files",
        ft = "minifiles",
      },
      {
        "g<C-N>",
        function()
          vim.g.chris468_mini_files_arrow_navigation = not vim.g.chris468_mini_files_arrow_navigation
          update_keymaps()
        end,
        desc = "Toggle arrow navigation",
        ft = "minifiles",
      },
      {
        "<C-X>",
        mini_files_split("horizontal"),
        desc = "Open in horizontal split",
        ft = "minifiles",
      },
      {
        "<C-V>",
        mini_files_split("vertical"),
        desc = "Open in vertical split",
        ft = "minifiles",
      },
      {
        "<C-T>",
        mini_files_split("tab"),
        desc = "Open in new tab",
        ft = "minifiles",
      },
    },
    lazy = false,
    opts = {
      content = {
        filter = mini_files_filter(vim.g.chris468_mini_files_show_hidden or false),
      },
      options = {
        use_as_default_explorer = true,
      },
      mappings = {
        close = "<Esc>",
        go_in = "<C-Space>",
        go_in_plus = "<Enter>",
        go_out = "-",
        go_out_plus = "<BS>",
        reset = "g<C-R>",
      },
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufWinEnter", "FileType", "ColorScheme" },
    opts = {
      user_default_options = {
        mode = "virtualtext",
        virtualtext_inline = true,
        names = false,
      },
    },
  },
  {
    "folke/snacks.nvim",
    event = "BufWinEnter",
    opts = {
      indent = {
        animate = {
          enabled = false,
        },
        indent = {
          char = "┊",
        },
        scope = {
          char = "┊",
          hl = "@keyword",
        },
      },
    },
  },
  {
    "luukvbaal/statuscol.nvim",
    event = "BufWinEnter",
    opts = function(_, opts)
      local builtin = require("statuscol.builtin")
      return vim.tbl_deep_extend("keep", opts or {}, {
        segments = {
          { text = { builtin.foldfunc } },
          {
            sign = {
              name = { ".*" },
              text = { ".*" },
              colwidth = 1,
            },
          },
          { text = { builtin.lnumfunc } },
          {
            sign = {
              namespace = { "gitsigns" },
              colwidth = 1,
            },
          },
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufWinEnter",
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
    },
    opts = {},
  },
  {
    "MisanthropicBit/decipher.nvim",
    keys = require("chris468.plugins.config.decipher").mappings(),
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter",
      "mini.icons",
    }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown" },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Toggle markdown preview" },
    },
    opts_extend = { "file_types" },
    opts = {
      completions = {
        lsp = { enabled = true },
      },
      code = {
        sign = false,
        language = true,
      },
      file_types = {
        "markdown",
      },
    },
  },
}
