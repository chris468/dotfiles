local cmd = require("chris468.util.keymap").cmd

local function toggle_terminal()
  require("toggleterm").toggle(vim.v.count1, nil, nil, nil, ("Terminal %s"):format(vim.v.count1))
end

local term_mappings = {
  { "<C-H>", cmd("TmuxNavigateLeft"), desc = "Navigate left", mode = "t" },
  { "<C-J>", cmd("TmuxNavigateDown"), desc = "Navigate down", mode = "t" },
  { "<C-K>", cmd("TmuxNavigateUp"), desc = "Navigate up", mode = "t" },
  { "<C-L>", cmd("TmuxNavigateRight"), desc = "Navigate right", mode = "t" },
}

local function enable_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_mappings = true
  for _, mapping in ipairs(term_mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[2], {
      desc = mapping.desc,
      buffer = bufnr,
    })
  end
end

local function disable_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_mappings = false
  for _, mapping in ipairs(term_mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[1], {
      buffer = bufnr,
      remap = false,
    })
  end
end

local function toggle_mappings()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "toggleterm" then
    return
  end

  -- Previous state is enabled if nil or true, disabled if false
  -- New state is enabled if false, disabled if nil or true
  local enable = vim.b[bufnr].chris468_terminal_mappings == false
  if enable then
    enable_mappings(bufnr)
  else
    disable_mappings(bufnr)
  end
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "TermExec", "TermSelect", "ToggleTerm", "ToggleTermToggleAll" },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      vim.api.nvim_create_autocmd("Filetype", {
        callback = function(arg)
          local bufnr = arg.buf
          if vim.b[bufnr].chris468_terminal_mappings == nil then
            enable_mappings(bufnr)
          end
        end,
        group = vim.api.nvim_create_augroup("chris468.toggleterm", { clear = true }),
        pattern = "toggleterm",
      })
    end,
    keys = vim.list_extend({
      { "<C-/>", toggle_terminal, desc = "Toggle term", mode = { "n", "i", "t" } },
      { "<C-_>", toggle_terminal, desc = "Toggle term", mode = { "n", "i", "t" } },
      { [[<C-\><C-\>]], toggle_mappings, desc = "Toggle mappings", mode = "t" },
      {
        [[<C-\><C-R>]],
        function()
          return [[<C-\><C-N>"]]
            .. vim.fn.nr2char(vim.fn.getchar() --[[@as integer ]])
            .. "pi"
        end,
        desc = "Registers",
        expr = true,
        mode = "t",
      },
    }, term_mappings),
    opts = {},
  },
}
