local assert = require("luassert")
local runner = require("nvumi.runner")
local spy = require("luassert.spy")

describe("nvumi.runner", function()
  it("should notify error when numi-cli is not installed", function()
    local notify_spy = spy.on(vim, "notify")
    local old_executable = vim.fn.executable
    vim.fn.executable = function()
      return 0
    end
    runner.run_numi("10 + 10", function() end)
    assert
      .spy(notify_spy)
      .was_called_with("Error: `numi-cli` is not installed or not in PATH.\nType `:help Nvumi` for more.", vim.log.levels.ERROR)
    vim.fn.executable = old_executable
  end)
end)

it("run_numi should invoke the callback with simulated output", function()
  local old_jstart = vim.fn.jobstart
  local callback_called = false

  vim.fn.jobstart = function(_, opts)
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
