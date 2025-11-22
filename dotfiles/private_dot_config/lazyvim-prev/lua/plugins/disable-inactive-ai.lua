-- Extras for any AI assistants I use will be enabled in LazyExtras
-- `Chris468.options.ai` selects the active assistant
-- Disable the plugins for the inactive assistants

--- @class AIPluginSpec
--- @field enabled? boolean
--- @field plugins? string[]
--- @field blink? string[]

--- @type {[string]: AIPluginSpec}
local ai_plugins = {
  Codeium = {
    enabled = not require("config.chezmoi").work,
    plugins = { "codeium.nvim" },
    blink = { "codeium" },
  },
  Copilot = {
    plugins = { "copilot.lua", "copilot-cmp", "blink-cmp-copilot", "CopilotChat.nvim" },
    blink = { "copilot" },
  },
}

--- @param callback fun(spec: AIPluginSpec)
local function foreach_disabled_ai_plugin(callback)
  for ai, spec in pairs(ai_plugins) do
    local enabled = Chris468.options.ai == ai and (spec.enabled == nil or spec.enabled)
    if not enabled then
      callback(spec)
    end
  end
end

local specs = {
  {
    "blink.cmp",
    optional = true,
    opts = function(_, opts)
      foreach_disabled_ai_plugin(function(spec)
        for _, provider in ipairs(spec.blink) do
          opts.sources.providers[provider] = nil
        end

        local function filter(tbl)
          return tbl
              and vim.tbl_filter(function(v)
                return not vim.list_contains(spec.blink, v)
              end, tbl)
            or nil
        end

        opts.sources.default = filter(opts.sources.default)
        opts.sources.compat = filter(opts.sources.compat)
        opts.cmdline.sources = filter(opts.cmdline.sources)
      end)
    end,
  },
}

foreach_disabled_ai_plugin(function(spec)
  for _, plugin in ipairs(spec.plugins or {}) do
    table.insert(specs, { plugin, enabled = false })
  end
end)

return specs
