local Formatter = require("chris468-tools.formatter")

describe("Formatter", function()
  it("should have type formatter", function()
    assert.are.equal("formatter", Formatter.type)
  end)
end)
