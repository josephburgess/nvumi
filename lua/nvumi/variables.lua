local M = {}

M.variables = {}

function M.set_variable(name, value)
  M.variables[name] = value
end

function M.get_variable(name)
  return M.variables[name]
end

function M.substitute_variables(expr)
  return expr:gsub("(%a[%w_]*)", function(var)
    local value = M.get_variable(var)
    if value then
      return "(" .. value .. ")"
    else
      return var
    end
  end)
end

function M.clear_variables()
  M.variables = {}
end

return M
