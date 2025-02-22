local M = {}

---@type table<string, string>
M.variables = {} -- store for key/val pairs of variables

---@type table<string, string>
M.outputs = {} -- store for key/val pairs of answers

---@param name string
---@param value string
function M.set_variable(name, value)
  M.variables[name] = value
end

---@param name string
---@return string|nil
function M.get_variable(name)
  return M.variables[name]
end

---@param expr string
---@return string
function M.substitute_variables(expr)
  local result = expr:gsub("(%a[%w_]*)", function(var)
    local value = M.get_variable(var)
    return value and "(" .. value .. ")" or var
  end)
  return result
end

--- OUTPUTS ---

function M.store_output(line_index, output)
  M.outputs[line_index] = output
  M.last_output = output
end

function M.get_last_output()
  return M.last_output
end

function M.get_output(line_index)
  return M.outputs[line_index]
end

function M.clear_state()
  M.variables = {}
  M.outputs = {}
  M.last_output = nil
end

function M.yank_last_output()
  local last = M.get_last_output()
  if last then
    vim.fn.setreg("+", last)
    vim.notify(("Yanked: %s"):format(last), vim.log.levels.INFO)
  else
    vim.notify("No output available to yank", vim.log.levels.ERROR)
  end
end

function M.yank_all_outputs()
  local outputs = vim.tbl_values(M.outputs)
  if #outputs > 0 then
    local result = table.concat(outputs, "\n")
    vim.fn.setreg("+", result)
    vim.notify("Yanked all evaluations", vim.log.levels.INFO)
  else
    vim.notify("No outputs available to yank", vim.log.levels.ERROR)
  end
end

function M.yank_output_on_line()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local output = M.outputs[row - 1]
  if output then
    vim.fn.setreg("+", output)
    vim.notify(("Yanked: %s"):format(output), vim.log.levels.INFO)
  else
    vim.notify("No evaluation found on this line", vim.log.levels.ERROR)
  end
end

return M
