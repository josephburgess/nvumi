local config = require("nvumi.config")
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

local M = {}

---@param ctx table             context
---@param line string           line content
---@param index number          line number
---@param next_callback fun()   next function to call when done
local function process_line(ctx, line, index, next_callback)
  --- if empty or comment, bail
  if not line:match("%S") or line:match("^%s*%-%-") then
    return next_callback()
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  local prepared_line = state.substitute_variables(var and expr or line)
  runner.run_numi(prepared_line, function(data)
    local result = data[1]

    if var then -- is a variable assignment
      state.set_variable(var, result)
    end

    renderer.render_result(ctx, index - 1, result, next_callback)
  end)
end

---@param ctx table         context
---@param lines string[]    lines from the buffer
---@param index number      line index
local function process_lines(ctx, lines, index)
  if index > #lines then
    return
  end
  process_line(ctx, lines[index], index, function()
    process_lines(ctx, lines, index + 1)
  end)
end

---@return nil
function M.run_on_buffer()
  local ctx = {
    buf = vim.api.nvim_get_current_buf(),
    ns = vim.api.nvim_create_namespace("nvumi_inline"),
    opts = config.options,
  }
  local lines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
  vim.api.nvim_buf_clear_namespace(ctx.buf, ctx.ns, 0, -1)
  process_lines(ctx, lines, 1)
end

---@return nil
function M.reset_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("nvumi_inline")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  state.clear_state()
end

return M
