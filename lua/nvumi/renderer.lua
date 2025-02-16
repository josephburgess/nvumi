local ns = vim.api.nvim_create_namespace("nvumi_inline")
local state = require("nvumi.state")
local M = {}

---@param buf number          buffer number
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_inline(buf, line_index, result)
  vim.api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_text = { { " = " .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

---@param buf number          buffer number
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_newline(buf, line_index, result)
  vim.api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_lines = { { { " " .. result, "Comment" } } },
  })
end

---@param buf number          buffer number
---@param line_index number   line index (0idx)
---@param data string[]       array of strings representing result
---@param config table        user config
---@param callback? fun()     callback to run once finished rendering (if there's still more lines to process)
function M.render_result(buf, line_index, data, config, callback)
  local result = table.concat(data, " ")
  state.store_output(line_index, result)

  if config.virtual_text == "inline" then
    M.render_inline(buf, line_index, result)
  else
    M.render_newline(buf, line_index, result)
  end

  if callback then
    callback()
  end
end

return M
