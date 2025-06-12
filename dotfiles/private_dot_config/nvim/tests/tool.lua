local registry = {}

function registry.get_package(name)
  return {}
end

package.loaded["mason-registry"] = registry

local tool = require("chris468.plugins.config.tools.tool")

describe("tool", function()
  describe("generic tool", function()
    describe("name", function()
      it("should be name when tool_name is unset", function()
        local t = tool.Tool:new("formatter", "form")
        assert.are.equal("form", t:name())
      end)
      it("should be tool_name when specified", function()
        local t = tool.Tool:new("formatter", "form", { tool_name = "tool_name" })
        assert.are.equal("tool_name", t:name())
      end)
    end)

    describe("enabled", function()
      it("should be enabled when enabled is unset", function()
        local t = tool.Tool:new("formatter", "form")
        assert.are.equal(true, t.enabled)
      end)
      it("should be enabled when enabled is true", function()
        local t = tool.Tool:new("formatter", "form", { enabled = true })
        assert.are.equal(true, t.enabled)
      end)
      it("should be disabled when enabled is false", function()
        local t = tool.Tool:new("formatter", "form", { enabled = false })
        assert.are.equal(false, t.enabled)
      end)
    end)
  end)
end)
