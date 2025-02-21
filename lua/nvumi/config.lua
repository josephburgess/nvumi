---@class nvumi.Keys
---@field run string
---@field reset string
---@field yank string
---@field yank_all string

---@class nvumi.Options
---@field virtual_text string
---@field prefix string
---@field date_format string
---@field keys nvumi.Keys
---@field custom_conversions table
---@field custom_functions table

local M = {}

---@type nvumi.Options
local defaults = {
  virtual_text = "newline",
  prefix = " 🚀 ",
  date_format = "iso",
  keys = {
    run = "<CR>",
    reset = "R",
    yank = "<leader>y",
    yank_all = "<leader>Y",
  },
  -- New field for custom math functions.
  custom_conversions = {},
  custom_functions = {},
}

M.options = vim.deepcopy(defaults)

---@param user_opts? nvumi.Options
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", defaults, user_opts or {})
end

return M
