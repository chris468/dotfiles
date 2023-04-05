local M = { defaults = {_keys = {}} }
local need_prompt = true

local function find_defaults(dap)
  local new_defaults = {_keys = {}}
  for filetype, configs in pairs(dap.configurations) do
    for _, config in ipairs(configs) do
      if config.default then
        new_defaults[filetype] = config
        new_defaults._keys[#new_defaults._keys + 1] = {filetype=filetype, config=config}
        break
      end
    end
  end
  M.defaults = new_defaults
  print(vim.inspect(M.defaults))
end

function M.load_configs(dap, reset)
  if reset then need_prompt = true print ('lc reset prompt') end
  require('dap.ext.vscode').load_launchjs()
  find_defaults(dap)
end

local function select_default(dap)
  M.load_configs(dap)
  find_defaults(dap)
  if #M.defaults._keys == 1 then
    return M.defaults._keys[1].config
  end

  local ft = vim.bo.filetype
  return M.defaults[ft]
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
  print('loc', need_prompt)
  if dap.session() then
    print('cont')
    dap.continue()
  else
    local default = select_default(dap)
    if default then
      print('default', vim.inspect(default))
      dap.run(default)
    else
      if need_prompt then
        print('prompt')
        M.prompt(dap)
      else
        print('run last')
        dap.run_last()
      end
    end
  end
end

return M
