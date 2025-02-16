local api = vim.api
local config = require("nvumi.config")
local processor = require("nvumi.processor")
local renderer = require("nvumi.renderer")
local M = {}

---@return nil
function M.open()
  local opts = config.options
  ---@diagnostic disable-next-line: missing-fields
  require("snacks.scratch").open({
    name = "Nvumi",
    ft = "nvumi",
    icon = "",
    win_by_ft = {
      nvumi = {
        keys = {
          ["source"] = { opts.keys.run, processor.run_on_buffer, mode = { "n", "x" }, desc = "Run Numi" },
          ["reset"] = { opts.keys.reset, processor.reset_buffer, mode = "n", desc = "Reset buffer" },
          ["yank"] = { opts.keys.yank, renderer.yank_last_output, mode = "n", desc = "Yank last answer" },
        },
      },
    },
  })
end

---@return nil
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

return M
