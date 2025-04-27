function PLUGIN:PreInstall(ctx)
	local version = ctx.version
	for _, release in ipairs(require("releases")) do
		if version == release.version then
			return release
		end
	end

	return {}
end
