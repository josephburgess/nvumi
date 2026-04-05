local autocmds = require("nvumi.autocmds")
local M = {}

---@return nil
function M.open()
  require("nvumi.scratch").open()
end

---@return nil
function M.setup()
  vim.api.nvim_create_user_command("Nvumi", M.open, {})

  vim.api.nvim_create_user_command("NvumiEvalLine", function()
    require("nvumi.actions").run_on_line()
  end, {})

  vim.api.nvim_create_user_command("NvumiEvalBuf", function()
    require("nvumi.actions").run_on_buffer()
  end, {})

  vim.api.nvim_create_user_command("NvumiClear", function()
    require("nvumi.actions").reset_buffer()
  end, {})

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then devicons.set_icon({ nvumi = { icon = "" } }) end

  autocmds.setup()
end

return M
