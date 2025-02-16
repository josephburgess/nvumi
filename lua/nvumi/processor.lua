local api = vim.api
local config = require("nvumi.config").options
local renderer = require("nvumi.renderer")
local runner = require("nvumi.runner")
local state = require("nvumi.state")

local M = {}

---@param line string          line content
---@param index number         line number
---@param buf number           buffer number
---@param opts table           user config
---@param next_callback fun()  next function to call when done
local function process_line(line, index, buf, opts, next_callback)
  --- if empty or comment, bail
  if not line:match("%S") or line:match("^%s*%-%-") then
    return next_callback()
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  --- if line is a var assignment, populate existing variables in the exp, run numi, set the new variable,
  if var and expr then
    local substituted_expr = state.substitute_variables(expr)
    runner.run_numi(substituted_expr, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      local result = table.concat(data, " ")
      state.set_variable(var, result)
      renderer.render_result(buf, index - 1, { result }, opts, next_callback)
    end)
  --- else just substitute any var values, evaluate the expression and render answer
  else
    local substituted_line = state.substitute_variables(line)
    runner.run_numi(substituted_line, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      renderer.render_result(buf, index - 1, data, opts, next_callback)
    end)
  end
end

---@param lines string[]   lines from the buffer
---@param buf number       buffer number
---@param opts table       user config
---@param index number     line index
local function process_lines(lines, buf, opts, index)
  if index > #lines then
    return
  end
  process_line(lines[index], index, buf, opts, function()
    process_lines(lines, buf, opts, index + 1)
  end)
end

---@return nil
function M.run_on_buffer()
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local ns = api.nvim_create_namespace("nvumi_inline")
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  process_lines(lines, buf, config, 1)
end

---@return nil
function M.reset_buffer()
  local buf = api.nvim_get_current_buf()
  local ns = api.nvim_create_namespace("nvumi_inline")
  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  state.clear_state()
end

return M
