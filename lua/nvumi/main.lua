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
            vim.schedule(function()
              vim.api.nvim_buf_set_extmark(buf, ns, line_nr - 1, 0, {
                virt_text = { { " = " .. table.concat(data, " "), "Comment" } },
                virt_text_pos = "eol",
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
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
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
