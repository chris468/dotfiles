local function detect_venv(root_dir)
  local Job = require("plenary.job")
  local python = vim.loop.os_uname().sysname == "Windows_NT" and "python.exe" or "python"
  local dot_venv_python = root_dir .. "/.venv/bin/" .. python
  if vim.fn.filereadable(dot_venv_python) == 1 then
    return dot_venv_python
  end

  local pyproject = root_dir .. "/pyproject.toml"
  if vim.fn.executable("poetry") == 1 and vim.fn.filereadable(pyproject) == 1 then
    local ok, venv = pcall(function()
      return Job:new({
        command = "poetry",
        cwd = root_dir,
        args = { "env", "info", "-p" },
      })
        :sync()[1]
    end)
    if ok then
      return venv .. "/bin/" .. python
    end
  end

  return false
end

return {
  config = {
    on_new_config = function(new_config, new_root_dir)
      local defaults = require("lspconfig.server_configurations.pyright")
      if defaults.on_new_config then
        defaults.on_new_config(new_config, new_root_dir)
      end

      local venv_python = detect_venv(new_root_dir)
      if venv_python then
        new_config.settings.python.pythonPath = venv_python
      end
    end,
  },
}
