local add_neotest_adapters = require("chris468/plugins/config/neotest").add_neotest_adapters

local function go_enabled()
  local have_go = vim.fn.executable("go") == 1
  if have_go then
    return true
  end
  return false, "go not found in path"
end

return {
  {
    "chris468-tools",
    opts = {
      lsps = { gopls = {} },
      formatters = {
        goimports = { filetypes = { "go" }, enabled = go_enabled },
        gofumpt = { filetypes = { "go" }, enabled = go_enabled },
      },
      daps = {
        delve = { enabled = go_enabled },
      },
    },
  },
  {
    "neotest",
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      add_neotest_adapters(opts, {
        require("neotest-golang")({}),
      })
    end,
  },
}
