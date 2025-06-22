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
  assert(not package:is_installed(), "package should not already be installed")

  local finished = spy.new()
  package
    :once("install:success", function()
      finished()
    end)
    :once("install:failed", function()
      finished()
    end)
  assert_utils.wait_for(function()
    assert.spy(finished).called()
  end)
end

local function create_test_tool()
  local TestTool = Tool:extend("TestTool")
  TestTool.type = "test"

  function TestTool:new(name, opts)
    return self:_new(name, opts)
  end

  function TestTool:__eq(other)
    return self:name() == other:name()
  end

  return TestTool
end

local function create_tools(cfg, TestTool)
  local result = {}
  for group, ts in pairs(cfg) do
    result[group] = {}
    for name, opts in pairs(ts) do
      result[group][name] = TestTool:new(name, opts)
    end
  end
  return result
end

describe("installer", function()
  local TestTool
  local config
  local tools

  before_each(function()
    TestTool = create_test_tool()

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

    tools = create_tools(config, TestTool)
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
        tools = create_tools(config, TestTool)
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
    end)

    after_each(function()
      augroup = vim.api.nvim_create_augroup("chris468-tools-test", { clear = true })
      vim.api.nvim_buf_delete(bufnr, { force = true })
      bufnr = nil
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
        wait_for_install("tool1")

        assert.spy(install).called(1)
      end)

      it("should call before install callback", function()
        local before_install = spy.on(TestTool, "before_install")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"
        wait_for_install("tool1")

        assert.spy(before_install).called(1)
        assert.spy(before_install).called_with(tools.group1.tool1)
      end)

      it("should call success callback", function()
        local on_installed = spy.on(TestTool, "on_installed")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"
        wait_for_install("tool1")

        assert.spy(on_installed).called(1)
        assert.spy(on_installed).called_with(tools.group1.tool1, bufnr)
      end)

      it("should not call failed callback", function()
        local on_install_failed = spy.on(TestTool, "on_install_failed")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"
        wait_for_install("tool1")

        assert.spy(on_install_failed).called(0)
      end)

      it("should call failed callback", function()
        local tool1_spec = require("tests.utils.lua_registry.tool1")
        stub(tool1_spec.source, "install", function()
          error("install failed")
        end)
        local on_install_failed = spy.on(TestTool, "on_install_failed")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"
        wait_for_install("tool1")

        assert.spy(on_install_failed).called(1)
        assert.spy(on_install_failed).called_with(tools.group1.tool1, bufnr)
      end)

      it("should not call success callback", function()
        local tool1_spec = require("tests.utils.lua_registry.tool1")
        stub(tool1_spec.source, "install", function()
          error("install failed")
        end)
        local on_installed = spy.on(TestTool, "on_installed")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"
        wait_for_install("tool1")

        assert.spy(on_installed).called(0)
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

        assert_utils.wait_for(function()
          assert.spy(install).called(0)
        end, { success = true })
      end)

      it("should call before install callback", function()
        local before_install = spy.on(TestTool, "before_install")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        assert.spy(before_install).called(1)
        assert.spy(before_install).called_with(tools.group1.tool1)
      end)

      it("should call success callback", function()
        local on_installed = spy.on(TestTool, "on_installed")

        installer.install_on_filetype({ ft = { tools.group1.tool1 } }, augroup)
        vim.bo[bufnr].filetype = "ft"

        assert.spy(on_installed).called(1)
        assert.spy(on_installed).called_with(tools.group1.tool1, bufnr)
      end)
    end)
  end)
end)
