local assert = require("luassert")
local units = require("nvumi.unit_formatter")

describe("nvumi.unit_formatter", function()
  before_each(function()
    require("nvumi.config").options.date_format = "iso"
  end)

  it("returns the original result if not a valid date", function()
    assert.are.same("catch a throatful", units.format_date("catch a throatful"))
    assert.are.same("42", units.format_date("42"))
  end)

  it("formats dates in ISO format (YYYY-MM-DD)", function()
    require("nvumi.config").options.date_format = "iso"
    assert.are.same("2025-02-21", units.format_date("2025-02-21"))
  end)

  it("formats dates in US format (MM/DD/YYYY)", function()
    require("nvumi.config").options.date_format = "us"
    assert.are.same("02/21/2025", units.format_date("2025-02-21"))
  end)

  it("formats dates in UK format (DD/MM/YYYY)", function()
    require("nvumi.config").options.date_format = "uk"
    assert.are.same("21/02/2025", units.format_date("2025-02-21"))
  end)

  it("formats dates in long format (Month DD, YYYY)", function()
    require("nvumi.config").options.date_format = "long"
    assert.are.same("February 21, 2025", units.format_date("2025-02-21"))
  end)
end)
