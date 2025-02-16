local assert = require("luassert")
local api = vim.api
local renderer = require("nvumi.renderer")

describe("nvumi.renderer", function()
  local test_buf

  before_each(function()
    test_buf = api.nvim_create_buf(false, true)
  end)

  after_each(function()
    if api.nvim_buf_is_valid(test_buf) then
      api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  it("render_inline should add an extmark with virtual text", function()
    renderer.render_inline(test_buf, 0, "inline test")
    local ns = api.nvim_create_namespace("nvumi_inline")
    local marks = api.nvim_buf_get_extmarks(test_buf, ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)

  it("render_newline should add an extmark with virt_lines", function()
    renderer.render_newline(test_buf, 0, "newline test")
    local ns = api.nvim_create_namespace("nvumi_inline")
    local marks = api.nvim_buf_get_extmarks(test_buf, ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)
end)
