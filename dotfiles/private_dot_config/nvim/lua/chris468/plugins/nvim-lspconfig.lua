local icons = require("chris468.config.icons")

local servers = {
  angularls = {},
  ansiblels = {},
  autotools_ls = {},
  bashls = {},
  clangd = {},
  cmake = {},
  cssls = {},
  docker_compose_language_service = {},
  dockerls = {},
  elixirls = {},
  erlangls = {},
  gopls = {},
  helm_ls = {},
  html = {},
  java_language_server = {},
  jsonls = {},
  lemminx = {}, -- xml
  lua_ls = {},
  mesonlsp = {},
  nil_ls = {}, -- nix
  omnisharp = {
    cmd = { "omnisharp" },
  },
  powershell_es = {},
  pyright = {},
  ruff = {}, -- python
  spectral = {}, -- OpenAPI
  taplo = {}, -- toml
  terraformls = {},
  tflint = {},
  tsserver = {},
  vimls = {},
  yamlls = {},
  codeqlls = {},
}

local function servers_for_filetypes()
  local server_to_package = require("mason-lspconfig").get_mappings().lspconfig_to_mason
  local filetype_to_servers = require("mason-lspconfig.mappings.filetype")

  local install_for_filetype = {}

  for filetype, filetype_servers in pairs(filetype_to_servers) do
    local s = {}
    for _, server in ipairs(filetype_servers) do
      local p = servers[server] and server_to_package[server] or false
      if p then
        s[#s + 1] = {
          p,
          callback = function()
            require("lspconfig")[server].setup(servers[server])
          end,
        }
      end
    end

    if #s > 0 then
      install_for_filetype[filetype] = s
    end
  end

  return install_for_filetype
end

local function to_server_config(server, opts, capabilities)
  if type(server) == "string" then
    if type(opts) == "table" then
      return server, vim.tbl_deep_extend("force", opts, capabilities)
    elseif type(opts) == "function" then
      return server, opts(capabilities)
    end
  end

  vim.notify("Invalid lsp server configuration: " .. vim.inspect({ [server] = opts }), vim.log.levels.ERROR)
end

return {
  "neovim/nvim-lspconfig",
  config = function(_, opts)
    local lspconfig = require("lspconfig")

    -- lspconfig.util.on_setup = lspconfig.util.add_hook_before(lspconfig.util.on_setup, hook_install_lsp)

    for k, v in pairs(opts.servers) do
      local server, config = to_server_config(k, v, opts.capabilities)
      if server and config then
        lspconfig[server].setup(config)
      end
    end

    for severity, sign in pairs(opts.signs) do
      vim.fn.sign_define("DiagnosticSign" .. severity, { text = sign, texthl = "Diagnostic" .. severity, numhl = "" })
    end
  end,
  dependencies = {
    { "williamboman/mason-lspconfig.nvim" },
    {
      "williamboman/mason.nvim",
      dependencies = { "williamboman/mason-lspconfig.nvim" },
      opts = function(_, opts)
        local r = opts.install_for_filetype or {}
        r.lsp = servers_for_filetypes()
        opts.install_for_filetype = r
      end,
    },
    { "folke/noice.nvim" },
    {
      "folke/neodev.nvim",
      opts = {
        override = function(root_dir, library)
          if root_dir:find("config/nvim") then
            library.enabled = true
          end
        end,
      },
    },
  },
  keys = {
    { "<leader>cil", "<cmd>LspInfo<cr>", desc = "Language server" },
  },
  lazy = false,
  opts = {
    capabilities = {},
    servers = servers,
    signs = {
      Error = icons.error,
      Warn = icons.warn,
      Hint = icons.hint,
      Info = icons.info,
    },
  },
}