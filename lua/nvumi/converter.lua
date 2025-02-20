local M = {}
local config = require("nvumi.config")

-- trim whitespc
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- given a unit str, find  a matching conversion def
local function find_conversion_unit(unit_str)
  local unit_lower = trim(unit_str):lower()
  for _, conv in ipairs(config.custom_conversions or {}) do
    for phrase in conv.phrases:gmatch("[^,]+") do
      local phrase_lower = trim(phrase):lower()
      if unit_lower == phrase_lower then
        return conv
      end
    end
  end
  return nil
end

-- append the unit's identifier/formatstr to the result
local function format_result(value, conv)
  local result = tostring(value)
  if conv and conv.format then
    result = result .. " " .. conv.format
  end
  return result
end

-- process full conversion - form: "value src_unit in target_unit".
local function process_full_conversion(expr)
  local value_str, src_unit_str, target_unit_str = expr:match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)$")
  if not value_str then
    return nil
  end

  local value = tonumber(value_str)
  local src_conv = find_conversion_unit(src_unit_str)
  local target_conv = find_conversion_unit(target_unit_str)

  -- ensure both units exist w/ same base unit
  if src_conv and target_conv and src_conv.baseUnitId and target_conv.baseUnitId then
    if src_conv.baseUnitId == target_conv.baseUnitId then
      local result_value = value * (src_conv.ratio / target_conv.ratio)
      return format_result(result_value, target_conv)
    end
  end
  return nil
end

-- mainly for variable assignment - if someone said x = 10 liters, this should work in assigning that variable as 10 L
local function process_simple_conversion(expr)
  local expr_lower = expr:lower()
  for _, conv in ipairs(config.custom_conversions or {}) do
    for phrase in conv.phrases:gmatch("[^,]+") do
      local phrase_lower = trim(phrase):lower()
      if expr_lower:find(phrase_lower) then
        local num_str = expr:match("(%d+%.?%d*)%s*" .. phrase_lower)
        local num = tonumber(num_str)
        if num then
          local result = num * conv.ratio
          return format_result(result, conv)
        end
      end
    end
  end
  return nil
end

function M.process_custom_conversion(expr)
  local result = process_full_conversion(expr)
  if result then
    return result
  end
  return process_simple_conversion(expr)
end

return M
