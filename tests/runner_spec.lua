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
      end
      return 1
    end

    runner.run_numi("dummy expression", function(data)
      callback_called = true
      assert.are.same({ "runner result" }, data)
    end)

    vim.wait(50, function()
      return callback_called
    end)
    vim.fn.jobstart = old_jstart
  end)
end)
