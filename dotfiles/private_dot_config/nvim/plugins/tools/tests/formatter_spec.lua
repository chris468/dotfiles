local FakeRegistry = require("tests.utils.fake_registry")

local Formatter = require("chris468-tools.formatter")

describe("Formatter", function()
  local registry = FakeRegistry()

  before_each(function()
    registry:register()
  end)

  after_each(function()
    registry:unregister()
  end)

  it("should have type formatter", function()
    assert.are.equal("formatter", Formatter.type)
  end)
end)
