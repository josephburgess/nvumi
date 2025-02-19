local actions = require("nvumi.actions")
local debounce = require("nvumi.debounce").debounce

local M = {}

function M.setup()
  -- setup comments/syntax highlighting
  vim.api.nvim_create_autocmd("FileType", {
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
  local debounced_rob = debounce(500, actions.run_on_buffer)
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    pattern = "*.nvumi",
    callback = function()
      debounced_rob()
    end,
  })

  -- live evaluations
  local debounced_rol = debounce(300, actions.run_on_line)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*.nvumi",
    callback = function()
      debounced_rol()
    end,
  })
end

return M
