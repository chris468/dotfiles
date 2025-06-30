local Linter = require("chris468-tools.linter")

describe("Linter", function()
  it("should have type linter", function()
    assert.are.equal("linter", Linter.type)
  end)
end)
