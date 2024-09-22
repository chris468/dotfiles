local settings = require("chris468.config.settings")

--- @alias chris468CsharpLsp
--- | '"roslyn"'
--- | '"omnisharp"'

--- @alias chris468AIAssistant "copilot"|"codeium"

--- @class chris468Config
--- @field enable_noice boolean
--- @field csharp_lsp chris468CsharpLsp | chris468CsharpLsp[]
--- @field ai_assistants chris468AIAssistant | chris468AIAssistant[] | false

--- @type chris468Config
local default_config = {
  enable_noice = true,
  csharp_lsp = "roslyn",
  ai_assistants = false,
}

--- @type table<chris468AIAssistant, boolean>
local ai_assistant_enabled = {
  codeium = not settings.work,
}

--- @param ai_assistants chris468AIAssistant[] | chris468AIAssistant | false
--- @return chris468AIAssistant[]
local function filter_ai_assistants(ai_assistants)
  if type(ai_assistants) == "string" then
    ai_assistants = { ai_assistants }
  elseif type(ai_assistants) ~= "table" then
    ai_assistants = {}
  end

  return vim.tbl_filter(function(assistant)
    local allowed = ai_assistant_enabled[assistant] == nil or ai_assistant_enabled[assistant]
    if not allowed then
      vim.schedule_wrap(function()
        vim.notify(assistant .. " disabled", vim.log.levels.WARN)
      end)()
    end

    return allowed
  end, ai_assistants)
end

--- @type boolean, fun(config: chris468Config) : chris468Config
local ok, local_config = pcall(require, "chris468.config.local", default_config)

local config = ok and local_config(default_config) or default_config
config.ai_assistants = filter_ai_assistants(config.ai_assistants)

local M = {}

--- @param ai_assistant string
--- @return boolean
function M.is_ai_assistant_enabled(ai_assistant)
  return vim.tbl_contains(config.ai_assistants, ai_assistant)
end

return vim.tbl_extend("error", config, M)
