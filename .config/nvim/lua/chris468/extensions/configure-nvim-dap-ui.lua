local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

for _, close_event in pairs({ "event_terminated", "event_exited" }) do
    dap.listeners.before[close_event]["dapui_config"] = function()
        dapui.close()
    end
end
