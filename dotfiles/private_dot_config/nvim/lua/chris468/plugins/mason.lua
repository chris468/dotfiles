local function install_tool(pkg, callback)
  vim.notify("Installing " .. pkg.name .. "...")
  pkg:install():once("closed", function()
    if pkg:is_installed() then
      if callback then
        vim.schedule_wrap(callback)()
      end
      vim.notify("Successfully installed " .. pkg.name .. ".")
    else
      vim.notify("Failed to install " .. pkg.name .. ".", vim.log.levels.WARN)
    end
  end)
end

local function install_tools(tools)
  local registry = require("mason-registry")
  for _, tool in ipairs(tools) do
    local callback = false
    if type(tool) == "table" then
      callback = tool.callback or false
      tool = tool[1]
    end
    if not registry.is_installed(tool) then
      local pkg = registry.get_package(tool)
      if pkg then
        install_tool(pkg, callback)
      else
        vim.notify("Package " .. tool .. " not found", vim.log.levels.ERROR)
      end
    end
  end
end

local function hook_install(install_for_filetype)
  for category, filetype_tools in pairs(install_for_filetype) do
    for filetype, tools in pairs(filetype_tools) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        callback = function()
          vim.schedule_wrap(function(_)
            install_tools(tools)
          end)()
          return true
        end,
        desc = "Install " .. category .. " packages for " .. filetype,
      })
    end
  end
end

return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  config = function(_, opts)
    hook_install(opts.install_for_filetype)
    require("mason").setup(opts)
  end,
  dependencies = {
    { "folke/noice.nvim" },
  },
  keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
  lazy = false,
  opts = {
    -- map of category to (string | string, callback = function?)[]
    -- name of the mason package, callback after installation.
    install_for_filetype = {},
  },
  priority = 1100,
}
