---@module "plenary.busted"
---
local Tool = require("chris468-tools.tool")
local mason_registry = require("mason-registry")

local TestTool = Tool:extend()
TestTool.type = "TestType"
function TestTool:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts)
end

local package_name = "tool1"

describe("tool", function()
  describe("name", function()
    it("should be package name when tool_name is unset", function()
      local t = TestTool:new(package_name)
      assert.are.equal(package_name, t:name())
    end)

    it("should be tool_name when different than package name", function()
      local expected_name = "different"
      local t = TestTool:new(package_name, { tool_name = expected_name })
      assert.are.equal(expected_name, t:name())
    end)
  end)

  describe("enabled", function()
    it("should be enabled when enabled is unset", function()
      local t = TestTool:new(package_name)
      assert.are.equal(true, t.enabled)
    end)
    it("should be enabled when enabled is true", function()
      local t = TestTool:new(package_name, { enabled = true })
      assert.are.equal(true, t.enabled)
    end)
    it("should be disabled when enabled is false", function()
      local t = TestTool:new(package_name, { enabled = false })
      assert.are.equal(false, t.enabled)
    end)
  end)

  describe("package", function()
    it("should return package", function()
      local expected_package = mason_registry.get_package(package_name)
      assert.is.truthy(expected_package)

      local t = TestTool:new(package_name)
      assert.are.equal(expected_package, t:package())
    end)

    it("should return false when set to false", function()
      local t = TestTool:new(package_name, { package = false })
      assert.are.equal(false, t:package())
    end)

    it("should return false if package does not exist", function()
      local t = TestTool:new("missing tool")
      assert.are.equal(false, t:package())
    end)

    it("should return package if tool name is different", function()
      local expected_package = mason_registry.get_package(package_name)
      assert.is.truthy(expected_package)

      local t = TestTool:new(package_name, { tool_name = "different" })
      assert.are.equal(expected_package, t:package())
    end)
  end)

  describe("filetypes", function()
    it("should return filetypes when set", function()
      local filetypes = { "f1", "f2" }
      local t = TestTool:new(package_name, { filetypes = filetypes })
      assert.are.same(filetypes, t:filetypes())
    end)

    it("should return empty when unset", function()
      local t = TestTool:new(package_name)
      assert.are.same({}, t:filetypes())
    end)
  end)

  describe("display name", function()
    it("should have type and name", function()
      local t = TestTool:new("test tool")
      assert.are.equal(TestTool.type .. " test tool", t:display_name())
    end)

    it("should have type, package name, and tool name", function()
      local tool_name = "different"

      local t = TestTool:new("test tool", { tool_name = tool_name })
      assert.are.equal(string.format("%s test tool (%s)", TestTool.type, tool_name), t:display_name())
    end)
  end)
end)
