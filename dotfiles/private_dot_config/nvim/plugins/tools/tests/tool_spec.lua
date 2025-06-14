---@module "plenary.busted"

local registry = { _packages = {} }
package.loaded["mason-registry"] = registry

function registry.get_package(name)
  if not registry._packages[name] then
    error("package " .. name .. " not found")
  end
  return registry._packages[name]
end

local tool = require("chris468-tools.tool")

---@class ToolSpec
local tool_specs = {
  Formatter = {
    display_type = "formatter",
    supports_custom_name = true,
    supports_custom_filetypes = true,
    ---@type fun(...) : Tool
    factory = function(...)
      return tool.Formatter:new(...)
    end,
  },
  Linter = {
    display_type = "linter",
    supports_custom_name = true,
    supports_custom_filetypes = true,
    ---@type fun(...) : Tool
    factory = function(...)
      return tool.Linter:new(...)
    end,
  },
  Lsp = {
    display_type = "LSP",
    supports_custom_name = false,
    supports_custom_filetypes = false,
    ---@type fun(...) : Tool
    factory = function(...)
      return tool.Lsp:new(...)
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

  all_tools(function(spec)
    describe("name", function()
      it("should be package name when tool_name is unset", function()
        local t = spec.factory("test tool")
        assert.are.equal("test tool", t:name())
      end)

      if spec.supports_custom_name then
        it("should be tool_name when specified", function()
          local t = spec.factory("test tool", { tool_name = "test tool name" })
          assert.are.equal("test tool name", t:name())
        end)
      end
    end)

    describe("enabled", function()
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

    describe("package", function()
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
          local t = spec.factory("test tool", { tool_name = "different" })
          assert.are.equal(test_tool, t:package())
        end)
      end
    end)

    if spec.supports_custom_name then
      describe("filetypes", function()
        it("should return filetypes when set", function()
          local filetypes = { "f1", "f2" }
          local t = spec.factory("test tool", { filetypes = filetypes })
          assert.are.equal(filetypes, t:filetypes())
        end)

        it("should return empty when unset", function()
          local t = spec.factory("test tool")
          assert.are.same({}, t:filetypes())
        end)
      end)
    end

    describe("display name", function()
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

  describe("Lsp", function()
    local config_filetypes = { "ft1", "ft2" }
    local lsp_filetypes = { "ft3", "ft4" }
    local lsp_config = { filetypes = config_filetypes }
    vim.lsp.config["test tool"] = { filetypes = lsp_filetypes }

    describe("name", function()
      it("should be lspconfig name when present", function()
        registry._packages.lsp = { spec = { name = "lsp", neovim = { lspconfig = "test tool" } } }
        local t = tool_specs.Lsp.factory("lsp", { lspconfig = {} })
        assert.is.truthy(t:package())
        assert.are.equal("test tool", t:name())
      end)
    end)

    describe("lspconfig", function()
      it("should return lspconfig", function()
        local t = tool.Lsp:new("test tool", { lspconfig = lsp_config })
        assert.are.equal(lsp_config, t.lspconfig)
      end)

      it("should return empty when unset", function()
        local t = tool.Lsp:new("test tool", {})
        assert.are.same({}, t.lspconfig)
      end)
    end)

    describe("filetypes", function()
      it("should take filetypes from tool", function()
        local t = tool.Lsp:new("test tool", { lspconfig = lsp_config })
        assert.are.equal(config_filetypes, t:filetypes())
      end)

      it("should take filetypes from lsp", function()
        local t = tool.Lsp:new("test tool", { lspconfig = {} })
        assert.are.equal(lsp_filetypes, t:filetypes())
      end)
    end)
  end)
end)
