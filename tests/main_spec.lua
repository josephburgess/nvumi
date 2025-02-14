local config = require("nvumi.config")
local main = require("nvumi.main")

describe("nvumi.main", function()
  before_each(function()
    vim.cmd("enew")
  end)

  it("reset_buffer should clear the buffer and extmarks", function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "one for the money", "two for the better green" })
    main._test.reset_buffer()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.are.same({ "" }, lines)
  end)

  it("run_numi_on_buffer should set extmarks based on simulated job output", function()
    ---@diagnostic disable: duplicate-set-field
    local original_jobstart = vim.fn.jobstart
    vim.fn.jobstart = function(_, opts)
      if opts and opts.on_stdout then
        opts.on_stdout(0, { "4" }, "4")
      end
      return 1
    end
    ---@diagnostic enable: duplicate-set-field

    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "2+2" })

    config.options.virtual_text = "inline"
    main._test.run_numi_on_buffer()

    vim.wait(100, function()
      local ns = vim.api.nvim_create_namespace("nvumi_inline")
      local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
      return #marks > 0
    end)

    local ns = vim.api.nvim_create_namespace("nvumi_inline")
    local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
    assert.is_true(#marks > 0)

    vim.fn.jobstart = original_jobstart
  end)
end)
