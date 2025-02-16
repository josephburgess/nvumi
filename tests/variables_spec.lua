local assert = require("luassert")
local variables = require("nvumi.variables")

describe("nvumi.variables", function()
  before_each(function()
    variables.clear_variables()
  end)

  it("should set and get a variable", function()
    variables.set_variable("a", "42")
    assert.are.same("42", variables.get_variable("a"))
  end)

  it("substitute_variables should replace variable names with their values", function()
    variables.set_variable("var", "100")
    local result = variables.substitute_variables("2*var+1")
    -- Expected: "2*(100)+1"
    assert.are.same("2*(100)+1", result)
  end)

  it("clear_variables should remove all variables", function()
    variables.set_variable("temp", "xyz")
    variables.clear_variables()
    assert.is_nil(variables.get_variable("temp"))
  end)
end)
