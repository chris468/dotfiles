if LazyVim.pick.picker.name ~= "telescope" then
  return {}
end

local captured_opts = {}
local function capture_builtin_opts()
  local builtin = require("telescope.builtin")
  for k, v in pairs(builtin) do
    builtin[k] = function(o)
      captured_opts = o
      v(o)
    end
  end
end

local function toggle_opt(builtin, key, display)
  return function()
    display = vim.tbl_extend("keep", display or {}, {
      [true] = key .. " enabled",
      [false] = key .. " disabled",
    })

    captured_opts[key] = not captured_opts[key]
    captured_opts.default_text = require("telescope.actions.state").get_current_line()
    require("telescope.builtin")[builtin](captured_opts)
    vim.notify(display[captured_opts[key]])
  end
end

---@param modes string|string[]
---@param mappings { [string]: (table|string|fun()) }
---@return { [string]: { [string]: (table|string|fun()) } }
---@overload fun(mappings: { [string]: (table|string|function) }) : { [string]: { [string]: (table|string|fun()) } }
local function mappings_for_modes(modes, mappings)
  if not mappings then
    mappings = modes --[[ @diagnostic disable-line: cast-local-type ]]
    modes = { "n", "i" }
  end
  modes = type(modes) == "table" and modes or { modes }
  return vim.iter(modes):fold({}, function(result, m)
    result[m] = mappings
    return result
  end)
end

local function file_mappings(builtin)
  return mappings_for_modes({
    ["<C-E>i"] = {
      toggle_opt(builtin, "no_ignore", {
        [true] = "Including ignored",
        [false] = "Excluding ignored",
      }),
      type = "action",
      opts = { desc = "Toggle ignored" },
    },
    ["<C-E>h"] = {
      toggle_opt(builtin, "hidden", {
        [true] = "Including hidden",
        [false] = "Excluding hidden",
      }),
      type = "action",
      opts = { desc = "Toggle hidden" },
    },
  })
end

local oldfiles_mappings = mappings_for_modes({
  ["<C-E>c"] = {
    toggle_opt("oldfiles", "cwd_only", {
      [true] = "Working directory only",
      [false] = "Anywhere",
    }),
    type = "action",
    opts = { desc = "Toggle cwd only" },
  },
})

---@type LazyPluginSpec[]
return {
  {
    "telescope.nvim",
    config = function(_, opts)
      require("telescope").setup(opts)
      capture_builtin_opts()
    end,
    keys = {
      { "<leader>sL", "<cmd>Telescope loclist<cr>", desc = "Location List" },
      { "<leader>sl", "<cmd>Telescope lazy<CR>", desc = "Lazy" },
    },
    opts = {
      defaults = {
        dynamic_preview_title = true,
        layout_config = {
          prompt_position = "top",
          mirror = true,
        },
        layout_strategy = "vertical",
        mappings = mappings_for_modes({
          ["<C-f>"] = "results_scrolling_down",
          ["<C-b>"] = "results_scrolling_up",
          ["<C-/>"] = "which_key",
          ["<C-_>"] = "which_key",
          ["<C-k>"] = "nop",
          ["<M-f>"] = "nop",
          ["<M-k>"] = "nop",
          ["<M-q>"] = "nop",
        }),
        prompt_prefix = " ",
        sorting_strategy = "ascending",
      },
      pickers = {
        find_files = {
          mappings = file_mappings("find_files"),
        },
        live_grep = {
          mappings = file_mappings("live_grep"),
        },
        oldfiles = {
          mappings = oldfiles_mappings,
        },
      },
    },
  },
  {
    "tsakirist/telescope-lazy.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("lazy")
      end)
    end,
  },
}
