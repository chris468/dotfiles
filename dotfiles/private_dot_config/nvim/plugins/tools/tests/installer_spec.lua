---@module "plenary.busted"

local Tool = require("chris468-tools.tool")

local installer = require("chris468-tools.installer")

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

---@class TestTool : chris468.tools.Tool
local TestTool = Tool:extend("TestTool") --[[ @as TestTool]]
TestTool.type = "test"
function TestTool:__eq(other)
  return self:name() == other:name()
end
function TestTool:new(name, opts)
  return self:_new(name, opts)
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
end)
