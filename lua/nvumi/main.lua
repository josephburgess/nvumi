local actions = require("nvumi.actions")
local autocmds = require("nvumi.autocmds")
local config = require("nvumi.config")
local state = require("nvumi.state")
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
          ["source"] = { opts.keys.run, actions.run_on_buffer, mode = { "n", "x" }, desc = "Run Numi" },
          ["reset"] = { opts.keys.reset, actions.reset_buffer, mode = "n", desc = "Reset Buffer" },
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

  autocmds.setup()
end

return M
