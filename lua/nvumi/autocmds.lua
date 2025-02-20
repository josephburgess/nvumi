local actions = require("nvumi.actions")
local debounce = require("nvumi.debounce").debounce

local M = {}

local cmd_group = vim.api.nvim_create_augroup("NvumiAutocmds", { clear = true })

function M.setup()
  -- setup comments/syntax highlighting
  vim.api.nvim_create_autocmd("FileType", {
    group = cmd_group,
    pattern = "nvumi",
    callback = function()
      vim.bo.commentstring = "-- %s"
      vim.cmd("set syntax=nvumi")
      vim.cmd([[
        syntax clear Comment
        syntax match Comment /^\s*--.*/
      ]])
    end,
  })

  -- evaluate whole buffer on exit insert
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = cmd_group,
    pattern = "*.nvumi",
    callback = function()
      actions.run_on_buffer()
    end,
  })

  -- live evaluations
  local debounced_rol = debounce(300, actions.run_on_line)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = cmd_group,
    pattern = "*.nvumi",
    callback = function()
      debounced_rol()
    end,
  })
end

return M
