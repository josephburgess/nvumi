local assert = require("luassert")
local main = require("nvumi.main")

describe("nvumi.main", function()
  before_each(function()
    package.preload["nvumi.scratch"] = function()
      return {
        open = function()
          _G._TEST_NVUMI_SCRATCH_OPENED = true
        end,
      }
    end
  end)

  after_each(function()
    _G._TEST_NVUMI_SCRATCH_OPENED = nil
    package.preload["nvumi.scratch"] = nil
    package.loaded["nvumi.scratch"] = nil
  end)

  it("should open a scratch buffer when Nvumi is invoked", function()
    main.open()
    assert.is_truthy(_G._TEST_NVUMI_SCRATCH_OPENED)
  end)
end)
