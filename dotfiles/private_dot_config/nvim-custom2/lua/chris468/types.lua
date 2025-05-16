---@alias chris468.config.CheckPrequisite fun(): boolean, string

---@class chris468.config.ToolSpec
---@field [1] string package name
---@field prerequisite? chris468.config.CheckPrequisite

---@class chris468.config.FormatterSpec: chris468.config.ToolSpec
---@field format_on_save? boolean

---@alias chris468.config.ToolsByFiletype { [string]: string[]|chris468.config.ToolSpec[] }
---@alias chris468.config.FormattersByFiletype { [string]: string[]|chris468.config.FormatterSpec[] }
---@alias chris468.config.Lsps  table<string, { config: vim.lsp.Config, prerequisite?: chris468.config.CheckPrequisite }>
