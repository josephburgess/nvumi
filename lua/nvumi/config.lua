---@class nvumi
---@field meta table

---@class nvumi.Keys
---@field run string
---@field reset string
---@field yank string
---@field open string

---@class nvumi.Options
---@field virtual_text string
---@field prefix string
---@field keys nvumi.Keys

local M = {}

---@type nvumi.Options
local defaults = {
  virtual_text = "newline",
  prefix = "= ",
  keys = {
    run = "<CR>",
    reset = "R",
    yank = "<leader>y",
    open = "<leader>on",
  },
}

M.options = vim.deepcopy(defaults)

---@param user_opts? nvumi.Options
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", defaults, user_opts or {})
end

return M
