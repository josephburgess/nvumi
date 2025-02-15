local config = require("nvumi.config")

describe("nvumi.config", function()
  before_each(function()
    config.options = {
      virtual_text = "newline",
      keys = {
        run = "<CR>",
        reset = "<C-r>",
      },
    }
  end)

  it("should have the default virtual_text set to 'newline'", function()
    assert.are.same("newline", config.options.virtual_text)
  end)

  it("should override virtual_text when setup is called", function()
    config.setup({ virtual_text = "inline" })
    assert.are.same("inline", config.options.virtual_text)
  end)

  it("should have default keys", function()
    assert.are.same("<CR>", config.options.keys.run)
    assert.are.same("<C-r>", config.options.keys.reset)
  end)

  it("should override keys when setup is called", function()
    config.setup({ keys = { run = "<Enter>", reset = "R" } })
    assert.are.same("<Enter>", config.options.keys.run)
    assert.are.same("R", config.options.keys.reset)
  end)
end)
