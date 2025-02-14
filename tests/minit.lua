#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- mocked to avoid errs
package.preload["nvim-web-devicons"] = function()
  return { set_icon = function(_) end }
end

require("lazy.minit").setup({ spec = { { dir = vim.uv.cwd() } } })
