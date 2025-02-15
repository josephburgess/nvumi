local fn = vim.fn
local schedule = vim.schedule

local M = {}

function M.run_numi(expr, callback)
  fn.jobstart({ "numi-cli", expr }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      schedule(function()
        callback(data)
      end)
    end,
  })
end

return M
