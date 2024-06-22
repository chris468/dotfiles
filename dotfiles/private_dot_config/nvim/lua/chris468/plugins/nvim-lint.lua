local tools = require("chris468.config.lang").tools

--- @return chris468.util.mason.ToolsForFiletype
function get_linters()
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
        local linters_to_install = {}
        for ft, linters in pairs(linters_by_ft) do
          linters_to_install[ft] = {}
          for _, l in ipairs(linters) do
            linters_to_install[ft][#linters_to_install[ft] + 1] = {
              l,
              callback = function()
                local lint = require("lint")
                lint.try_lint()
              end,
            }
          end
        end

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
