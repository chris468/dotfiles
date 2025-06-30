local spy = require("luassert.spy")
local registry = require("tests.utils.lua_registry")
local Dap = require("chris468-tools.dap")

---@param t table
---@return table
local function readonly(t)
  return setmetatable(t, {
    __newindex = function() error("read-only table") end
  })
end

describe("Dap", function()
  local expected = readonly({
    dap_name = "dap_adapter",
    package_name = registry.names.dap.name,
    filetypes = readonly({ "mdapft1", "mdapft2" })

  })

  before_each(function()
    package.loaded["mason-nvim-dap.mappings.source"] = {
      package_to_nvim_dap = {
        [expected.package_name] = expected.dap_name
      }
    }
    package.loaded["mason-nvim-dap.mappings.filetypes"] = {
      [expected.dap_name] = expected.filetypes
    }
  end)

  after_each(function()
    package.loaded["mason-nvim-dap.sources"] = nil
    package.loaded["mason-nvim-dap.filetypes"] = nil
  end)

  it("should have type dap", function()
    assert.are.equal("DAP", Dap.type)
  end)

  describe("name", function()
    it("should return dap name", function()
      local t = Dap:new(expected.package_name, {})
      assert.equal(expected.dap_name, t:name())
    end)
  end)

  describe("filetypes", function()
    local dap_filetypes = readonly({ "dapft1", "dapft2" })
    it("should return filetypes from tool", function()
      local t = Dap:new(expected.package_name
      , { filetypes = dap_filetypes })
      assert.are.equal(dap_filetypes, t:filetypes())
    end)

    it("should return filetypes from mason-nvim-dap", function()
      local t = Dap:new(expected.package_name, {})
      assert.are.equal(expected.filetypes, t:filetypes())
    end)
  end)
end)
