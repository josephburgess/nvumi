local converter = require("nvumi.converter")
local functions = require("nvumi.functions")
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

local M = {}

local function should_skip_line(line)
  return not line:match("%S") or line:match("^%s*%-%-")
end

---@param ctx table             context (e.g. buffer, line, etc)
---@param line string           line content
---@param index number          line number
---@param next_callback fun()   function to call when done
function M.process_line(ctx, line, index, next_callback)
  if should_skip_line(line) then
    return next_callback()
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  local prepared_line = state.substitute_variables(var and expr or line)

  local function assign_and_render(result)
    if var then
      state.set_variable(var, result)
    end
    renderer.render_result(ctx, index - 1, result, next_callback)
  end

  local result = converter.process_custom_conversion(prepared_line)
  if result then
    assign_and_render(result)
    return
  end

  result = functions.evaluate_function_call(prepared_line)
  if result then
    assign_and_render(result)
    return
  end

  runner.run_numi(prepared_line, function(data)
    local numi_result = data[1]
    assign_and_render(numi_result)
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
