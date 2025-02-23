local assert = require("luassert")
local config = require("nvumi.config")
local evaluator = require("nvumi.evaluator")

describe("nvumi.evaluator", function()
  before_each(function()
    config.options.custom_functions = {
      {
        def = { phrases = "add" },
        fn = function(args)
          return { result = args[1] + args[2] }
        end,
      },
      {
        def = { phrases = "square, sqr" },
        fn = function(args)
          if type(args[1]) ~= "number" then return { error = "should be a num bro!" } end
          return { result = args[1] * args[1] }
        end,
      },
    }
  end)

  it("evaluates fn call", function()
    local result = evaluator.evaluate_function("square(4)")
    assert.are.same("16", result)
  end)

  it("evaluates a func call with multiple arguments", function()
    local result = evaluator.evaluate_function("add(3, 7)")
    assert.are.same("10", result)
  end)

  it("returns nil for unknown function names", function()
    local result = evaluator.evaluate_function("madvillainy(4)")
    assert.is_nil(result)
  end)

  it("returns error msgs", function()
    local result = evaluator.evaluate_function("square(abc)")
    assert.are.same("Error: should be a num bro!", result)
  end)

  it("fn names are not case-sensitive", function()
    local result = evaluator.evaluate_function("SQR(5)")
    assert.are.same("25", result)
  end)

  it("ignores extra spaces", function()
    local result = evaluator.evaluate_function("  square (   6   )  ")
    assert.are.same("36", result)
  end)

  it("return nil for bad input", function()
    assert.is_nil(evaluator.evaluate_function("square"))
  end)

  it("return nil for an unregistered function", function()
    local result = evaluator.evaluate_function("czarface(3)")
    assert.is_nil(result)
  end)

  it("return nil without parens", function()
    local result = evaluator.evaluate_function("someFunc")
    assert.is_nil(result)
  end)
end)
