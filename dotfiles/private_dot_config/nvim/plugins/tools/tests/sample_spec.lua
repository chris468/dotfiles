describe("outer", function()
  local before = 0
  local after = 0
  before_each(function()
    before = before + 1
  end)
  after_each(function()
    after = after + 1
  end)

  it("first", function()
    assert.are.equal(1, before)
  end)

  it("second", function()
    assert.are.equal(1, after)
    assert.are.equal(2, before)
  end)

  describe("inner", function()
    it("third", function()
      assert.are.equal(2, after)
      assert.are.equal(3, before)
    end)

    it("fourth", function()
      assert.are.equal(3, after)
      assert.are.equal(4, before)
    end)
  end)
end)
