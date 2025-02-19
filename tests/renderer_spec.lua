local assert = require("luassert")
local renderer = require("nvumi.renderer")
local spy = require("luassert.spy")
local state = require("nvumi.state")
local stub = require("luassert.stub")

describe("nvumi.renderer", function()
  local ctx, store_output, get_output, clear_ns_spy
  local real_api

  before_each(function()
    real_api = vim.api

    ctx = {
      buf = vim.api.nvim_create_buf(false, true),
      ns = vim.api.nvim_create_namespace("nvumi_inline"),
      opts = { prefix = "!!", virtual_text = "newline" },
    }

    vim.api.nvim_buf_set_lines(
      ctx.buf,
      0,
      -1,
      false,
      { "one for the money", "two for the better green", "3,4-methylenedioxymethamphetamine" }
    )

    store_output = stub(state, "store_output")
    get_output = stub(state, "get_output")
    clear_ns_spy = spy.on(vim.api, "nvim_buf_clear_namespace")
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(ctx.buf) then
      vim.api.nvim_buf_delete(ctx.buf, { force = true })
    end

    vim.api = real_api
    store_output:revert()
    get_output:revert()
    clear_ns_spy:revert()
  end)

  it("renders inline text with an extmark", function()
    renderer.render_inline(ctx, 0, "inline test")
    local marks = vim.api.nvim_buf_get_extmarks(ctx.buf, ctx.ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)

  it("renders newline text with an extmark", function()
    renderer.render_newline(ctx, 0, "newline test")
    local marks = vim.api.nvim_buf_get_extmarks(ctx.buf, ctx.ns, 0, -1, {})
    assert.is_true(#marks > 0)
  end)

  it("stores and renders if new result", function()
    get_output.returns(nil)
    renderer.render_result(ctx, 1, "result", function() end)
    assert.spy(clear_ns_spy).was_called(1)
    assert.stub(store_output).was_called_with(1, "result")
  end)

  it("not rerender if unchanged result", function()
    get_output.returns("mmmmcookies")

    local rdr_inln = spy.on(renderer, "render_inline")
    local rdr_newln = spy.on(renderer, "render_newline")

    renderer.render_result(ctx, 1, "mmmmcookies", function() end)
    assert.spy(rdr_inln).was_not_called()
    assert.spy(rdr_newln).was_not_called()
    rdr_inln:revert()
    rdr_newln:revert()
  end)

  it("renders inline if set", function()
    ctx.opts.virtual_text = "inline"
    get_output.returns(nil)
    local render_inline_spy = spy.on(renderer, "render_inline")
    renderer.render_result(ctx, 2, "catch a throatful", function() end)

    assert.spy(render_inline_spy).was_called(1)

    render_inline_spy:revert()
  end)

  it("renders newline if set", function()
    ctx.opts.virtual_text = "newline"
    get_output.returns(nil)

    local render_newline_spy = spy.on(renderer, "render_newline")

    renderer.render_result(ctx, 2, "fire vocals", function() end)
    assert.spy(render_newline_spy).was_called(1)
    render_newline_spy:revert()
  end)
end)
