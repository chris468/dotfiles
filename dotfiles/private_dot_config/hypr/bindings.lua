---@param mods Modifier|Modifier[]
---@param key string
local function keys(mods, key)
	if type(mods) == "string" then
		mods = { mods }
	end
	return table.concat(mods, " + ") .. " + " .. key
end

local M = {}

---@param opts Options
function M.setup(opts)
	hl.bind(keys(opts.mainMod, "Return"), hl.dsp.exec_cmd(opts.apps.terminal))
	hl.bind(keys(opts.mainMod, "Q"), hl.dsp.window.close())
	hl.bind(keys({ opts.mainMod, "SHIFT" }, "E"), hl.dsp.exit())
	hl.bind(keys(opts.mainMod, "E"), hl.dsp.exec_cmd(opts.apps.fileManager))
	hl.bind(keys(opts.mainMod, "V"), hl.dsp.window.float({ action = "toggle" }))
	hl.bind(keys(opts.mainMod, "d"), hl.dsp.exec_cmd(opts.apps.menu))
	hl.bind(keys(opts.mainMod, "P"), hl.dsp.window.pseudo())
	hl.bind(keys(opts.mainMod, "J"), hl.dsp.layout("togglesplit"))
	hl.bind(keys({ opts.mainMod, "CONTROL", "SHIFT" }, "W"), hl.dsp.exec_cmd("killall waybar ; waybar"))

	hl.bind(keys(opts.mainMod, "left"), hl.dsp.focus({ direction = "left" }))
	hl.bind(keys(opts.mainMod, "right"), hl.dsp.focus({ direction = "right" }))
	hl.bind(keys(opts.mainMod, "up"), hl.dsp.focus({ direction = "up" }))
	hl.bind(keys(opts.mainMod, "down"), hl.dsp.focus({ direction = "down" }))

	for i = 1, 10 do
		local key = tostring(i % 10)
		hl.bind(keys(opts.mainMod, key), hl.dsp.focus({ workspace = i }))
		hl.bind(keys({ opts.mainMod, "SHIFT" }, key), hl.dsp.window.move({ workspace = i }))
	end

	hl.bind(keys(opts.mainMod, "S"), hl.dsp.workspace.toggle_special("magic"))
	hl.bind(keys({ opts.mainMod, "SHIFT" }, "S"), hl.dsp.window.move({ workspace = "special:magic" }))

	hl.bind(keys(opts.mainMod, "mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(keys(opts.mainMod, "mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

	hl.bind(keys(opts.mainMod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
	hl.bind(keys(opts.mainMod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })
end

return setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})
