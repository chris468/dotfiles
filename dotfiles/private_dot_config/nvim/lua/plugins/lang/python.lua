local function search(dir)
  local script_path = vim.fn.stdpath("config") .. "/scripts/find-envs.sh"
  return ("bash %s %s"):format(script_path, dir)
end

return {
  {
    "venv-selector.nvim",
    opts = {
      options = { debug = true },
      settings = {
        search = {
          pipx = false,
          cwd = {
            command = search("$CWD"),
          },
          filed = {
            command = search("$FILE_DIR"),
          },
        },
      },
    },
  },
}
