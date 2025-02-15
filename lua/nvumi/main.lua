local M = {}

local api = vim.api
local fn = vim.fn
local schedule = vim.schedule
local ns = api.nvim_create_namespace("nvumi_inline")

local variables = require("nvumi.variables")

local function render_inline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_text = { { " = " .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

local function render_newline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_lines = { { { " " .. result, "Comment" } } },
  })
end

local function render_result(buf, line_index, data, config, callback)
  local result = table.concat(data, " ")
  if config.virtual_text == "inline" then
    render_inline(buf, line_index, result)
  else
    render_newline(buf, line_index, result)
  end
  if callback then
    callback()
  end
end

-- helper to run numi asynchronously
local function run_numi(expr, callback)
  fn.jobstart({ "numi-cli", expr }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      schedule(function()
        callback(data)
      end)
    end,
  })
end

-- Process a line:
-- if empty or comment, bail
-- if an assignment, substitute var, run the expression, set var and render the result
-- else just evaluate the expression and render the result.
local function process_line(line, index, buf, config, next_callback)
  if not line:match("%S") or line:match("^%s*%-%-") then
    return next_callback()
    -- bail
  end

  local var, expr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
  if var and expr then
    local substituted_expr = variables.substitute_variables(expr)
    run_numi(substituted_expr, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      local result = table.concat(data, " ")
      variables.set_variable(var, result)
      render_result(buf, index - 1, { result }, config, next_callback)
    end)
  else
    local substituted_line = variables.substitute_variables(line)
    run_numi(substituted_line, function(data)
      if not data or #data == 0 then
        return next_callback()
      end
      render_result(buf, index - 1, data, config, next_callback)
    end)
  end
end

-- recursively process
local function process_lines(lines, buf, config, index)
  if index > #lines then
    return
  end
  process_line(lines[index], index, buf, config, function()
    process_lines(lines, buf, config, index + 1)
  end)
end

local function run_numi_on_buffer()
  local config = require("nvumi.config").options
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  process_lines(lines, buf, config, 1)
end

local function reset_buffer()
  local buf = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  variables.clear_variables()
end

function M.open()
  local config = require("nvumi.config").options
  require("snacks.scratch").open({
    name = "Nvumi",
    ft = "nvumi",
    icon = "",
    win_by_ft = {
      nvumi = {
        keys = {
          ["source"] = { config.keys.run, run_numi_on_buffer, mode = { "n", "x" }, desc = "Run Numi" },
          ["reset"] = { config.keys.reset, reset_buffer, mode = "n", desc = "Reset buffer" },
        },
      },
    },
  })
end

function M.setup()
  api.nvim_create_user_command("Nvumi", function()
    M.open()
  end, {})
  require("nvim-web-devicons").set_icon({ nvumi = { icon = "" } })

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
end

M._test = {
  run_numi_on_buffer = run_numi_on_buffer,
  reset_buffer = reset_buffer,
}

return M
