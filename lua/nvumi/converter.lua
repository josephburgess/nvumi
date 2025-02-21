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
  local normalized_unit = normalize_unit(unit_str)

  for _, conversion in ipairs(config.custom_conversions or {}) do
    for phrase in conversion.phrases:gmatch("[^,]+") do
      if normalize_unit(phrase) == normalized_unit then
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

--- @param expression string
--- @return string | nil
local function convert_units(expression)
  expression = trim(expression)

  local value_str, source_unit, target_unit = expression:match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)%s*$")
  if not value_str then
    return nil
  end

  local value = tonumber(value_str)
  local source_conv = find_conversion(source_unit)
  local target_conv = find_conversion(target_unit)

  -- ensure both units exist w/ same base unit
  if not (source_conv and target_conv) or source_conv.base_unit ~= target_conv.base_unit then
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
