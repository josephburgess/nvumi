local config = require("nvumi.config")
local main = require("nvumi.main")
local M = {}

function M.setup(user_config)
  config.setup(user_config)
  main.setup()
end

return M
