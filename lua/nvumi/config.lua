-- keybinds
---@class NvumiKeys
---@field run string
---@field reset string
---@field yank string

-- opts
---@class NvumiOptions
---@field virtual_text string
---@field keys NvumiKeys

local M = {}

local default_options = {
  virtual_text = "newline", -- or "inline"
  keys = {
    run = "<CR>", -- run calculations
    reset = "R", -- reset buffer
    yank = "<C-y>", -- yank last output
  },
}

---@type NvumiOptions
M.options = default_options

---@param user_opts? NvumiOptions
function M.setup(user_opts)
  M.options = vim.tbl_extend("force", M.options, user_opts or {})
end

return M
