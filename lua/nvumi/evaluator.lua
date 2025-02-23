local config = require("nvumi.config")

local M = {}

--- @param fn_name string
--- @return function|nil
local function get_target_fn(fn_name)
  local custom_functions = config.options.custom_functions or {}

  for _, f in ipairs(custom_functions) do
    local phrases = f.def and f.def.phrases or ""
    for phrase in phrases:gmatch("[^,]+") do
      if phrase:match("^%s*(.-)%s*$"):lower() == fn_name:lower() then
        return f.fn
      end
    end
  end

  return nil
end

--- @param args_str string
--- @return table|nil
local function parse_args(args_str)
  if not args_str or args_str:match("^%s*$") then
    return {}
  end

  local args = {}

  for arg in args_str:gmatch("[^,]+") do
    local num = tonumber(arg:match("^%s*(.-)%s*$"))
    if num then
      table.insert(args, num)
    else
      table.insert(args, arg)
    end
  end

  return args
end

--- @param expression string
--- @return string|nil
function M.evaluate_function(expression)
  local fn_name, args_str = expression:match("^%s*(%a+)%s*%((.-)%)%s*$")
  if not fn_name then
    return nil
  end

  local target_fn = get_target_fn(fn_name)
  if not target_fn then
    return nil
  end

  local args = parse_args(args_str)

  if args == nil then
    return nil
  end

  local result = target_fn(args)

  if result.error then
    return "Error: " .. result.error
  elseif result.result then
    return tostring(result.result)
  end
end

return M
