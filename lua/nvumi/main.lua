local config = require("nvumi.config")
local processor = require("nvumi.processor")
local state = require("nvumi.state")
local debounce = require("nvumi.debounce").debounce
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
          ["reset"] = { opts.keys.reset, processor.reset_buffer, mode = "n", desc = "Reset Buffer" },
          ["yank"] = { opts.keys.yank, state.yank_last_output, mode = "n", desc = "Yank Last" },
        },
      },
    },
  })
end

---@return nil
function M.setup()
  vim.api.nvim_create_user_command("Nvumi", function()
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

  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    pattern = "*.nvumi",
    callback = function()
      processor.run_on_buffer()
    end,
  })

  local debounced_eval = debounce(300, require("nvumi.processor").run_on_line)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*.nvumi",
    callback = function()
      debounced_eval()
    end,
  })
end

return M
