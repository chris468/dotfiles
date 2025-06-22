---@module "plenary.busted"

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

local function wait_for_install(package_name)
  local package = require("mason-registry").get_package(package_name)
  assert_utils.wait_for(function()
    assert(not package:is_installing(), "package should finish installing")
    assert(package:is_installed(), "package should be installed")
  end)
end

---@class TestTool : chris468.tools.Tool
local TestTool = Tool:extend("TestTool") --[[ @as TestTool]]
TestTool.type = "test"

function TestTool:new(name, opts)
  return self:_new(name, opts)
end

function TestTool:__eq(other)
  return self:name() == other:name()
end

local function create_tools(config)
  local result = {}
  for group, tools in pairs(config) do
    result[group] = {}
    for name, opts in pairs(tools) do
      result[group][name] = TestTool:new(name, opts)
    end
  end
  return result
end

describe("installer", function()
  local config
  local tools
  before_each(function()
    config = {
      group1 = {
        tool1 = {
          filetypes = { "ft1", "ft2" },
        },
        tool2 = {
          filetypes = { "ft2", "ft3" },
        },
      },
      group2 = {
        tool3 = {
          filetypes = { "ft1", "ft3", "ft4" },
        },
      },
    }

    tools = create_tools(config)
  end)

  describe("map_tools_by_filetype", function()
    it("returns map of filetype to tools", function()
      local expected = setmetatable({
        ft1 = { tools.group1.tool1, tools.group2.tool3 },
        ft2 = { tools.group1.tool1, tools.group1.tool2 },
        ft3 = { tools.group1.tool2, tools.group2.tool3 },
        ft4 = { tools.group2.tool3 },
      }, by_ft_mt)

      local actual, _ = installer.map_tools_by_filetype(config, TestTool)
      setmetatable(actual, by_ft_mt)

      assert.are.equal(expected, actual)
    end)

    it("excludes tools for disabled filetypes", function()
      local expected = setmetatable({
        ft1 = { tools.group1.tool1, tools.group2.tool3 },
        ft4 = { tools.group2.tool3 },
      }, by_ft_mt)

      local actual, _ = installer.map_tools_by_filetype(config, TestTool, { "ft2", "ft3" })
      setmetatable(actual, by_ft_mt)

      assert.are.equal(expected, actual)
    end)

    it("returns map of filetype to names", function()
      local mt = by_ft_mt
      local expected = setmetatable({
        ft1 = { tools.group1.tool1:name(), tools.group2.tool3:name() },
        ft2 = { tools.group1.tool1:name(), tools.group1.tool2:name() },
        ft3 = { tools.group1.tool2:name(), tools.group2.tool3:name() },
        ft4 = { tools.group2.tool3:name() },
      }, mt)

      local _, actual = installer.map_tools_by_filetype(config, TestTool)
      setmetatable(actual, mt)

      assert.are.equal(expected, actual)
    end)

    it("excludes names of tools for disabled filetypes", function()
      local expected = setmetatable({
        ft1 = { tools.group1.tool1:name(), tools.group2.tool3:name() },
        ft4 = { tools.group2.tool3:name() },
      }, by_ft_mt)

      local _, actual = installer.map_tools_by_filetype(config, TestTool, { "ft2", "ft3" })
      setmetatable(actual, by_ft_mt)

      assert.are.equal(expected, actual)
    end)

    describe("disabled", function()
      before_each(function()
        config.group1.tool2.enabled = false
        config.group2.tool3.enabled = false
        tools = create_tools(config)
      end)

      it("omits tools", function()
        local expected = setmetatable({
          ft1 = { tools.group1.tool1 },
          ft2 = { tools.group1.tool1 },
        }, by_ft_mt)

        local actual, _ = installer.map_tools_by_filetype(config, TestTool)
        setmetatable(actual, by_ft_mt)

        assert.are.equal(expected, actual)
      end)

      it("omits tool names", function()
        local expected = setmetatable({
          ft1 = { tools.group1.tool1:name() },
          ft2 = { tools.group1.tool1:name() },
        }, by_ft_mt)

        local _, actual = installer.map_tools_by_filetype(config, TestTool)
        setmetatable(actual, by_ft_mt)

        assert.are.equal(expected, actual)
      end)
    end)
  end)

  describe("install_tool", function()
    local snapshot
    local bufnr
    local augroup
    before_each(function()
      snapshot = assert.snapshot()
      bufnr = vim.api.nvim_create_buf(true, false)
      augroup = vim.api.nvim_create_augroup("chris468-tools-test", { clear = true })
      TestTool.before_install = spy.new()
      TestTool.on_installed = spy.new()
      TestTool.on_install_failed = spy.new()
    end)
    after_each(function()
      augroup = vim.api.nvim_create_augroup("chris468-tools-test", { clear = true })
      vim.api.nvim_buf_delete(bufnr, { force = true })
      bufnr = nil
      snapshot:revert()
    end)

    describe("needs install", function()
      before_each(function()
        local InstallLocation = require("mason-core.installer.InstallLocation")
        stub(InstallLocation, "global", InstallLocation:new(vim.fn.tempname()))
      end)
      it("should install package", function()
        local tool1_spec = require("tests.utils.lua_registry.tool1")
        local install = spy.new()
        stub(tool1_spec.source, "install", install)

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        vim.wait(1000, function()
          pcall(assert.spy(install).called, 1)
        end)

        assert.spy(install).called(1)
      end)

      it("should call before install callback", function()
        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        vim.wait(1000, function()
          pcall(assert.spy(TestTool.before_install).called, 1)
        end)

        assert.spy(TestTool.before_install).called(1)
        assert.spy(TestTool.before_install).called_with(tools.group1.tool1)
      end)

      it("should call success callback", function()
        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        wait_for_install("tool1")

        assert.spy(TestTool.on_installed).called(1)
        assert.spy(TestTool.on_installed).called_with(tools.group1.tool1, bufnr)
      end)

      it("should call failed callback", function()
        local tool1_spec = require("tests.utils.lua_registry.tool1")
        stub(tool1_spec.source, "install", function()
          error("install failed")
        end)

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        assert.spy(TestTool.on_install_failed).called(1)
        assert.spy(TestTool.on_install_failed).called_with(tools.group1.tool1, bufnr)
      end)
    end)

    describe("already installed", function()
      before_each(function()
        stub(tools.group1.tool1:package(), "is_installed", true)
      end)

      it("should not install package", function()
        local tool1_spec = require("tests.utils.lua_registry.tool1")
        local install = spy.new()
        stub(tool1_spec.source, "install", install)

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        assert.spy(install).called(0)
      end)

      it("should call before install callback", function()
        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        assert.spy(TestTool.before_install).called(1)
        assert.spy(TestTool.before_install).called_with(tools.group1.tool1)
      end)

      it("should call success callback", function()
        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        vim.wait(1000, function()
          pcall(assert.spy(TestTool.on_installed).called, 1)
        end)
        assert.spy(TestTool.on_installed).called(1)
        assert.spy(TestTool.on_installed).called_with(tools.group1.tool1, bufnr)
      end)
    end)
  end)
end)
