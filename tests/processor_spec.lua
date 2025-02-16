local api = vim.api
local assert = require("luassert")
local config = require("nvumi.config")
local processor = require("nvumi.processor")
local runner = require("nvumi.runner")
local variables = require("nvumi.variables")

describe("nvumi.processor", function()
  local old_run_numi
  local test_buf

  before_each(function()
    variables.clear_variables()
    config.setup()
    test_buf = api.nvim_create_buf(false, true)
    api.nvim_set_current_buf(test_buf)

    old_run_numi = runner.run_numi

    runner.run_numi = function(expr, callback)
      local mocked_results = {
        ["2+2"] = { "4" },
        ["3+3"] = { "6" },
        ["x+1"] = { "(6)+1" },
        ["6"] = { "6" },
        ["10"] = { "10" },
      }
      callback(mocked_results[expr] or { "ERROR" })
    end
  end)

  after_each(function()
    runner.run_numi = old_run_numi
    if api.nvim_buf_is_valid(test_buf) then
      api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  it("recognizes expressions and sets extmarks", function()
    api.nvim_buf_set_lines(test_buf, 0, -1, false, { "2+2", "x = 3+3" })
    processor.run_on_buffer()

    local ns = api.nvim_create_namespace("nvumi_inline")
    local marks = api.nvim_buf_get_extmarks(test_buf, ns, 0, -1, {})

    assert.is_true(#marks > 0)
    assert.are.same("6", variables.get_variable("x"))
  end)

  it("recognizes variable substitution in expressions", function()
    api.nvim_buf_set_lines(test_buf, 0, -1, false, { "x = 6", "x+1" })
    processor.run_on_buffer()
    assert.are.same("6", variables.get_variable("x"))
    assert.are.same("(6)+1", variables.substitute_variables("x+1"))
  end)

  it("reset_buffer should clear the buffer and variables", function()
    api.nvim_buf_set_lines(test_buf, 0, -1, false, { "dummy line" })
    processor.reset_buffer()
    local lines = api.nvim_buf_get_lines(test_buf, 0, -1, false)
    assert.are.same({ "" }, lines)
    assert.are.same({}, variables.variables)
  end)
end)
