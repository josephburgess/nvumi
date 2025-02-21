local assert = require("luassert")
local config = require("nvumi.config")
local converter = require("nvumi.converter")

describe("nvumi.converter", function()
  before_each(function()
    config.options.custom_conversions = {
      {
        id = "speed_a",
        phrases = "a, speed_a",
        base_unit = "speed",
        format = "A",
        ratio = 1, -- base unit
      },
      {
        id = "speed_b",
        phrases = "b, speed_b",
        base_unit = "speed",
        format = "B",
        ratio = 0.5, -- 1 B = 0.5 A/ 2B = 1A
      },
      {
        id = "speed_c",
        phrases = "c, speed_c",
        base_unit = "speed",
        format = "C",
        ratio = 0.25, -- 1 C = 0.25 A / 4C=1a
      },
      {
        id = "volume_a",
        phrases = "va, volume_a",
        base_unit = "volume",
        format = "VA",
        ratio = 1,
      },
      {
        id = "volume_b",
        phrases = "vb, volume_b",
        base_unit = "volume",
        format = "VB",
        ratio = 1 / 3, -- 1 VB = 1/3 VA
      },
    }
  end)

  it("a to b", function()
    local result = converter.process_custom_conversion("10 a in b")
    assert.are.same("20 B", result)
  end)

  it("b to a", function()
    local result = converter.process_custom_conversion("10 b in a")
    assert.are.same("5 A", result) -- 10 * (1/2) = 5
  end)

  it("a to c", function()
    local result = converter.process_custom_conversion("8 a in c")
    assert.are.same("32 C", result) -- 8 * (4/1) = 32
  end)

  it("c to a", function()
    local result = converter.process_custom_conversion("16 c in a")
    assert.are.same("4 A", result) -- 16 * (1/4) = 4
  end)

  it("other base converter - va to vb", function()
    local result = converter.process_custom_conversion("10 VA in VB")
    assert.are.same("30 VB", result) -- 10 * (3/1) = 30
  end)

  it("nil when base converter dont correspond", function()
    assert.is_nil(converter.process_custom_conversion("10 A in VA"))
  end)

  it("nil for invalid converter", function()
    assert.is_nil(converter.process_custom_conversion("10 unknown_unit in B"))
  end)

  it("is case insensitive", function()
    local result = converter.process_custom_conversion("10 speed_a in SPeED_B")
    assert.are.same("20 B", result)
  end)

  it("handles extra spaces", function()
    local result = converter.process_custom_conversion("  10    a    in    b  ")
    assert.are.same("20 B", result)
  end)
end)
