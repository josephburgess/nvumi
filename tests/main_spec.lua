local assert = require("luassert")
local main = require("nvumi.main")

describe("nvumi.main", function()
  before_each(function()
    package.preload["snacks.scratch"] = function()
      return {
        open = function(opts)
          _G._TEST_NVUMI_OPEN_OPTS = opts
        end,
      }
    end
  end)

  after_each(function()
    _G._TEST_NVUMI_OPEN_OPTS = nil
    package.preload["snacks.scratch"] = nil
  end)

  it("should open a scratch buffer when Nvumi is invoked", function()
    main.open()
    assert.is_truthy(_G._TEST_NVUMI_OPEN_OPTS)
    assert.are.same("Nvumi", _G._TEST_NVUMI_OPEN_OPTS.name)
    local keys = _G._TEST_NVUMI_OPEN_OPTS.win_by_ft.nvumi.keys
    assert.is_truthy(keys["source"])
    assert.is_truthy(keys["reset"])
  end)
end)
