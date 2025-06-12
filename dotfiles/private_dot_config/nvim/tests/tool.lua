---@module "plenary.test"

local registry = { _packages = {} }
package.loaded["mason-registry"] = registry

function registry.get_package(name)
  if not registry._packages[name] then
    error("package " .. name .. " not found")
  end
  return registry._packages[name]
end

local tool = require("chris468.plugins.config.tools.tool")

---@class ToolSpec
local tool_specs = {
  Tool = {
    display_type = "test_type",
    supports_custom_name = true,
    ---@type fun(...) : AbstractTool
    factory = function(...)
      return tool.Tool:new("test_type", ...)
    end,
  },
  LspTool = {
    display_type = "LSP",
    supports_custom_name = false,
    ---@type fun(...) : AbstractTool
    factory = function(...)
      return tool.LspTool:new(...)
    end,
  },
}

---@param func fun(ToolSpec)
local function all_tools(func)
  for name, spec in pairs(tool_specs) do
    describe(name, function()
      func(spec)
    end)
  end
end

local test_tool = { spec = { name = "test_tool" } }

describe("tool", function()
  before_each(function()
    registry._packages = { ["test tool"] = test_tool }
  end)

  describe("name", function()
    all_tools(function(spec)
      it("should be name when tool_name is unset", function()
        local t = spec.factory("test tool")
        assert.are.equal("test tool", t:name())
      end)

      if spec.supports_custom_name then
        it("should be tool_name when specified", function()
          local t = tool.Tool:new("test type", "test tool", { tool_name = "test tool name" })
          assert.are.equal("test tool name", t:name())
        end)
      end
    end)

    describe("enabled", function()
      all_tools(function(spec)
        it("should be enabled when enabled is unset", function()
          local t = spec.factory("test tool")
          assert.are.equal(true, t.enabled)
        end)
        it("should be enabled when enabled is true", function()
          local t = spec.factory("test tool", { enabled = true })
          assert.are.equal(true, t.enabled)
        end)
        it("should be disabled when enabled is false", function()
          local t = spec.factory("test tool", { enabled = false })
          assert.are.equal(false, t.enabled)
        end)
      end)
    end)

    describe("package", function()
      all_tools(function(spec)
        it("should return package", function()
          local t = spec.factory("test tool")
          assert.are.equal(test_tool, t:package())
        end)

        it("should return false when set to false", function()
          local t = spec.factory("test tool", { package = false })
          assert.are.equal(false, t:package())
        end)

        it("should return false if package does not exist", function()
          local t = spec.factory("missing tool")
          assert.are.equal(false, t:package())
        end)

        if spec.supports_custom_name then
          it("should return package if tool name is different", function()
            local t = tool.Tool:new("test type", "missing tool", { tool_name = "different" })
            assert.are.equal(false, t:package())
          end)
        end
      end)
    end)

    describe("display name", function()
      all_tools(function(spec)
        it("should have type and name", function()
          local t = spec.factory("test tool")
          assert.are.equal(spec.display_type .. " test tool", t:display_name())
        end)

        if spec.supports_custom_name then
          it("should have type, package name, and tool name", function()
            local t = spec.factory("test tool", { tool_name = "different" })
            assert.are.equal(spec.display_type .. " test tool (different)", t:display_name())
          end)
        end
      end)
    end)
  end)
end)
