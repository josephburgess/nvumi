local actions = require("nvumi.actions")
local debounce = require("nvumi.debounce").debounce

local M = {}

local cmd_group = vim.api.nvim_create_augroup("NvumiAutocmds", { clear = true })

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = cmd_group,
    pattern = "nvumi",
    callback = function(ev)
      vim.bo[ev.buf].commentstring = "-- %s"
      vim.cmd("setlocal syntax=nvumi")
      vim.cmd([[
        syntax clear Comment
        syntax match Comment /^\s*--.*/
      ]])

      local buf_group = vim.api.nvim_create_augroup("NvumiBuffer_" .. ev.buf, { clear = true })

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = buf_group,
        buffer = ev.buf,
        callback = actions.run_on_buffer,
      })

      local debounced_rob = debounce(300, actions.run_on_buffer)
      local debounced_rol = debounce(300, actions.run_on_line)

      vim.api.nvim_create_autocmd("TextChanged", {
        group = buf_group,
        buffer = ev.buf,
        callback = debounced_rob,
      })

      vim.api.nvim_create_autocmd("TextChangedI", {
        group = buf_group,
        buffer = ev.buf,
        callback = debounced_rol,
      })
    end,
  })
end

return M
