local icons = require("chris468.config.icons")
local config = require("chris468.config")
local util = require("chris468.util")

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

local servers = (function()
  local s = {
    -- angularls = {},
    -- ansiblels = {},
    -- autotools_ls = {},
    bashls = {},
    -- clangd = {},
    -- cmake = {},
    -- cssls = {},
    -- docker_compose_language_service = {},
    -- dockerls = {},
    -- elixirls = {},
    -- erlangls = {},
    -- gopls = {},
    -- helm_ls = {},
    -- html = {},
    -- java_language_server = {},
    jsonls = {},
    -- lemminx = {}, -- xml
    lua_ls = {},
    -- mesonlsp = {},
    -- nil_ls = {}, -- nix
    -- powershell_es = {},
    pyright = {
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
    -- rust_analyzer = {},
    ruff = {}, -- python
    -- spectral = {}, -- OpenAPI
    -- taplo = {}, -- toml
    -- terraformls = {},
    -- tflint = {},
    -- tsserver = {},
    -- vimls = {},
    yamlls = {},
  }

  if util.contains(config.csharp_lsp, "omnisharp") then
    s.omnisharp = require("chris468.plugins.config.lsp.omnisharp")
  end
  if util.contains(config.csharp_lsp, "roslyn") then
    local roslyn = require("chris468.plugins.config.lsp.roslyn")
    require("lspconfig.configs").roslyn_lsp = roslyn.server
    s.roslyn_lsp = roslyn.lspconfig
  end

  return s
end)()

local signs = {
  [vim.diagnostic.severity.ERROR] = {
    icon = icons.diagnostic.error,
    hl = "DiagnosticError",
  },
  [vim.diagnostic.severity.WARN] = {
    icon = icons.diagnostic.warn,
    hl = "DiagnosticWarn",
  },
  [vim.diagnostic.severity.INFO] = {
    icon = icons.diagnostic.info,
    hl = "DiagnosticInfo",
  },
  [vim.diagnostic.severity.HINT] = {
    icon = icons.diagnostic.hint,
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

  if util.contains(config.csharp_lsp, "roslyn") then
    install_for_filetype.cs = install_for_filetype.cs or {}
    install_for_filetype.cs[#install_for_filetype.cs + 1] = "chris468_roslyn_lsp"
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

local function configure_diagnostics()
  vim.diagnostic.config({
    signs = {
      severity = { min = vim.diagnostic.severity.WARN },
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostic.error,
        [vim.diagnostic.severity.WARN] = icons.diagnostic.warn,
        [vim.diagnostic.severity.INFO] = icons.diagnostic.info,
        [vim.diagnostic.severity.HINT] = icons.diagnostic.hint,
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
end

return {
  "neovim/nvim-lspconfig",
  config = function(_, opts)
    configure_diagnostics()
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
          [vim.diagnostic.severity.ERROR] = icons.diagnostic.error,
          [vim.diagnostic.severity.WARN] = icons.diagnostic.warn,
          [vim.diagnostic.severity.INFO] = icons.diagnostic.info,
          [vim.diagnostic.severity.HINT] = icons.diagnostic.hint,
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
    { "nvim-lua/plenary.nvim" },
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
    { "folke/lazydev.nvim" },
    { "smjonas/inc-rename.nvim", opts = {} },
    {
      "folke/trouble.nvim",
      cmd = { "Trouble" },
      keys = {
        { "<leader>cd", open_document_diagnostics, desc = "Document diagnostics" },
        { "<leader>cD", open_workspace_diagnostics, desc = "Workspace diagnostics" },
        { "<leader>cx", "<cmd>Trouble close<cr>", desc = "Close trouble" },
      },
      lazy = true,
      opts = {
        auto_jump = true,
        focus = true,
        follow = false,
        icons = {
          folder_closed = icons.file.folder_closed,
          folder_open = icons.file.folder_open,
          kinds = icons.kinds,
        },
      },
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
