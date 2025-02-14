local M = {}

local api = vim.api
local fn = vim.fn
local schedule = vim.schedule
local ns = api.nvim_create_namespace("nvumi_inline")

local function render_inline(buf, line_index, result)
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, {
    virt_text = { { " = " .. result, "Comment" } },
    virt_text_pos = "eol",
  })
end

local function render_newline(buf, line_index, result)
  local virt_lines = {}
  for _, txt in ipairs(vim.split(result, "\n")) do
    table.insert(virt_lines, { { " " .. txt, "Comment" } })
  end
  api.nvim_buf_set_extmark(buf, ns, line_index, 0, { virt_lines = virt_lines })
end

local function run_numi_on_buffer()
  local config = require("nvumi.config").options
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for i, line in ipairs(lines) do
    if line:match("%S") then
      fn.jobstart({ "numi-cli", line }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            schedule(function()
              local result = table.concat(data, " ")
              if config.virtual_text == "inline" then
                render_inline(buf, i - 1, result)
              else
                render_newline(buf, i - 1, result)
              end
            end)
          end
        end,
      })
    end
  end
end

local function reset_buffer()
  local buf = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(buf, 0, -1, false, {})
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

function M.open()
  require("snacks.scratch").open({
    name = "Nvumi",
    ft = "nvumi",
    icon = "",
    win_by_ft = {
      nvumi = {
        keys = {
          ["source"] = { "<CR>", run_numi_on_buffer, mode = { "n", "x" }, desc = "Run Numi" },
          ["reset"] = { "R", reset_buffer, mode = "n", desc = "Reset buffer" },
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
end

M._test = {
  run_numi_on_buffer = run_numi_on_buffer,
  reset_buffer = reset_buffer,
}

return M
