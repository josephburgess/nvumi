local converter = require("nvumi.converter")
local functions = require("nvumi.functions")
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

local M = {}

---@param line string
---@return boolean
local function should_skip_line(line)
  return not line:match("%S") or line:match("^%s*%-%-")
end

---@param ctx table
---@param index number
---@param var string|nil
---@param result string
---@param next_callback fun()
local function assign_and_render(ctx, index, var, result, next_callback)
  if var then
    state.set_variable(var, result)
  end
  renderer.render_result(ctx, index - 1, result, next_callback)
end

---@param ctx table
---@param line string
---@param index number
---@param next_callback fun()
function M.process_line(ctx, line, index, next_callback)
  if should_skip_line(line) then
    return next_callback()
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  local prepared_line = state.substitute_variables(var and expr or line)

  local result = converter.process_custom_conversion(prepared_line)
  if result then
    return assign_and_render(ctx, index, var, result, next_callback)
  end

  result = functions.evaluate_function_call(prepared_line)
  if result then
    return assign_and_render(ctx, index, var, result, next_callback)
  end

  runner.run_numi(prepared_line, function(data)
    assign_and_render(ctx, index, var, data[1], next_callback)
  end)
end

---@param ctx table
---@param lines string[]
---@param index number
function M.process_lines(ctx, lines, index)
  if index > #lines then
    return
  end

  M.process_line(ctx, lines[index], index, function()
    M.process_lines(ctx, lines, index + 1)
  end)
end

return M
