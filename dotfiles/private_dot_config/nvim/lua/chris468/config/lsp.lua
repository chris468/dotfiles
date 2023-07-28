return function(capabilities)
	return {
		lua_ls = {
			capabilities = capabilities,
			settings = {
				Lua = {
					workspace = {
						checkThirdParty = false,
					},
				},
			},
		},
	}
end
