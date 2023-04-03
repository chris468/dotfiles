return function(dap)
  local first = true

  local function prompt()
    first = false
    require('dap.ext.vscode').load_launchjs()
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
      if first then
        prompt()
      else
        dap.run_last()
      end
    end
  end

  return {
    prompt = prompt,
    prompt_or_continue = prompt_or_continue,
    launch_or_continue = launch_or_continue,
  }
end
