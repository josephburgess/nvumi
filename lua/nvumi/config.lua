local M = {}

M.options = {
  virtual_text = "newline", -- or "inline"
  keys = {
    run = "<CR>", -- run calculations
    reset = "R", -- reset buffer
  },
}

function M.setup(user_opts)
  M.options = vim.tbl_extend("force", M.options, user_opts or {})
end

return M
