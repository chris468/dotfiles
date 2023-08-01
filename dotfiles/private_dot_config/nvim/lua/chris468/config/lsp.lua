local M = {}

-- map of language server name to configuration
-- optional ensure_installed boolean property controls whether the server will
-- be automatically installed by mason-lspconfig, default true.
-- optional post_install function property will be called after successful install
-- of the lsp, with a single parameter the path to the installation location. Both
-- the package name and spec.bin keys are checked so tht, for example, pylsp will match
-- even though the package name is python-lsp-server.
-- Everything else is passed to the lspconfig server configuration.
M.servers = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					checkThirdParty = false,
				},
			},
		},
	},
	pylsp = {
		settings = {
			pylsp = {
				plugins = {
					autopep8 = { enabled = false },
					pycodestyle = { enabled = false },
					yapf = { enabled = false },
					black = { enabled = true },
				},
			},
		},
		post_install = function(package_path)
			local venv = package_path .. "/venv"
			local job = require("plenary.job")
			job:new({
				command = venv .. "/bin/pip",
				args = {
					"install",
					"--upgrade",
					"--disable-pip-version-check",
					"python-lsp-black",
				},
				cwd = venv,
				env = {
					VIRTUAL_ENV = virtual_env,
				},
				on_start = function()
					vim.schedule(function()
						vim.notify(
							"installing python-lsp-black plugin",
							vim.log.levels.INFO,
							{ title = "pylsp post_install" }
						)
					end)
				end,
				on_exit = function(_, return_value)
					vim.schedule(function()
						if return_value == 0 then
							vim.notify(
								"python-lsp-black was successfully installed",
								vim.log.levels.INFO,
								{ title = "pylsp post_install" }
							)
						else
							vim.notify(
								"python-lsp-black install failed with return code "
								.. return_value
								.. ". Retry with :PylspInstall",
								vim.log.levels.ERROR,
								{ title = "pylsp post_install" }
							)
						end
					end)
				end,
			}):start()
		end,
	},
}

M.mason_lsp = {
	ensure_installed = {},
}

M.post_install = {}

local ensure_installed = M.mason_lsp.ensure_installed
for k, v in pairs(M.servers) do
	if v.ensure_installed == nil or v.ensure_installed then
		ensure_installed[#ensure_installed + 1] = k
		v.ensure_installed = nil
	end

	if v.post_install then
		M.post_install[k] = v.post_install
		v.post_install = nil
	end
end

return M
