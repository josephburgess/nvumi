---@class nvumi
---@field meta table

---@class nvumi.Keys
---@field run string
---@field reset string
---@field yank string

---@class nvumi.Options
---@field virtual_text string
---@field keys nvumi.Keys

local M = {}

---@type nvumi.Options
local defaults = {
  virtual_text = "newline",
  keys = {
    run = "<CR>",
    reset = "R",
    yank = "<leader>y",
  },
}

M.options = defaults

---@param user_opts? nvumi.Options
function M.setup(user_opts)
  M.options = vim.tbl_extend("force", M.options, user_opts or {})
end

return M
