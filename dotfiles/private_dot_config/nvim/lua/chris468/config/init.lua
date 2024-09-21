--- @alias chris468CsharpLsp
--- | '"roslyn"'
--- | '"omnisharp"'

--- @class chris468Config
--- @field enable_noice boolean
--- @field csharp_lsp chris468CsharpLsp | chris468CsharpLsp[]

--- @type chris468Config
local default_config = {
  enable_noice = true,
  csharp_lsp = "roslyn",
}

--- @type boolean, fun(config: chris468Config) : chris468Config
local ok, local_config = pcall(require, "chris468.config.local", default_config)

return ok and local_config(default_config) or default_config
