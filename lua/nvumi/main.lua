local M = {}

local function run_numi_on_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local ns = vim.api.nvim_create_namespace("nvumi_inline")

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for line_nr, line in ipairs(lines) do
    if line:match("%S") then
      vim.fn.jobstart({ "numi-cli", line }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local result = table.concat(data, " ")
            local virt_lines = {}
            for _, txt in ipairs(vim.split(result, "\n")) do
              table.insert(virt_lines, { { " " .. txt, "Comment" } })
            end
            vim.schedule(function()
              vim.api.nvim_buf_set_extmark(buf, ns, line_nr - 1, 0, {
                virt_lines = virt_lines,
              })
            end)
          end
        end,
      })
    end
  end
end

function M.open()
  local opts = {
    name = "Nvumi",
    ft = "nvumi",
    win_by_ft = {
      nvumi = {
        keys = {
          ["source"] = {
            "<CR>",
            function()
              run_numi_on_buffer()
            end,
            mode = { "n", "x" },
          },
        },
      },
    },
  }
  require("snacks.scratch").open(opts)
end

function M.setup()
  vim.api.nvim_create_user_command("Nvumi", function()
    M.open()
  end, {})
end

return M
