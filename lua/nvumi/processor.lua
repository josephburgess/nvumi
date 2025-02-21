local converter = require("nvumi.converter")
local functions = require("nvumi.functions")
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

local M = {}

---@param ctx table             context
---@param line string           line content
---@param index number          line number
---@param next_callback fun()   function to call when done
function M.process_line(ctx, line, index, next_callback)
  --- if empty or comment, bail
  if not line:match("%S") or line:match("^%s*%-%-") then
    return next_callback()
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  local prepared_line = state.substitute_variables(var and expr or line)

  local custom_result = converter.process_custom_conversion(prepared_line)
  if custom_result then
    if var then
      state.set_variable(var, custom_result)
    end
    renderer.render_result(ctx, index - 1, custom_result, next_callback)
    return
  end

  local custom_fn_result = functions.evaluate_function_call(prepared_line)
  if custom_fn_result then
    local result = tostring(custom_fn_result.double)
    if var then
      state.set_variable(var, result)
    end
    renderer.render_result(ctx, index - 1, result, next_callback)
    return
  end

  runner.run_numi(prepared_line, function(data)
    local result = data[1]
    if var then -- variable assignment
      state.set_variable(var, result)
    end
    renderer.render_result(ctx, index - 1, result, next_callback)
  end)
end

---@param ctx table         context
---@param lines string[]    lines from the buffer
---@param index number      line index
function M.process_lines(ctx, lines, index)
  if index > #lines then
    return
  end
  M.process_line(ctx, lines[index], index, function()
    M.process_lines(ctx, lines, index + 1)
  end)
end

return M
