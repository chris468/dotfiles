local tools = require("chris468.config.lang").tools

--- @return chris468.util.mason.ToolsForFiletype
local function get_linters()
  local result = {}
  for ft, t in pairs(tools) do
    result[ft] = t.lint
  end

  return result
end

local linters_by_ft = get_linters()

return {
  "mfussenegger/nvim-lint",
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      callback = function()
        if vim.bo.buftype ~= "help" then
          lint.try_lint()
        end
      end,
      desc = "Lint on save",
    })
  end,
  event = { "BufReadPost", "BufWritePost" },
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        local function try_lint()
          local lint = require("lint")
          lint.try_lint()
        end

        --- @type chris468.util.mason.ToolsForFiletype
        local linters_to_install = vim.tbl_map(function(linters)
          return vim.tbl_map(function(linter)
            --- @type chris468.util.mason.Tool
            return {
              package_name = linter,
              callback = try_lint,
            }
          end, linters)
        end, linters_by_ft)

        opts.install_for_filetype = vim.tbl_extend("error", opts.install_for_filetype or {}, {
          linter = linters_to_install,
        })
      end,
    },
  },
  opts = {
    linters_by_ft = linters_by_ft,
  },
}
