local config = require("nvumi.config")

describe("nvumi.config", function()
  before_each(function()
    config.options = { virtual_text = "newline" }
  end)

  it("should have the default virtual_text set to 'newline'", function()
    assert.are.same("newline", config.options.virtual_text)
  end)

  it("should override virtual_text when setup is called", function()
    config.setup({ virtual_text = "inline" })
    assert.are.same("inline", config.options.virtual_text)
  end)
end)
