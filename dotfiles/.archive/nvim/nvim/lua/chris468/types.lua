---@alias chris468.config.ShouldInstallTool boolean|fun(): boolean, string

---@class chris468.config.ToolSpec
---@field [1] string name
---@field package? string package name (if different from name)
---@field install? chris468.config.ShouldInstallTool

---@class chris468.config.FormatterSpec: chris468.config.ToolSpec
---@field format_on_save? boolean

---@alias chris468.config.ToolsByFiletype { [string]: string[]|chris468.config.ToolSpec[] }
---@alias chris468.config.FormattersByFiletype { [string]: string[]|chris468.config.FormatterSpec[] }
---@alias chris468.config.Lsps  table<string, { config: vim.lsp.Config|fun(): vim.lsp.Config, install?: chris468.config.ShouldInstallTool }>
