local spy = require("luassert.spy")
local registry = require("tests.utils.lua_registry")
local Lsp = require("chris468-tools.lsp")

describe("Lsp", function()
  it("should have type lsp", function()
    assert.are.equal("LSP", Lsp.type)
  end)

  describe("name", function()
    it("should return lspconfig name from package", function()
      local spec = registry.names.lsp_with_name
      local expected_name = spec.tool_name

      local t = Lsp:new(spec.name, {})
      assert.are.equal(expected_name, t:name())
    end)
  end)

  describe("filetypes", function()
    local package_name = registry.names.lsp.name
    local lsp_filetypes = { "lspft1", "lspft2" }
    local lspconfig_filetypes = { "lspconfigft1", "lspconfigft2" }

    before_each(function()
      vim.lsp.config[package_name] = { filetypes = lsp_filetypes }
    end)
    after_each(function()
      vim.lsp.config[package_name] = {}
    end)

    it("should return filetypes from lsp", function()
      local t = Lsp:new(package_name, { lspconfig = { filetypes = lspconfig_filetypes } })
      assert.are.equal(lspconfig_filetypes, t:filetypes())
    end)

    it("should return filetypes from lspconfig", function()
      local t = Lsp:new(package_name, {})
      assert.are.equal(lsp_filetypes, t:filetypes())
    end)
  end)

  describe("lspconfig", function()
    local lsp_config = { filetypes = { "ft1", "ft2" } }
    local lsp_config_fn = function()
      return lsp_config
    end

    it("should return lspconfig", function()
      local t = Lsp:new("test tool", { lspconfig = lsp_config })
      assert.are.equal(lsp_config, t:lspconfig())
    end)

    it("should return empty when unset", function()
      local t = Lsp:new("test tool", {})
      assert.are.same({}, t:lspconfig())
    end)

    it("should call lspconfig when it is a function", function()
      local t = Lsp:new("test tool", { lspconfig = lsp_config_fn })
      assert.are.same(lsp_config, t:lspconfig())
    end)

    it("should call lspconfig exactly once when it is a function", function()
      local lspconfig_spy = spy.new(lsp_config_fn)
      local fn = function(...)
        return lspconfig_spy(...)
      end
      local t = Lsp:new("test tool", { lspconfig = fn })

      assert.are_same(lsp_config, t:lspconfig())
      assert.are_same(lsp_config, t:lspconfig())
      assert.spy(lspconfig_spy).was.called(1, t)
    end)
  end)
end)
