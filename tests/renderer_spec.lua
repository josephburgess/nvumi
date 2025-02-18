local assert = require("luassert")
local api = vim.api
local renderer = require("nvumi.renderer")

describe("nvumi.renderer", function()
  local ctx

  before_each(function()
    ctx = {
      buf = api.nvim_create_buf(false, true),
      ns = api.nvim_create_namespace("nvumi_inline"),
      opts = { prefix = "!!" },
    }
  end)

  after_each(function()
    if api.nvim_buf_is_valid(ctx.buf) then
      api.nvim_buf_delete(ctx.buf, { force = true })
    end
  end)

  it("render_inline should add an extmark with virtual text", function()
    renderer.render_inline(ctx, 0, "inline test")
    local marks = api.nvim_buf_get_extmarks(ctx.buf, ctx.ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)

  it("render_newline should add an extmark with virt_lines", function()
    renderer.render_newline(ctx, 0, "newline test")
    local marks = api.nvim_buf_get_extmarks(ctx.buf, ctx.ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)
end)
