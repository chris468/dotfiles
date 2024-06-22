local icons = require("chris468.config.icons")
local lang = require("chris468.config.lang")
local util = require("chris468.util")

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

--- @param capabilities table
local function register_lsp(capabilities)
  --- @param tool chris468.util.mason.Tool
  return function(tool)
    local name = tool.data.name
    local lsp = tool.data.lsp --[[ @type chris468.config.lang.Lsp ]]

    if lsp.register_server then
      require("lspconfig.configs")[name] = util.value_or_result(lsp.register_server)
    end

    local config = util.value_or_result(lsp.config, {}) --[[ @as table ]]
    config = vim.tbl_deep_extend("error", config, { capabilities = capabilities })
    require("lspconfig")[name].setup(config)
    vim.cmd("LspStart " .. name)
  end
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

    --- @param server string
    --- @return chris468.config.lang.Lsp?
    local function to_lsp(server)
      return lang.lsp[server] or nil
    end

    --- @param server string
    --- @return chris468.util.mason.Tool?
    local function to_tool(server)
      local lsp = to_lsp(server)
      if not lsp then
        return nil
      end

      local mappings = require("mason-lspconfig.mappings.server").lspconfig_to_package
      local tool = {
        package_name = lsp.package_name or mappings[server] or server,
        on_complete = register_lsp(opts.capabilities),
        data = {
          name = server,
          lsp = lsp,
        },
      }

      return tool
    end

    --- @param servers string[]
    --- @return (chris468.util.mason.Tool[])?
    local function to_tools(servers)
      local tools = nil
      for _, server in ipairs(servers) do
        local tool = to_tool(server)
        if tool then
          tools = tools or {}
          tools[#tools + 1] = tool
        end
      end

      return tools
    end

    --- @return { [string]: string[] }
    local function filetypes_from_lang_config()
      --- @type { [string]: string[] }
      local result = {}
      for server, lsp in pairs(lang.lsp) do
        if lsp then
          local filetypes = util.value_or_result(lsp.config, {}).filetypes
            or util.value_or_result(lsp.register_server, { default_config = {} }).default_config.filetypes
            or {}

          for _, filetype in ipairs(filetypes) do
            result[filetype] = result[filetype] or {}
            table.insert(result[filetype], server)
          end
        end
      end

      return result
    end

    local filetype_to_servers =
      util.merge_flatten(require("mason-lspconfig.mappings.filetype"), filetypes_from_lang_config())
    local filetype_to_tools = vim.tbl_map(to_tools, filetype_to_servers)
    util.mason.lazy_install_for_filetype(filetype_to_tools, "install and configure lsp")
  end,
  event = "FileType",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "williamboman/mason.nvim" },
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
  },
}
