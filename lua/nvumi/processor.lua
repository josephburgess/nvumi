local api = vim.api
local config = require("nvumi.config").options
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local variables = require("nvumi.variables")

local M = {}

local function process_line(line, index, buf, config, next_callback)
  if not line:match("%S") or line:match("^%s*%-%-") then
    return next_callback() -- Ignore empty lines or comments.
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  if var and expr then
    local substituted_expr = variables.substitute_variables(expr)
    runner.run_numi(substituted_expr, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      local result = table.concat(data, " ")
      variables.set_variable(var, result)
      renderer.render_result(buf, index - 1, { result }, config, next_callback)
    end)
  else
    local substituted_line = variables.substitute_variables(line)
    runner.run_numi(substituted_line, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      renderer.render_result(buf, index - 1, data, config, next_callback)
    end)
  end
end

-- Recursively process all lines in the buffer.
local function process_lines(lines, buf, config, index)
  if index > #lines then
    return
  end
  process_line(lines[index], index, buf, config, function()
    process_lines(lines, buf, config, index + 1)
  end)
end

-- Run Numi on the entire buffer.
function M.run_on_buffer()
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local ns = api.nvim_create_namespace("nvumi_inline")
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  process_lines(lines, buf, config, 1)
end

-- Reset the buffer and clear variables.
function M.reset_buffer()
  local buf = api.nvim_get_current_buf()
  local ns = api.nvim_create_namespace("nvumi_inline")
  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  variables.clear_variables()
end

return M
