local actions = require("nvumi.actions")
local config = require("nvumi.config")
local state = require("nvumi.state")

local M = {}

local bufnr = nil
local winid = nil

local function is_open()
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function build_footer()
  local keys = config.options.keys
  return string.format(" %s run  %s reset  %s yank  %s yank all ", keys.run, keys.reset, keys.yank, keys.yank_all)
end

local function get_or_create_buf()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    return bufnr
  end

  bufnr = vim.api.nvim_create_buf(false, true)

  local keys = config.options.keys
  vim.keymap.set({ "n", "x" }, keys.run, actions.run_on_buffer, { buffer = bufnr, desc = "nvumi: run" })
  vim.keymap.set("n", keys.reset, actions.reset_buffer, { buffer = bufnr, desc = "nvumi: reset" })
  vim.keymap.set("n", keys.yank, state.yank_output_on_line, { buffer = bufnr, desc = "nvumi: yank line" })
  vim.keymap.set("n", keys.yank_all, state.yank_all_outputs, { buffer = bufnr, desc = "nvumi: yank all" })
  vim.keymap.set("n", "q", M.close, { buffer = bufnr, desc = "nvumi: close" })

  -- set filetype last so the FileType autocmd sees a fully configured buffer
  vim.bo[bufnr].filetype = "nvumi"

  return bufnr
end

local function open_win(buf)
  local width = math.floor(vim.o.columns * 0.65)
  local height = math.floor(vim.o.lines * 0.65)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " nvumi ",
    title_pos = "center",
    footer = build_footer(),
    footer_pos = "center",
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      winid = nil
    end,
  })

  return win
end

function M.open()
  if is_open() then
    M.close()
    return
  end

  local buf = get_or_create_buf()
  winid = open_win(buf)
end

function M.close()
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, false)
  end
  winid = nil
end

return M
