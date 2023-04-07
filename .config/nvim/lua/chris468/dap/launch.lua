local M = { defaults = {} }
local need_prompt = true

local function find_defaults(dap)
  local defaults = {}
  local default_configs = {}
  local filetype_to_default = {}
  for filetype, configs in pairs(dap.configurations) do
    for _, config in ipairs(configs) do
      if config.default then
        if not filetype_to_default[filetype] then
          filetype_to_default[filetype] = config
        end
        if not defaults[config] then
          default_configs[#default_configs + 1] = config
          defaults[config] = true
        end
      end
    end
  end

  local new_defaults = { filetype_to_default=filetype_to_default }
  if #default_configs == 1 then
    new_defaults.single_default = default_configs[1]
  end
  M.defaults = new_defaults
end

function M.load_configs(dap, reset)
  local if_ext = require 'chris468.util.if-ext'
  local mappings = {}
  if_ext('mason-nvim-dap.mappings.filetypes', function(e)
    mappings = e.adapter_to_configs
  end)
  require('dap.ext.vscode').load_launchjs(nil, mappings)
end

local function select_default(dap)
  M.load_configs(dap)
  find_defaults(dap)
  if M.defaults.single_default then
    return M.defaults.single_default
  end

  return M.defaults.filetype_to_default[vim.bo.filetype]
end

function M.prompt(dap)
  need_prompt = false
  M.load_configs(dap)
  dap.continue()
end

function M.prompt_or_continue(dap)
  if dap.session() then
    dap.continue()
  else
    M.prompt(dap)
  end
end

function M.launch_or_continue(dap)
  if dap.session() then
    dap.continue()
  else
    local default = select_default(dap)
    if default then
      dap.run(default)
    else
      if need_prompt then
        M.prompt(dap)
      else
        dap.run_last()
      end
    end
  end
end

return M
