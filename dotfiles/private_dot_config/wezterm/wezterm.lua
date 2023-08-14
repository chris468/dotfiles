local wezterm = require("wezterm")
local config = wezterm.config_builder()
local settings = require("chris468.settings")

config.color_scheme = "nord"
require("chris468.tab_colors")(config)

config.font = wezterm.font(settings.font.family)
config.font_size = settings.font.size

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.native_macos_fullscreen_mode = true
require("chris468.hide_tabs_in_full_screen")

config.default_cwd = settings.homeDir

if settings.os == "windows" then
	config.default_prog = { "pwsh.exe" }
end

return config
