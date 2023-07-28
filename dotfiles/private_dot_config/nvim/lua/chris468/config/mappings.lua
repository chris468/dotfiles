local function find_git_files()
	local ok, tbi = pcall(require, "telescope.builtin")
	if not ok then
		return
	end

	ok = pcall(tbi.git_files)
	if not ok then
		tbi.find_files()
	end
end

local function temporarily_toggle_relativenumber()
	local win = vim.wo[vim.api.nvim_get_current_win()]
	local old = win.relativenumber
	win.relativenumber = not old
	local timer = vim.loop.new_timer()
	timer:start(
		2000,
		0,
		vim.schedule_wrap(function()
			win.relativenumber = old
		end)
	)
end

local mappings = {
	{
		{
			e = { ":NvimTreeToggle<CR>", "Explorer" },
			f = { find_git_files, "Find project files" },
			h = { ":noh<CR>", "Clear hilight" },
			l = {
				name = "Language Services",
				f = {
					function()
						vim.lsp.buf.format()
					end,
					"Format",
				},
			},
			r = { ":Telescope oldfiles<CR>", "Fine recent files" },
			s = {
				name = "Search",
				f = { find_git_files, "Find project files" },
				F = { ":Telescope find_files<CR>", "Files" },
				b = { ":Telescope buffers<CR>", "Buffer" },
				r = { ":Telescope oldfiles<CR>", "Recent files" },
			},
			R = { temporarily_toggle_relativenumber, "Quick toggle relative numbers" },
		},
		{ prefix = "<leader>" },
	},
}

return mappings
