local M = {}

local function run_numi_on_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("nvumi_inline")
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for i, line in ipairs(lines) do
    if line:match("%S") then
      vim.fn.jobstart({ "numi-cli", line }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local virt_lines = {}
            for _, txt in ipairs(vim.split(table.concat(data, " "), "\n")) do
              table.insert(virt_lines, { { "  " .. txt, "Comment" } })
            end
            vim.schedule(function()
              vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_lines = virt_lines })
            end)
          end
        end,
      })
    end
  end
end

local function reset_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("nvumi_inline")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

function M.open()
  require("snacks.scratch").open({
    name = "Nvumi",
    ft = "nvumi",
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
  vim.api.nvim_create_user_command("Nvumi", function()
    M.open()
  end, {})
end

return M
