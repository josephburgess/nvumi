local M = {}

---@type table<string, string>
M.variables = {} -- store for key/val pairs of variables

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

---@return nil
function M.clear_variables()
  M.variables = {}
end

return M
