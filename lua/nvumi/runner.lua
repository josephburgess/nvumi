local M = {}

---@param expr string                   expression to run with numi-cli
---@param callback fun(data: string[])  callback to receive the output
function M.run_numi(expr, callback)
  if vim.fn.executable("numi-cli") == 0 then
    vim.notify("Error: `numi-cli` is not installed or not in PATH.\n" .. "Type `:help Nvumi` for more.", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "numi-cli", expr }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      vim.schedule(function()
        callback(data)
      end)
    end,
  })
end

---@param expr string
---@return string
function M.run_numi_sync(expr)
  if vim.fn.executable("numi-cli") == 0 then
    vim.notify("Error: `numi-cli` is not installed or not in PATH.\n" .. "Type `:help Nvumi` for more.", vim.log.levels.ERROR)
    return ""
  end

  local output = (vim.fn.system({ "numi-cli", expr }) or ""):gsub("\n", "")
  return output
end

return M
