local M = {}

M.options = {
  -- options_tbc = "default",
}

function M.setup(user_opts)
  M.options = vim.tbl_extend("force", M.options, user_opts or {})
end

return M
