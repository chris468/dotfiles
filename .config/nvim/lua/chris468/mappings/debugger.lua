return function(dap)
  local first = true
  local defaults = {_keys = {}}

  local function find_defaults()
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
    print('new defaults', vim.inspect(new_defaults))
    defaults = new_defaults
  end

  local function load_configs()
    require('dap.ext.vscode').load_launchjs()
    find_defaults()
  end

  local function select_default()
    load_configs()
    find_defaults()
    if #defaults._keys == 1 then
      return defaults._keys[1].config
    end

    local ft = vim.bo.filetype
    return defaults[ft]
  end

  local function prompt()
    first = false
    load_configs()
    dap.continue()
  end

  local function prompt_or_continue()
    if dap.session() then
      dap.continue()
    else
      prompt()
    end
  end

  local function launch_or_continue()
    if dap.session() then
      dap.continue()
    else
      local default = select_default()
      if default then
        dap.run(default)
      else
        if first then
          prompt()
        else
          dap.run_last()
        end
      end
    end
  end

  return {
    prompt = prompt,
    prompt_or_continue = prompt_or_continue,
    launch_or_continue = launch_or_continue,
  }
end
