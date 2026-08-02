local M = {}

---@class chris468-notes.Config
---@field path string
---@field sync_command? string
local defaults = {
	path = "~/notes",
}

defaults.sync_command = defaults.path .. "/.scripts/sync"

---@type chris468-notes.Config
M.opts = vim.deepcopy(defaults)

---@param opts? chris468-notes.Config
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
	M.opts.path = vim.fn.expand(M.opts.path or defaults.path)
	if M.opts.sync_command then
		M.opts.sync_command = vim.fn.expand(M.opts.sync_command)
	end
end

local _m = {
	__index = function(_, key)
		return M.opts[key]
	end,
}

---@type chris468-notes.Config
return setmetatable(M, _m)
