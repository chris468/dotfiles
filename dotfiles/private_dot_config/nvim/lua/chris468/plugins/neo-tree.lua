local icons = require("chris468.config.icons")

local function reveal()
  local buf = vim.bo.filetype == "neo-tree" and "#" or "%"
  local reveal_file = vim.fn.expand(buf .. ":p")
  vim.notify("reveal " .. buf .. ": '" .. reveal_file .. "'")
  require("neo-tree.command").execute({
    reveal_file = vim.fn.expand(buf .. ":p"),
  })
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = { "Neotree" },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons", optional = true },
    { "MunifTanjim/nui.nvim" },
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    { "<leader>E", reveal, desc = "Explorer (reveal current file)" },
    { "<leader>be", "<cmd>Neotree toggle source=buffers<cr>", desc = "Explorer" },
  },
  opts = {
    filesystem = {
      follow_current_file = { enabled = false },
    },
    default_component_configs = {
      symbols = {
        error = icons.error,
        warn = icons.warn,
        hint = icons.hint,
        info = icons.info,
      },
    },
    window = {
      mappings = {
        ["<space>"] = "nop",
      },
    },
  },
}
