local state = require("nvumi.state")

local M = {}

local function check_executable()
  if vim.fn.executable("numi-cli") == 0 then
    vim.notify("Error: `numi-cli` is not installed or not in PATH.\nType `:help Nvumi` for more.", vim.log.levels.ERROR)
    return false
  end
  return true
end

---@param expr string                   expression to run with numi-cli
---@param callback fun(data: string[])  callback to receive the output
function M.run_numi(expr, callback)
  if not check_executable() then return end
  local gen = state.eval_gen
  vim.fn.jobstart({ "numi-cli", expr }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.schedule(function()
        if state.is_current_gen(gen) then callback(data) end
      end)
    end,
  })
end

---@param expr string
---@return string
function M.run_numi_sync(expr)
  if not check_executable() then return "" end
  return (vim.fn.system({ "numi-cli", expr }) or ""):gsub("\n", "")
end

return M
