local assert = require("luassert")
local runner = require("nvumi.runner")

describe("nvumi.runner", function()
  it("run_numi should invoke the callback with simulated output", function()
    local old_jstart = vim.fn.jobstart
    local callback_called = false

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fn.jobstart = function(args, opts)
      if opts and opts.on_stdout then
        opts.on_stdout(0, { "runner result" }, "runner result")
        callback_called = true
      end
      return 1
    end

    runner.run_numi("dummy expression", function(data)
      callback_called = true
      assert.are.same({ "runner result" }, data)
    end)

    local success = vim.wait(500, function()
      return callback_called
    end, 10)
    assert.is_true(success, "callback not called")
    vim.fn.jobstart = old_jstart
  end)
end)
