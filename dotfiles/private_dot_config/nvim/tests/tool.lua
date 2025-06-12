local registry = {}

function registry.get_package(name)
  return {}
end

package.loaded["mason-registry"] = registry

local tool = require("chris468.plugins.config.tools.tool")

local tool_factories = {
  Tool = function(...)
    return tool.Tool:new("test_type", ...)
  end,
  LspTool = function(...)
    return tool.LspTool:new(...)
  end,
}

---@param func fun(factory: fun(...): AbstractTool))
local function all_tools(func)
  for name, factory in pairs(tool_factories) do
    describe(name, function()
      func(factory)
    end)
  end
end

describe("tool", function()
  describe("name", function()
    all_tools(function(factory)
      it("should be name when tool_name is unset", function()
        local t = factory("test tool")
        assert.are.equal("test tool", t:name())
      end)
    end)

    describe("Tool", function()
      it("should be tool_name when specified", function()
        local t = tool.Tool:new("test type", "test tool", { tool_name = "test tool name" })
        assert.are.equal("test tool name", t:name())
      end)
    end)

    all_tools(function(factory)
      describe("enabled", function()
        it("should be enabled when enabled is unset", function()
          local t = factory("test tool")
          assert.are.equal(true, t.enabled)
        end)
        it("should be enabled when enabled is true", function()
          local t = factory("test tool", { enabled = true })
          assert.are.equal(true, t.enabled)
        end)
        it("should be disabled when enabled is false", function()
          local t = factory("test tool", { enabled = false })
          assert.are.equal(false, t.enabled)
        end)
      end)
    end)
  end)
end)
