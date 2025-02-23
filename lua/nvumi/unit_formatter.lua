local config = require("nvumi.config")
local M = {}

function M.format_date(result)
  local year, month, day = result:match("(%d%d%d%d)-(%d%d)-(%d%d)")

  if not year then return result end

  local format = config.options.date_format

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

  local formats = {
    us = ("%s/%s/%s"):format(month, day, year),
    uk = ("%s/%s/%s"):format(day, month, year),
    long = ("%s %s, %s"):format(months[tonumber(month)], day, year),
  }

  return formats[format] or result
end

return M
