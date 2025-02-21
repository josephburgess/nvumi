local config = require("nvumi.config")

local M = {}

---@alias Result { double: number }

--- eval expression if its a custom func call
--- should be in the form: `funcName(arg1, arg2, ...)`
--- @param expression string
--- @return Result|nil
function M.evaluate_function_call(expression)
  local fn_name, args_str = expression:match("^%s*(%a+)%s*%((.-)%)%s*$")
  if not fn_name then
    return nil
  end

  local custom_functions = config.options.custom_functions or {}
  local target_fn = nil

  for _, f in ipairs(custom_functions) do
    local phrases = f.def and f.def.phrases or ""
    for phrase in phrases:gmatch("[^,]+") do
      if phrase:match("^%s*(.-)%s*$"):lower() == fn_name:lower() then
        target_fn = f.fn
        break
      end
    end
    if target_fn then
      break
    end
  end

  if not target_fn then
    return nil
  end

  local args = {}
  for arg in args_str:gmatch("[^,]+") do
    local trimmed = arg:match("^%s*(.-)%s*$")
    local num = tonumber(trimmed)
    if not num then
      return nil
    end
    table.insert(args, { double = num })
  end

  return target_fn(args)
end

return M
