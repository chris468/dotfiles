local wezterm = require("wezterm")
local config = wezterm.config_builder()
local settings = require("chris468.settings")

require("chris468.theme." .. settings.theme)(config)

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

config.ssh_domains = settings.ssh_domains

config.initial_cols = 120
config.initial_rows = 40

config.disable_default_key_bindings = true
config.keys = {
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "SHIFT|CTRL", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "Enter", mods = "ALT", action = wezterm.action.ToggleFullScreen },
	{ key = "=", mods = "SHIFT|CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "SHIFT|CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = ")", mods = "SHIFT|CTRL", action = wezterm.action.ResetFontSize },
	{ key = "c", mods = "SHIFT|CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "c", mods = "SUPER", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "n", mods = "SHIFT|CTRL", action = wezterm.action.SpawnWindow },
	{ key = "n", mods = "SUPER", action = wezterm.action.SpawnWindow },
	{ key = "t", mods = "SHIFT|CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "SUPER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "v", mods = "SHIFT|CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "w", mods = "SHIFT|CTRL", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "w", mods = "SUPER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "p", mods = "SUPER|SHIFT", action = wezterm.action.ActivateCommandPalette },
	{ key = "p", mods = "SHIFT|CTRL", action = wezterm.action.ActivateCommandPalette },
	{ key = "d", mods = "SUPER|SHIFT", action = wezterm.action.ShowDebugOverlay },
	{ key = "d", mods = "SHIFT|CTRL", action = wezterm.action.ShowDebugOverlay },
}
config.term = "wezterm"
return config
