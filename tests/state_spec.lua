local assert = require("luassert")
local state = require("nvumi.state")

describe("nvumi.state", function()
  before_each(function()
    state.clear_state()
  end)

  it("should set and get a variable", function()
    state.set_variable("a", "42")
    assert.are.same("42", state.get_variable("a"))
  end)

  it("substitute_variables should replace variable names with their values", function()
    state.set_variable("var", "100")
    local result = state.substitute_variables("2*var+1")
    assert.are.same("2*(100)+1", result)
  end)

  it("clear_state should remove all state", function()
    state.set_variable("temp", "xyz")
    state.clear_state()
    assert.is_nil(state.get_variable("temp"))
  end)

  describe("state - output and yanking", function()
    local original_notify

    before_each(function()
      original_notify = vim.notify
      vim.notify = function(msg, level)
        _G._TEST_YANK_NOTIFY_MESSAGE = msg
        _G._TEST_YANK_NOTIFY_LEVEL = level
      end
    end)

    after_each(function()
      vim.notify = original_notify
      _G._TEST_YANK_NOTIFY_MESSAGE = nil
      _G._TEST_YANK_NOTIFY_LEVEL = nil
    end)

    it("store update and give last output", function()
      state.store_output(1, "Answer")
      assert.are.same("Answer", state.get_last_output())
      assert.are.same("Answer", state.outputs[1])
    end)

    it("yanks last output to clipboard", function()
      state.store_output(2, "Result")
      state.yank_last_output()

      local clipboard = vim.fn.getreg("+")
      assert.are.same("Result", clipboard)

      assert.are.same("Yanked: Result", _G._TEST_YANK_NOTIFY_MESSAGE)
      assert.are.same(vim.log.levels.INFO, _G._TEST_YANK_NOTIFY_LEVEL)
    end)

    it("notify error when nothing to yank", function()
      state.clear_state()
      state.yank_last_output()

      assert.are.same("No output available to yank", _G._TEST_YANK_NOTIFY_MESSAGE)
      assert.are.same(vim.log.levels.ERROR, _G._TEST_YANK_NOTIFY_LEVEL)
    end)
  end)
end)
