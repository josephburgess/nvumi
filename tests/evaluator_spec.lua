local assert = require("luassert")
local config = require("nvumi.config")
local evaluator = require("nvumi.evaluator")

describe("nvumi.evaluator", function()
  before_each(function()
    config.options.custom_functions = {
      {
        def = { phrases = "square, sqr" },
        fn = function(args)
          return { double = args[1].double * args[1].double }
        end,
      },
      {
        def = { phrases = "add" },
        fn = function(args)
          return { double = args[1].double + args[2].double }
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

  it("return nil for bad args", function()
    local result = evaluator.evaluate_function("square(abc)")
    assert.is_nil(result)
  end)

  it("fn names are not case sensitvie", function()
    local result = evaluator.evaluate_function("SQR(5)")
    assert.are.same("25", result)
  end)

  it("ignores extra spaces", function()
    local result = evaluator.evaluate_function("  square (   6   )  ")
    assert.are.same("36", result)
  end)

  it("return nil for bad input", function()
    assert.is_nil(evaluator.evaluate_function("square"))
    assert.is_nil(evaluator.evaluate_function("square()"))
    assert.is_nil(evaluator.evaluate_function("square(,)"))
  end)
end)
