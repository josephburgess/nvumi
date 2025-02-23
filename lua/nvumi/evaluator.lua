local config = require("nvumi.config")

local M = {}

--- @param str string
--- @return string
local function normalize(str)
  return str:match("^%s*(.-)%s*$"):lower()
end

--- @param fn_name string
--- @return function|nil
local function get_target_fn(fn_name)
  local custom_functions = config.options.custom_functions or {}

  for _, f in ipairs(custom_functions) do
    for phrase in (f.def and f.def.phrases or ""):gmatch("[^,]+") do
      if normalize(phrase) == normalize(fn_name) then
        return f.fn
      end
    end
  end
end

--- @param args_str string
--- @return table
local function parse_args(args_str)
  local args = {}
  for arg in (args_str or ""):gmatch("[^,]+") do
    local value = tonumber(normalize(arg)) or normalize(arg)
    table.insert(args, value)
  end
  return args
end

--- @param expression string
--- @return string|nil
function M.evaluate_function(expression)
  local fn_name, args_str = expression:match("^%s*(%a+)%s*%((.-)%)%s*$")
  local target_fn = fn_name and get_target_fn(fn_name)
  if not target_fn then
    return nil
  end

  local result = target_fn(parse_args(args_str))
  return result.error and "Error: " .. result.error or tostring(result.result)
end

return M
