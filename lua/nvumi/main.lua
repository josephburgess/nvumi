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
          ["source"] = { opts.keys.run, actions.run_on_buffer, mode = { "n", "x" }, desc = "Run" },
          ["reset"] = { opts.keys.reset, actions.reset_buffer, mode = "n", desc = "Reset" },
          ["yank"] = { opts.keys.yank, state.yank_output_on_line, mode = "n", desc = "Yank Line" },
          ["yank_all"] = { opts.keys.yank_all, state.yank_all_outputs, mode = "n", desc = "Yank All" },
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

  vim.api.nvim_create_user_command("NvumiEvalLine", function()
    require("nvumi.actions").run_on_line()
  end, {})

  vim.api.nvim_create_user_command("NvumiEvalBuf", function()
    require("nvumi.actions").run_on_buffer()
  end, {})

  vim.api.nvim_create_user_command("NvumiClear", function()
    require("nvumi.actions").reset_buffer()
  end, {})

  require("nvim-web-devicons").set_icon({ nvumi = { icon = "" } })

  autocmds.setup()
end

return M
