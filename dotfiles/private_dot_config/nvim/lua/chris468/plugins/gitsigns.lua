local function set_mappings(bufnr)
  local gitsigns = require("gitsigns")

  local function next()
    return function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end
  end

  local function previous()
    return function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end
  end

  local function blame_line()
    return function()
      gitsigns.blame_line({ full = true })
    end
  end

  local function diff_head()
    return function()
      gitsigns.diffthis("~")
    end
  end

  local function stage_selected_hunk()
    return function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end
  end

  local function reset_selected_hunk()
    return function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end
  end

  local mode_mappings = {
    n = {
      { "]c", next(), desc = "Next hunk" },
      { "[c", previous(), desc = "Previous hunk" },
      { "<leader>gs", gitsigns.stage_hunk, desc = "Stage hunk" },
      { "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk" },
      { "<leader>gS", gitsigns.stage_buffer, desc = "Stage buffer" },
      { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage hunk" },
      { "<leader>gR", gitsigns.reset_buffer, desc = "Reset buffer" },
      { "<leader>gp", gitsigns.preview_hunk, desc = "Preview hunk" },
      { "<leader>gb", blame_line(), desc = "Blame line" },
      { "<leader>gd", gitsigns.diffthis, desc = "Diff vs index" },
      { "<leader>gD", diff_head(), desc = "Diff vs HEAD" },
      { "<leader>gtb", gitsigns.toggle_current_line_blame, desc = "Toggle blame current line" },
      { "<leader>gtd", gitsigns.toggle_deleted, desc = "Toggle deleted" },
    },
    v = {
      { "<leader>gs", stage_selected_hunk(), desc = "Stage selected hunk" },
      { "<leader>gr", reset_selected_hunk(), desc = "Reset selected hunk" },
    },
    [{ "o", "x" }] = {
      {
        "ih",
        function()
          vim.cmd("Gitsigns select_hunk")
        end,
        desc = "Git hunk",
      },
    },
  }

  for modes, mappings in pairs(mode_mappings) do
    if type(modes) ~= "table" then
      modes = { modes }
    end
    for _, m in ipairs(mappings) do
      for _, mode in ipairs(modes) do
        vim.api.nvim_buf_set_keymap(bufnr, mode, m[1], "", { desc = m.desc, callback = m[2] })
      end
    end
  end
end

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = {
    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "╻" },
      topdelete = { text = "╹" },
      changedelete = { text = "┃" },
      untracked = { text = "┆" },
    },
    on_attach = set_mappings,
  },
}
