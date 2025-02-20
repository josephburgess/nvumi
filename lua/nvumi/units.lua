local config = require("nvumi.config")
local M = {}

function M.format_date(result)
  local format = config.options.date_format
  local year, month, day = result:match("(%d%d%d%d)-(%d%d)-(%d%d)")

  if not year then
    return result
  end

  if format == "iso" then
    return result
  end

  if format == "us" then
    return ("%s/%s/%s"):format(month, day, year)
  elseif format == "uk" then
    return ("%s/%s/%s"):format(day, month, year)
  elseif format == "long" then
    local months = {
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    }
    return ("%s %s, %s"):format(months[tonumber(month)], day, year)
  end

  return result
end

return M
