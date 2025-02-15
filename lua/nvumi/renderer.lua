local api = vim.api
local ns = api.nvim_create_namespace("nvumi_inline")
local M = {}

function M.render_inline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_text = { { " = " .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

function M.render_newline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_lines = { { { " " .. result, "Comment" } } },
  })
end

function M.render_result(buf, line_index, data, config, callback)
  local result = table.concat(data, " ")
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
