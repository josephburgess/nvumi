local M = {}

M.variables = {}

function M.set_variable(name, value)
  M.variables[name] = value
end

function M.get_variable(name)
  return M.variables[name]
end

function M.substitute_variables(expression)
  for var, value in pairs(M.variables) do
    expression = expression:gsub("%f[%a]" .. var .. "%f[%A]", value)
  end
  return expression
end

-- function M.list_variables()
--   local output = {}
--   for k, v in pairs(M.variables) do
--     table.insert(output, k .. " = " .. v)
--   end
--   print(table.concat(output, "\n"))
-- end
--
-- function M.clear_variables()
--   M.variables = {}
--   print("Nvumi: Cleared all stored variables.")
-- end

return M
