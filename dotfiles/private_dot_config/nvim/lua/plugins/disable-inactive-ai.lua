-- Extras for any AI assistants I use will be enabled in LazyExtras
-- `Chris468.options.ai` selects the active assistant
-- Disable the plugins for the inactive assistants

local ai_plugins = {
  Codeium = { enabled = not Chris468.options.work, "codeium.nvim" },
  Copilot = { "copilot.lua", "copilot-cmp", "blink-cmp-copilot", "CopilotChat.nvim" },
}

local specs = {}

for ai, plugins in pairs(ai_plugins) do
  local enabled = Chris468.options.ai == ai and (plugins.enabled == nil or plugins.enabled)
  if not enabled then
    for _, plugin in ipairs(plugins) do
      table.insert(specs, { plugin, enabled = false })
    end
  end
end

return specs
