local M = {}
local config = require("nvumi.config")

-- trim whitespc
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- given a unit str, find  a matching conversion def
local function lookup_unit(unit_str)
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

-- process (in form: "value src_unit in target_unit")
local function process_conversion(expr)
  local val_str, src_unit, target_unit = expr:match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)$")

  if not val_str then
    return nil
  end

  local value = tonumber(val_str)
  local src_conv = lookup_unit(src_unit)
  local target_conv = lookup_unit(target_unit)

  -- ensure both units exist w/ same base unit
  if src_conv and target_conv and src_conv.base_unit and target_conv.base_unit then
    if src_conv.base_unit == target_conv.base_unit then
      local result_value = value * (src_conv.ratio / target_conv.ratio)
      return format_result(result_value, target_conv)
    end
  end
  return nil
end

function M.process_custom_conversion(expr)
  local result = process_conversion(expr)
  if result then
    return result
  end
  return nil
end

return M
