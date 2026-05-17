---@type Options
local opts = {
	mainMod = "ALT",
	apps = {
		terminal = "alacritty",
		fileManager = "thunar",
		menu = "rofi -show run",
	},
}

require("bindings")(opts)
require("devices")(opts)
require("visual")(opts)
require("startup")(opts)
require("rules")(opts)
