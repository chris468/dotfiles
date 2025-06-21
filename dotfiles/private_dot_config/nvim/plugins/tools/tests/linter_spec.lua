local FakeRegistry = require("tests.utils.fake_registry")

local Linter = require("chris468-tools.linter")

describe("Linter", function()
  local registry = FakeRegistry()

  before_each(function()
    registry:register()
  end)

  after_each(function()
    registry:unregister()
  end)

  it("should have type linter", function()
    assert.are.equal("linter", Linter.type)
  end)
end)
