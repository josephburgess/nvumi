local M = {}
local config = require("nvumi.config")

function M.process_custom_conversion(expr)
  local value_str, src_unit_str, target_unit_str = expr:match("^(%d+%.?%d*)%s+(.+)%s+in%s+(.+)$")
  if value_str then
    local value = tonumber(value_str)
    local src_conv, target_conv

    for _, conv in ipairs(config.custom_conversions or {}) do
      for phrase in conv.phrases:gmatch("[^,]+") do
        phrase = phrase:match("^%s*(.-)%s*$"):lower()
        if src_unit_str:lower():find(phrase, 1, true) then
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
        phrase = phrase:match("^%s*(.-)%s*$"):lower()
        if target_unit_str:lower():find(phrase, 1, true) then
          target_conv = conv
          break
        end
      end
      if target_conv then
        break
      end
    end

    if src_conv and target_conv then
      local result_value = value * (src_conv.ratio / target_conv.ratio)
      local result_str = tostring(result_value)
      if target_conv.format then
        result_str = result_str .. " " .. target_conv.format
      end
      return result_str
    end
  end

  for _, conv in ipairs(config.custom_conversions or {}) do
    for phrase in conv.phrases:gmatch("[^,]+") do
      phrase = phrase:match("^%s*(.-)%s*$")
      if expr:find(phrase) then
        local num_str = expr:match("(%d+%.?%d*)%s*" .. phrase)
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
