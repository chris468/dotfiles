local wezterm = require("wezterm")

local function hide_single_tab_in_full_screen(window, _)
	local window_dims = window:get_dimensions()
	local overrides = window:get_config_overrides() or {}

	if not window_dims.is_full_screen ~= overrides.enable_tab_bar then
		overrides.enable_tab_bar = not window_dims.is_full_screen
		window:set_config_overrides(overrides)
	end
end

wezterm.on("window-resized", hide_single_tab_in_full_screen)
wezterm.on("window-config-reloaded", hide_single_tab_in_full_screen)
