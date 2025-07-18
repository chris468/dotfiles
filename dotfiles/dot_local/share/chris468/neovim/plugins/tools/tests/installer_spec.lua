local assert = require("luassert.assert")
local spy = require("luassert.spy")
local stub = require("luassert.stub")

local Tool = require("chris468-tools.tool")
local installer = require("chris468-tools.installer")

local assert_utils = require("tests.utils.assert")

local by_ft_mt = {}
function by_ft_mt:__eq(other)
	return #vim.tbl_keys(self) == #vim.tbl_keys(other)
		and vim.iter(self):all(function(ft, tools)
			return vim.iter(tools):all(function(tool)
				return other[ft]
					and vim.iter(other[ft]):any(function(other_tool)
						return tool == other_tool
					end)
			end)
		end)
end

---@param filetype string
---@param bufnr integer
---@param ... string
local function wait_for_install(filetype, bufnr, ...)
	local package_names = { ... }
	local complete = {}

	for _, package_name in ipairs(package_names) do
		local package = require("mason-registry").get_package(package_name)
		assert(not package:is_installed(), package_name .. " should not already be installed")

		complete[package_name] = false

		package
			:once("install:success", function()
				complete[package_name] = true
			end)
			:once("install:failed", function()
				complete[package_name] = true
			end)
	end

	vim.bo[bufnr].filetype = filetype

	assert_utils.wait_for(function()
		assert(
			vim.iter(complete):all(function(_, v)
				return v
			end),
			"install incomplete: " .. vim.inspect(complete)
		)
	end)
end

---@class TestTool : chris468.tools.Tool
local TestTool = Tool:extend() --[[ @as TestTool]]
TestTool.type = "test"

function TestTool:new(name, opts)
	return self:_new(name, opts)
end

function TestTool:__eq(other)
	return self:name() == other:name()
end

local function create_tools(config) end

describe("installer", function()
	local config
	local tools
	local tools_by_ft
	local names_by_ft

	local function set_tools()
		tools = {}
		tools_by_ft = setmetatable({}, by_ft_mt)
		names_by_ft = setmetatable({}, by_ft_mt)

		for name, opts in pairs(config) do
			local t = TestTool:new(name, opts)
			tools[name] = t
			for _, ft in ipairs(t:filetypes()) do
				tools_by_ft[ft] = tools_by_ft[ft] or {}
				table.insert(tools_by_ft[ft], t)

				names_by_ft[ft] = names_by_ft[ft] or {}
				table.insert(names_by_ft[ft], name)
			end
		end
	end

	before_each(function()
		config = {
			tool1 = {
				filetypes = { "ft1", "ft2" },
			},
			tool2 = {
				filetypes = { "ft2", "ft3" },
			},
			tool3 = {
				filetypes = { "ft1", "ft3", "ft4" },
			},
		}

		set_tools()
	end)

	describe("map_tools_by_filetype", function()
		it("returns map of filetype to tools", function()
			local actual, _ = installer.map_tools_by_filetype(config, TestTool, {})
			setmetatable(actual, by_ft_mt)

			assert.are.equal(tools_by_ft, actual)
		end)

		it("excludes tools for disabled filetypes", function()
			local expected = setmetatable({
				ft1 = { tools.tool1, tools.tool3 },
				ft4 = { tools.tool3 },
			}, by_ft_mt)

			local actual, _ = installer.map_tools_by_filetype(config, TestTool, { "ft2", "ft3" })
			setmetatable(actual, by_ft_mt)

			assert.are.equal(expected, actual)
		end)

		it("returns map of filetype to names", function()
			local _, actual = installer.map_tools_by_filetype(config, TestTool, {})
			setmetatable(actual, by_ft_mt)

			assert.are.equal(names_by_ft, actual)
		end)

		it("excludes names of tools for disabled filetypes", function()
			local expected = setmetatable({
				ft1 = { tools.tool1:name(), tools.tool3:name() },
				ft4 = { tools.tool3:name() },
			}, by_ft_mt)

			local _, actual = installer.map_tools_by_filetype(config, TestTool, { "ft2", "ft3" })
			setmetatable(actual, by_ft_mt)

			assert.are.equal(expected, actual)
		end)

		describe("disabled", function()
			before_each(function()
				config.tool2.enabled = false
				config.tool3.enabled = false
				set_tools()
			end)

			it("includes tools", function()
				local actual, _ = installer.map_tools_by_filetype(config, TestTool, {})
				setmetatable(actual, by_ft_mt)

				assert.are.equal(tools_by_ft, actual)
			end)

			it("includes tool names", function()
				local _, actual = installer.map_tools_by_filetype(config, TestTool, {})
				setmetatable(actual, by_ft_mt)

				assert.are.equal(names_by_ft, actual)
			end)
		end)
	end)

	describe("installer", function()
		local snapshot
		local bufnr, bufnr2
		local augroup

		local tool

		before_each(function()
			snapshot = assert.snapshot()
			bufnr = vim.api.nvim_create_buf(true, false)
			bufnr2 = vim.api.nvim_create_buf(true, false)
			augroup = vim.api.nvim_create_augroup("chris468-tools-test", { clear = true })
			tool = tools.tool1

			local InstallLocation = require("mason-core.installer.InstallLocation")
			stub(InstallLocation, "global", InstallLocation:new(vim.fn.tempname()))
		end)

		after_each(function()
			augroup = vim.api.nvim_create_augroup("chris468-tools-test", { clear = true })
			vim.api.nvim_buf_delete(bufnr, { force = true })
			bufnr = nil
			vim.api.nvim_buf_delete(bufnr2, { force = true })
			bufnr2 = nil
			require("mason-core.terminator").terminate(10)

			snapshot:revert()
		end)

		it("gets filetype event from setting filetype", function()
			local cb = spy.new()
			vim.api.nvim_create_autocmd("FileType", {
				group = augroup,
				callback = function()
					cb(a)
				end,
			})

			vim.bo[bufnr].filetype = "ft"

			assert.spy(cb).called(1)
		end)

		it("gets filetype event from raising filetype", function()
			local cb = spy.new()
			vim.api.nvim_create_autocmd("FileType", {
				group = augroup,
				callback = function()
					cb(a)
				end,
			})

			vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })

			assert.spy(cb).called(1)
		end)

		describe("needs install", function()
			it("should install package", function()
				installer.install_on_filetype({ ft = { tool } }, augroup)

				wait_for_install("ft", bufnr, "tool1")
			end)

			it("should call before install callback", function()
				local before_install = spy.on(tool, "before_install")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				wait_for_install("ft", bufnr, "tool1")

				assert.spy(before_install).called(1)
				assert.spy(before_install).called_with(tool)
			end)

			it("should call success callback", function()
				local on_installed = spy.on(tool, "on_installed")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				vim.bo[bufnr].filetype = "ft"
				wait_for_install("ft", bufnr, "tool1")

				assert.spy(on_installed).called(1)
				assert.spy(on_installed).called_with(tool)
			end)

			it("should not call failed callback", function()
				local on_install_failed = spy.on(tool, "on_install_failed")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				wait_for_install("ft", bufnr, "tool1")

				assert.spy(on_install_failed).called(0)
			end)

			it("should call failed callback", function()
				local tool1_spec = require("tests.utils.lua_registry.tool1")
				stub(tool1_spec.source, "install", function()
					error("install failed")
				end)
				local on_install_failed = spy.on(tool, "on_install_failed")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				wait_for_install("ft", bufnr, "tool1")

				assert.spy(on_install_failed).called(1)
				assert.spy(on_install_failed).called_with(tool)
			end)

			it("should not call success callback", function()
				local tool1_spec = require("tests.utils.lua_registry.tool1")
				stub(tool1_spec.source, "install", function()
					error("install failed")
				end)
				local on_installed = spy.on(tool, "on_installed")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				wait_for_install("ft", bufnr, "tool1")

				assert.spy(on_installed).called(0)
			end)

			it("should install for pre-existing buffers", function()
				vim.bo[bufnr2].filetype = "ft2"

				installer.install_on_filetype({ ft = { tool }, ft2 = { tools.tool2 } }, augroup)
				wait_for_install("ft", bufnr, "tool1", "tool2")
			end)

			it("should not install disabled tool", function()
				config.tool1.enabled = false
				set_tools()
				local install = spy.on(require("tests.utils.lua_registry.tool1").source, "install")

				installer.install_on_filetype({ ft = { tools.tool1, tools.tool2 } }, augroup)
				wait_for_install("ft", bufnr, "tool2")

				assert_utils.wait_for(function()
					assert.spy(install).called(0)
				end, { success = true })
			end)

			it("should notify if reason", function()
				config.tool1.enabled = function()
					return false, "reason"
				end
				set_tools()
				local notify = spy.on(vim, "notify")

				installer.install_on_filetype({ ft = { tools.tool1 } }, augroup)
				vim.bo[bufnr].filetype = "ft"

				assert_utils.wait_for(function()
					assert.spy(notify).called(1)
					assert.spy(notify).called_with("Not installing test tool1: reason")
				end)
			end)

			it("should not notify if no reason", function()
				config.tool1.enabled = function()
					return false
				end
				set_tools()
				local notify = spy.on(vim, "notify")

				installer.install_on_filetype({ ft = { tools.tool1 } }, augroup)
				vim.bo[bufnr].filetype = "ft"

				assert_utils.wait_for(function()
					assert.spy(notify).called(0)
				end, { success = true })
			end)
		end)

		describe("already installed", function()
			before_each(function()
				stub(tool:package(), "is_installed", true)
			end)

			it("should not install package", function()
				local install = spy.on(require("tests.utils.lua_registry.tool1").source, "install")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				vim.bo[bufnr].filetype = "ft"

				assert_utils.wait_for(function()
					assert.spy(install).called(0)
				end, { success = true })
			end)

			it("should call before install callback", function()
				local before_install = spy.on(tool, "before_install")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				vim.bo[bufnr].filetype = "ft"

				assert.spy(before_install).called(1)
				assert.spy(before_install).called_with(tool)
			end)

			it("should call success callback", function()
				local on_installed = spy.on(tool, "on_installed")

				installer.install_on_filetype({ ft = { tool } }, augroup)
				vim.bo[bufnr].filetype = "ft"

				assert.spy(on_installed).called(1)
				assert.spy(on_installed).called_with(tool)
			end)
		end)

		describe("multiple tools", function()
			it("installs all tools", function()
				installer.install_on_filetype(tools_by_ft, augroup)

				wait_for_install("ft3", bufnr, "tool2", "tool3")
			end)

			it("installs all tools when some fail", function()
				local tool2_spec = require("tests.utils.lua_registry.tool2")
				stub(tool2_spec.source, "install", function()
					error("install failed")
				end)
				installer.install_on_filetype(tools_by_ft, augroup)

				wait_for_install("ft3", bufnr, "tool2", "tool3")
			end)
		end)
	end)
end)
