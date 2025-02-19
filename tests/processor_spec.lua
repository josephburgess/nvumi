local assert = require("luassert")
local processor = require("nvumi.processor")
local runner = require("nvumi.runner")
local spy = require("luassert.spy")
local state = require("nvumi.state")

describe("nvumi.processor", function()
  local ctx, mock_run_numi, real_run

  before_each(function()
    ctx = { buf = 1, ns = 1, opts = { virtual_text = "newline", prefix = "= " } }
    state.clear_state()
    real_run = runner.run_numi
    mock_run_numi = spy.new(function(_, callback)
      callback({ "madvillainy" })
    end)
    runner.run_numi = mock_run_numi
  end)

  after_each(function()
    runner.run_numi = real_run
  end)

  it("should ignore empty lines and not call run_numi", function()
    local processed = false
    processor.process_line(ctx, "", 1, function()
      processed = true
    end)

    assert.is_true(processed)
    assert.spy(mock_run_numi).was_not_called()
  end)

  it("should ignore commented lines and not call run_numi", function()
    local processed = false
    processor.process_line(ctx, "-- this is a comment", 1, function()
      processed = true
    end)

    assert.is_true(processed)
    assert.spy(mock_run_numi).was_not_called()
  end)

  it("should process a valid expression and call run_numi", function()
    local output
    processor.process_line(ctx, "6 * 7", 1, function()
      output = state.get_last_output()
    end)

    assert.are.same("madvillainy", output)
    assert.spy(mock_run_numi).was_called(1)
  end)

  it("should recognize and process variable assignment", function()
    local output
    processor.process_line(ctx, "x = 50 * 2", 1, function()
      output = state.get_variable("x")
    end)

    assert.are.same("madvillainy", output)
    assert.spy(mock_run_numi).was_called(1)
  end)
end)
