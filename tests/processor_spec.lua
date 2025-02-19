local assert = require("luassert")
local processor = require("nvumi.processor")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

describe("nvumi.processor", function()
  local ctx

  before_each(function()
    ctx = { buf = 1, ns = 1, opts = { virtual_text = "newline", prefix = "= " } }
    state.clear_state()
  end)

  it("should ignore empty lines", function()
    local processed = false
    processor.process_line(ctx, "", 1, function()
      processed = true
    end)
    assert.is_true(processed)
  end)

  it("should ignore commented lines", function()
    local processed = false
    processor.process_line(ctx, "-- this is a comment", 1, function()
      processed = true
    end)
    assert.is_true(processed)
  end)

  it("should process a valid expression", function()
    local output
    runner.run_numi = function(_, callback)
      callback({ "42" })
    end
    processor.process_line(ctx, "6 * 7", 1, function()
      output = state.get_last_output()
    end)
    assert.are.same("42", output)
  end)

  it("should recognize a variable assignment", function()
    local output
    runner.run_numi = function(_, callback)
      callback({ "100" })
    end
    processor.process_line(ctx, "x = 50 * 2", 1, function()
      output = state.get_variable("x")
    end)
    assert.are.same("100", output)
  end)

  it("should substitute variables correctly", function()
    state.set_variable("y", "10")
    runner.run_numi = function(_, callback)
      callback({ "50" })
    end
    processor.process_line(ctx, "x = y * 5", 1, function() end)
    assert.are.same("50", state.get_variable("x"))
  end)

  it("should process multiple lines", function()
    runner.run_numi = function(_, callback)
      callback({ "10" })
    end
    local lines = { "a = 5 + 5", "b = a * 2" }

    processor.process_lines(ctx, lines, 1)
    assert.are.same("10", state.get_variable("a"))

    runner.run_numi = function(_, callback)
      callback({ "20" })
    end
    processor.process_lines(ctx, lines, 2)
    assert.are.same("20", state.get_variable("b"))
  end)
end)
