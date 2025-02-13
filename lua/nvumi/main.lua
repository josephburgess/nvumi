local M = {}
local function run_numi_line()
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
