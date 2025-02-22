local config = require("nvumi.config")
local processor = require("nvumi.processor")
local state = require("nvumi.state")
local ns = vim.api.nvim_create_namespace("nvumi_inline")

local M = {}

local function create_ctx()
  return {
    buf = vim.api.nvim_get_current_buf(),
    ns = ns,
    opts = config.options,
  }
end

function M.run_on_buffer()
  local ctx = create_ctx()
  local lines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
  processor.process_lines(ctx, lines, 1)
end

function M.run_on_line()
  local ctx = create_ctx()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  processor.process_line(ctx, line, row, function() end)
end

function M.reset_buffer()
  local ctx = create_ctx()
  vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, {})
  vim.api.nvim_buf_clear_namespace(ctx.buf, ctx.ns, 0, -1)
  state.clear_state()
end

return M
