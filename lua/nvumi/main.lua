local M = {}

local function run_numi_line()
	local buf = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_nr = cursor[1] - 1
	local line = vim.api.nvim_buf_get_lines(buf, line_nr, line_nr + 1, false)[1] or ""
	if line == "" then
		return
	end

	vim.fn.jobstart({ "numi-cli", line }, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data and #data > 0 then
				vim.schedule(function()
					local ns = vim.api.nvim_create_namespace("nvumi_inline")

					vim.api.nvim_buf_clear_namespace(buf, ns, line_nr, line_nr + 1)

					vim.api.nvim_buf_set_extmark(buf, ns, line_nr, 0, {
						virt_text = { { " = " .. table.concat(data, " "), "Comment" } },
						virt_text_pos = "eol",
					})
				end)
			end
		end,
	})
end

function M.open()
	local opts = {
		name = "Nvumi",
		ft = "nvumi", -- custom ft to avoid conflicts
		win_by_ft = {
			nvumi = {
				keys = {
					["source"] = {
						"<CR>",
						function(self)
							run_numi_line()
						end,
						mode = { "n", "x" },
					},
				},
			},
		},
	}
	require("snacks.scratch").open(opts)
end

function M.setup()
	vim.api.nvim_create_user_command("Nvumi", function()
		M.open()
	end, {})
end

return M
