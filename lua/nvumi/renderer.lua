local api = vim.api
local ns = api.nvim_create_namespace("nvumi_inline")
local last_output = nil
local M = {}

---@param buf number          buffer number
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_inline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_text = { { " = " .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

---@param buf number          buffer number
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_newline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
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
  last_output = result -- store the latest result
  if config.virtual_text == "inline" then
    M.render_inline(buf, line_index, result)
  else
    M.render_newline(buf, line_index, result)
  end
  if callback then
    callback()
  end
end

function M.yank_last_output()
  if last_output then
    vim.fn.setreg("+", last_output)
    print("Yanked: " .. last_output)
  else
    print("No output available to yank")
  end
end
return M
