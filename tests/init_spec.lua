local nvumi = require("nvumi")

describe("nvumi", function()
  before_each(function() end)

  it("should init without errors and register user command", function()
    nvumi.setup()
    local cmds = vim.api.nvim_get_commands({})
    assert.is_truthy(cmds["Nvumi"])
  end)
end)
