local Tool = require("chris468-tools.tool")
local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")

---@class chris468.tools.Linter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Linter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Linter
Linter = Tool:extend() --[[ @as chris468.tools.Linter ]]
Linter.type = "linter"
function Linter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Linter ]]
end

---@param linters string[]
local function run_installed_linters(linters)
  local installed_linters = vim.tbl_filter(function(v)
    return v:package() and v:package():is_installed()
  end, linters)

  if #installed_linters > 0 then
    require("lint").try_lint(vim.tbl_map(function(v)
      return v:name()
    end, installed_linters))
  end
end

---@param linters_by_ft table<string, chris468.tools.Tool[]>
local function register_lint(linters_by_ft)
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("chris468.lint", { clear = true }),
    callback = function()
      local linters = linters_by_ft[vim.bo.filetype] or {}
      run_installed_linters(linters)
    end,
  })
end

function Linter.setup(opts)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts.linters, Linter, opts.disabled_filetypes)
  require("lint").linters_by_ft = names_by_ft
  register_lint(tools_by_ft)
  installer.install_on_filetype(tools_by_ft, vim.api.nvim_create_augroup("chris468-tools.formatter", { clear = true }))
end

return Linter
