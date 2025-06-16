local Tool = require("chris468-tools.tool").Tool
local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")

local M = {}

---@class chris468.tools.Linter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Linter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Linter
M.Linter = Tool:extend() --[[ @as chris468.tools.Linter ]]
M.Linter.type = "linter"
function M.Linter:new(name, opts)
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

function M.setup(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts.linters, M.Linter)
  require("lint").linters_by_ft = names_by_ft
  lazily_install_tools_by_filetype(tools_by_ft, disabled_filetypes, "linter")
  register_lint(tools_by_ft)
end

return M
