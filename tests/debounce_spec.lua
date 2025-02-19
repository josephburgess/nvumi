local assert = require("luassert")
local debounce = require("nvumi.debounce")
local spy = require("luassert.spy")

describe("nvumi.debounce", function()
  it("debounces when called many times in succession", function()
    local callback_spy = spy.new(function() end)
    local debounced_fn = debounce.debounce(50, callback_spy)

    debounced_fn()
    debounced_fn()
    debounced_fn()

    local done = false
    vim.defer_fn(function()
      done = true
    end, 100)

    vim.wait(200, function()
      return done
    end, 10)

    assert.spy(callback_spy).was_called(1)
  end)
end)
