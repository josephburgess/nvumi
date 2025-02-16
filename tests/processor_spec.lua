local api = vim.api
local assert = require("luassert")
local config = require("nvumi.config")
local processor = require("nvumi.processor")
local variables = require("nvumi.variables")

describe("nvumi.processor", function()
  local old_jstart
  local test_buf

  before_each(function()
    variables.clear_variables()
    config.setup({ virtual_text = "inline", keys = { run = "<CR>", reset = "R" } })
    test_buf = api.nvim_create_buf(false, true)
    api.nvim_set_current_buf(test_buf)
    old_jstart = vim.fn.jobstart

    vim.fn.jobstart = function(args, opts)
      if args[2] then
        if args[2] == "3+3" then
          opts.on_stdout(0, { "6" }, "6")
        end
      else
        opts.on_stdout(0, { "4" }, "4")
      end
      return 1
    end
  end)

  after_each(function()
    vim.fn.jobstart = old_jstart
    if api.nvim_buf_is_valid(test_buf) then
      api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  it("run_on_buffer should process expressions and render extmarks", function()
    api.nvim_buf_set_lines(test_buf, 0, -1, false, { "2+2", "x = 3+3" })

    processor.run_on_buffer()

    vim.wait(100, function()
      local ns = api.nvim_create_namespace("nvumi_inline")
      local marks = api.nvim_buf_get_extmarks(test_buf, ns, 0, -1, {})
      return #marks > 0
    end)

    local ns = api.nvim_create_namespace("nvumi_inline")
    local marks = api.nvim_buf_get_extmarks(test_buf, ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)

  it("reset_buffer should clear the buffer and variables", function()
    api.nvim_buf_set_lines(test_buf, 0, -1, false, { "dummy line" })
    processor.reset_buffer()
    local lines = api.nvim_buf_get_lines(test_buf, 0, -1, false)
    assert.are.same({ "" }, lines)
    assert.are.same({}, variables.variables)
  end)
end)
