local actions = require("nvumi.actions")
local config = require("nvumi.config")
local state = require("nvumi.state")

local M = {}

local bufnr = nil
local winid = nil

local icon = "󰿉"
local PERSIST_FILE = vim.fn.stdpath("data") .. "/nvumi.scratch"

local function save_buf(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local f = io.open(PERSIST_FILE, "w")
  if f then
    f:write(table.concat(lines, "\n"))
    f:close()
  end
end

local function load_buf(buf)
  local f = io.open(PERSIST_FILE, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()
  if content and content ~= "" then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
  end
end

local function is_open()
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function build_footer()
  local keys = config.options.keys
  local sep = { "  ·  ", "FloatBorder" }
  return {
    { " ", "FloatBorder" },
    { keys.run, "FloatTitle" },
    { " Run", "Comment" },
    sep,
    { keys.reset, "FloatTitle" },
    { " Reset", "Comment" },
    sep,
    { keys.yank, "FloatTitle" },
    { " Yank", "Comment" },
    sep,
    { keys.yank_all, "FloatTitle" },
    { " Yank all", "Comment" },
    sep,
    { "q", "FloatTitle" },
    { " Close ", "Comment" },
  }
end

local function get_or_create_buf()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then return bufnr end

  bufnr = vim.api.nvim_create_buf(false, true)

  local keys = config.options.keys
  vim.keymap.set({ "n", "x" }, keys.run, actions.run_on_buffer, { buffer = bufnr, desc = "nvumi: run" })
  vim.keymap.set("n", keys.reset, function()
    actions.reset_buffer()
    local f = io.open(PERSIST_FILE, "w")
    if f then f:close() end
  end, { buffer = bufnr, desc = "nvumi: reset" })
  vim.keymap.set("n", keys.yank, state.yank_output_on_line, { buffer = bufnr, desc = "nvumi: yank line" })
  vim.keymap.set("n", keys.yank_all, state.yank_all_outputs, { buffer = bufnr, desc = "nvumi: yank all" })
  vim.keymap.set("n", "q", M.close, { buffer = bufnr, desc = "nvumi: close" })

  -- set filetype last (triggers autocmds)
  vim.bo[bufnr].filetype = "nvumi"

  load_buf(bufnr)

  return bufnr
end

local function open_win(buf)
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.4)
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
    title = { { " " .. icon .. " nvumi ", "FloatTitle" } },
    title_pos = "center",
    footer = build_footer(),
    footer_pos = "center",
  })

  vim.wo[win].scrolloff = 2
  vim.wo[win].statuscolumn = "  "

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      save_buf(bufnr)
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
  if winid and vim.api.nvim_win_is_valid(winid) then vim.api.nvim_win_close(winid, false) end
  winid = nil
end

return M
