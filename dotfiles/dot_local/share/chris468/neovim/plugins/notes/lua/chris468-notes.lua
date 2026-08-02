local config = require("chris468-notes.config")
local M = {}

local group = vim.api.nvim_create_augroup("chris468-notes", { clear = true })

local function sync_notes_on_first_enter()
	if not config.opts.sync_command then
		return
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function()
			if
				vim.startswith(vim.fn.getcwd(), config.opts.path)
				or vim.startswith(vim.api.nvim_buf_get_name(0), config.opts.path)
			then
				vim.notify("Syncing notes...", vim.log.levels.INFO, { title = "chris468-notes" })
				local ok, err = pcall(vim.system, { config.opts.sync_command }, function(out)
					if out.code == 0 then
						vim.notify("Finished syncing notes.", vim.log.levels.INFO, { title = "chris468-notes" })
					else
						vim.notify("Failed to sync notes.", vim.log.levels.ERROR, { title = "chris468-notes" })
					end
				end)
				if not ok then
					vim.notify("Failed to sync notes: " .. err, vim.log.levels.ERROR, { title = "chris468-notes" })
				end
				return true
			end
		end,
	})
end

function M.setup(opts)
	config.setup(opts)
	sync_notes_on_first_enter()
end

return M
