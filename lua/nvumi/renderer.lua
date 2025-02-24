local ns = vim.api.nvim_create_namespace("nvumi_inline")
local state = require("nvumi.state")
local units = require("nvumi.unit_formatter")

local M = {}

---@param ctx table           context
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_inline(ctx, line_index, result)
  vim.api.nvim_buf_set_extmark(ctx.buf, ns, line_index, 0, {
    virt_text = { { ctx.opts.prefix .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

---@param ctx table           context
---@param line_index number   line index (0idx)
---@param result string       answer string
function M.render_newline(ctx, line_index, result)
  vim.api.nvim_buf_set_extmark(ctx.buf, ns, line_index, 0, {
    virt_lines = { { { ctx.opts.prefix .. result, "Comment" } } },
  })
end

---@param ctx table           context
---@param line_index number   line index (0idx)
---@param result string       evaluation result
---@param callback fun()     callback to run once finished rendering (if there's still more lines to process)
function M.render_result(ctx, line_index, result, callback)
  -- dont rerender if same result
  if state.get_output(line_index) == result then return callback() end

  state.store_output(line_index, result)
  vim.api.nvim_buf_clear_namespace(ctx.buf, ns, line_index, line_index + 1)
  result = units.format_date(result)

  if ctx.opts.virtual_text == "inline" then
    M.render_inline(ctx, line_index, result)
  else
    M.render_newline(ctx, line_index, result)
  end

  callback()
end

return M
