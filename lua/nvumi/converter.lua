local M = {}
local config = require("nvumi.config")

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

function M.process_custom_conversion(expr)
  local value_str, src_unit_str, target_unit_str = expr:match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)$")
  if value_str then
    local value = tonumber(value_str)
    local src_conv, target_conv
    local src_unit = trim(src_unit_str):lower()
    local target_unit = trim(target_unit_str):lower()

    for _, conv in ipairs(config.custom_conversions or {}) do
      for phrase in conv.phrases:gmatch("[^,]+") do
        local p = trim(phrase):lower()
        if src_unit == p then
          src_conv = conv
          break
        end
      end
      if src_conv then
        break
      end
    end

    for _, conv in ipairs(config.custom_conversions or {}) do
      for phrase in conv.phrases:gmatch("[^,]+") do
        local p = trim(phrase):lower()
        if target_unit == p then
          target_conv = conv
          break
        end
      end
      if target_conv then
        break
      end
    end

    if src_conv and target_conv then
      if src_conv.baseUnitId and target_conv.baseUnitId and src_conv.baseUnitId == target_conv.baseUnitId then
        vim.print("target", target_conv.baseUnitId)
        vim.print("src", src_conv.baseUnitId)
        local result_value = value * (src_conv.ratio / target_conv.ratio)
        local result_str = tostring(result_value)
        if target_conv.format then
          result_str = result_str .. " " .. target_conv.format
        end
        return result_str
      end
    end
  end

  for _, conv in ipairs(config.custom_conversions or {}) do
    for phrase in conv.phrases:gmatch("[^,]+") do
      local p = trim(phrase):lower()
      if expr:lower():find(p) then
        local num_str = expr:match("(%d+%.?%d*)%s*" .. p)
        local num = tonumber(num_str)
        if num then
          local result = num * conv.ratio
          local result_str = tostring(result)
          if conv.format then
            result_str = result_str .. " " .. conv.format
          end
          return result_str
        end
      end
    end
  end
  return nil
end

return M
