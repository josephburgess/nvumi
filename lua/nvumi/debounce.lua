local M = {}

--- @param ms number:   debounce delay (ms)
--- @param fn function: function to debounce
--- @return function:   debounced function
function M.debounce(ms, fn)
  local timer = vim.loop.new_timer()
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule(function()
        fn(unpack(args))
      end)
    end)
  end
end

return M
