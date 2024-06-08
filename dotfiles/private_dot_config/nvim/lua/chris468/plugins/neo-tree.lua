local icons = require("chris468.config.icons").diagnostic

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
          error = icons.error .. " ",
          warn = icons.warn .. " ",
          info = "",
          hint = "",
        },
      },
    },
    filesystem = {
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
    window = {
      mappings = {
        ["<space>"] = "nop",
      },
    },
  },
}
