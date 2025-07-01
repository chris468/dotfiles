local util = require("chris468-tools._util")

local M = {}

local function notify(...)
	vim.schedule_wrap(vim.notify)(...)
end

---@generic TConfig
---@generic TTool : chris468.tools.Tool
---@param opts  { [string]: TConfig }
---@param Tool TTool
---@param disabled_filetypes string[]
---@return { [string]: TTool[] } tools_by_ft, { [string] : string[] } names_by_ft
function M.map_tools_by_filetype(opts, Tool, disabled_filetypes)
	disabled_filetypes = util.make_set(disabled_filetypes or {})
	local tools_by_ft = {}
	local names_by_ft = {}

	for name, config in pairs(opts) do
		---@diagnostic disable-next-line: undefined-field
		local tool = Tool:new(name, config)
		for _, ft in ipairs(tool:filetypes()) do
			if not disabled_filetypes[ft] then
				tools_by_ft[ft] = tools_by_ft[ft] or {}
				table.insert(tools_by_ft[ft], tool)

				names_by_ft[ft] = names_by_ft[ft] or {}
				table.insert(names_by_ft[ft], tool:name())
			end
		end
	end

	return tools_by_ft, names_by_ft
end

---@module "mason-core.package"

---@param tool chris468.tools.Tool The tool to install.
local function install_tool(tool)
	local display = tool:display_name()
	local enabled, reason = tool:enabled()
	if not enabled then
		if reason then
			notify(string.format("Not installing %s: %s", display, reason))
		end

		return
	end

	tool:before_install()

	local package = tool:package()
	if package and not package:is_installed() then
		notify(string.format("Installing %s...", display))
		package
			:once("install:success", function()
				notify(string.format("Successfully installed %s.", display))
				tool:on_installed()
			end)
			:once("install:failed", function()
				notify(string.format("Error installing %s.", display), vim.log.levels.WARN)
				tool:on_install_failed()
			end)
		package:install()
	else
		tool:on_installed()
	end
end

---@param tools chris468.tools.Tool[]
local function install_tools(tools)
	for _, tool in ipairs(tools) do
		install_tool(tool)
	end
end

---@param filetype string
---@param tools_by_ft { [string]: chris468.tools.Tool[] }
---@param handled_filetypes { [string]: boolean }
local function install_tools_for_filetype(filetype, tools_by_ft, handled_filetypes)
	if handled_filetypes[filetype] or not tools_by_ft[filetype] then
		return
	end
	handled_filetypes[filetype] = true

	install_tools(tools_by_ft[filetype])
end

---@param tools_by_ft { [string]: chris468.tools.Tool[] }
---@param handled_filetypes { [string]: boolean }
local function install_tools_for_existing_buffers(tools_by_ft, handled_filetypes)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype ~= "nofile" then
			local filetype = vim.bo[bufnr].filetype
			install_tools_for_filetype(filetype, tools_by_ft, handled_filetypes)
		end
	end
end

---@param tools_by_ft { [string]: chris468.tools.Tool[] }
---@param augroup integer
function M.install_on_filetype(tools_by_ft, augroup)
	local handled_filetypes = {}

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = function(arg)
			local filetype = arg.match
			install_tools_for_filetype(filetype, tools_by_ft, handled_filetypes)
		end,
	})

	install_tools_for_existing_buffers(tools_by_ft, handled_filetypes)
end

return M
