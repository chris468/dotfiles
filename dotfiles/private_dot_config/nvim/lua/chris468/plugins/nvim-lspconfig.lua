local icons = require("chris468.config.icons").diagnostic

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
  omnisharp = require("chris468.plugins.config.lsp.omnisharp"),
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

local signs = {
  [vim.diagnostic.severity.ERROR] = {
    icon = icons.error,
    hl = "DiagnosticError",
  },
  [vim.diagnostic.severity.WARN] = {
    icon = icons.warn,
    hl = "DiagnosticWarn",
  },
  [vim.diagnostic.severity.INFO] = {
    icon = icons.info,
    hl = "DiagnosticInfo",
  },
  [vim.diagnostic.severity.HINT] = {
    icon = icons.hint,
    hl = "DiagnosticHint",
  },
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

local function to_server_config(server, config, capabilities)
  if type(server) == "string" then
    if type(config) == "table" then
      if config.capabilities or capabilities then
        config = vim.deepcopy(config)
        config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities or {})
      end
      return server, config
    elseif type(config) == "function" then
      return server, config(capabilities)
    end
  end

  vim.notify("Invalid lsp server configuration: " .. vim.inspect({ [server] = config }), vim.log.levels.ERROR)
end

local function _open_diagnotics(for_document)
  local trouble = require("trouble")
  local opts = {
    mode = "diagnostics",
    filter = {
      severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
    },
  }
  if for_document then
    opts.filter.buf = 0
  end

  if trouble.is_open(opts) then
    trouble.close(opts)
  end

  trouble.open(opts)
end

local function open_workspace_diagnostics()
  _open_diagnotics()
end

local function open_document_diagnostics()
  _open_diagnotics(true)
end

return {
  "neovim/nvim-lspconfig",
  config = function(_, opts)
    local lspconfig = require("lspconfig")

    for k, v in pairs(opts.servers) do
      local server, config = to_server_config(k, v, opts.capabilities)
      if server and config then
        lspconfig[server].setup(config)
      end
    end

    vim.diagnostic.config({
      signs = {
        severity = { min = vim.diagnostic.severity.WARN },
        text = {
          [vim.diagnostic.severity.ERROR] = icons.error,
          [vim.diagnostic.severity.WARN] = icons.warn,
          [vim.diagnostic.severity.INFO] = icons.info,
          [vim.diagnostic.severity.HINT] = icons.hint,
        },
        numhl = {
          [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
      },
      float = {
        border = "rounded",
        header = "",
        prefix = function(diagnostic, _, _)
          local sign = signs[diagnostic.severity]
          return " " .. sign.icon .. " ", sign.hl
        end,
        source = true,
        suffix = function(diagnostic, _, _)
          local suffix = ""
          if diagnostic.code then
            suffix = " [" .. diagnostic.code .. "]"
          end

          return suffix, signs[diagnostic.severity].hl
        end,
        severity_sort = true,
      },
      update_in_insert = true,
      severity_sort = true,
      virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
    })
  end,
  event = "FileType",
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
          if root_dir:find("config/*vim") or root_dir:find("/tmp/luapad.") then
            library.enabled = true
          end
        end,
      },
    },
    { "smjonas/inc-rename.nvim", opts = {} },
    {
      "folke/trouble.nvim",
      cmd = { "Trouble" },
      config = true,
      keys = {
        { "<leader>cd", open_document_diagnostics, desc = "Document diagnostics" },
        { "<leader>cD", open_workspace_diagnostics, desc = "Workspace diagnostics" },
        { "<leader>cx", "<cmd>Trouble close<cr>", desc = "Close trouble" },
      },
      lazy = true,
    },
  },
  keys = {
    { "<leader>cIl", "<cmd>LspInfo<cr>", desc = "Language server" },
    { "<leader>cl", vim.diagnostic.open_float, desc = "Line diagnostics" },
  },
  opts = {
    capabilities = {},
    servers = servers,
  },
}
