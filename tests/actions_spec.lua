local actions = require("nvumi.actions")
local assert = require("luassert")
local processor = require("nvumi.processor")
local spy = require("luassert.spy")
local state = require("nvumi.state")

describe("nvumi.actions", function()
  local process_lines_spy, process_line_spy, clear_state_spy
  local real_fns, real_vim_api

  before_each(function()
    real_vim_api = vim.api
    vim.api = {
      nvim_get_current_buf = function()
        return 1
      end,
      nvim_buf_get_lines = function()
        return { "test line" }
      end,
      nvim_buf_clear_namespace = function() end,
      nvim_win_get_cursor = function()
        return { 1, 0 }
      end,
      nvim_get_current_line = function()
        return "single line"
      end,
      nvim_buf_set_lines = function() end,
      nvim_err_writeln = function() end,
    }

    real_fns = {
      process_lines = processor.process_lines,
      process_line = processor.process_line,
      clear_state = state.clear_state,
    }

    process_lines_spy = spy.on(processor, "process_lines")
    process_line_spy = spy.on(processor, "process_line")
    clear_state_spy = spy.on(state, "clear_state")
  end)

  after_each(function()
    for name, fn in pairs(real_fns) do
      processor[name] = fn
    end
    vim.api = real_vim_api
  end)

  it("calls process_lines on buffer run", function()
    actions.run_on_buffer()
    assert.spy(process_lines_spy).was_called(1)
  end)

  it("calls process_line on single line run", function()
    actions.run_on_line()
    assert.spy(process_line_spy).was_called(1)
  end)

  it("clears state on buffer reset", function()
    actions.reset_buffer()
    assert.spy(clear_state_spy).was_called(1)
  end)
end)
