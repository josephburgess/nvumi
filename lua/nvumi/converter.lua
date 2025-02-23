local M = {}
local config = require("nvumi.config")

---@alias Conversion { phrases: string, base_unit: string, ratio: number, format: string? }

---@param s string
---@return string
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

--- @param unit_str string
--- @return string
local function normalize_unit(unit_str)
  return trim(unit_str):lower()
end

--- @param unit_str string
---@return Conversion|nil
local function find_conversion(unit_str)
  local custom_conversions = config.options.custom_conversions or {}

  for _, conversion in ipairs(custom_conversions) do
    for phrase in conversion.phrases:gmatch("[^,]+") do
      if normalize_unit(phrase) == normalize_unit(unit_str) then
        return conversion
      end
    end
  end

  return nil
end

--- @param value number
--- @param conversion Conversion
--- @return string
local function format_result(value, conversion)
  return conversion and conversion.format and string.format("%s %s", value, conversion.format) or tostring(value)
end
local function extract_conversion_val_and_units(expression)
  local value_str, source_unit, target_unit = trim(expression):match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)%s*$")
  return tonumber(value_str), source_unit, target_unit
end

--- @param expression string
--- @return string | nil
local function convert_units(expression)
  local value, source_unit, target_unit = extract_conversion_val_and_units(expression)

  if not value or not source_unit or not target_unit then
    return nil
  end

  local source_conv, target_conv = find_conversion(source_unit), find_conversion(target_unit)

  -- ensure both units exist w/ same base unit
  if not (source_conv and target_conv and source_conv.base_unit == target_conv.base_unit) then
    return nil
  end

  local result = value * (source_conv.ratio / target_conv.ratio)
  return format_result(result, target_conv)
end

---@param expression any
---@return string|nil
function M.process_custom_conversion(expression)
  return convert_units(expression)
end

return M
