local lspconfig = require("lspconfig")

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "pyright",
        "lua_ls",
        "omnisharp",
        "bashls",
        "jsonls",
        "yamlls",
    },
})

local function with_capabilities(settings)
    local s = require("chris468.util.if-ext")("cmp_nvim_lsp", function(cmp_nvim_lsp)
        return { capabilities = cmp_nvim_lsp.default_capabilities() }
    end, function()
        return {}
    end)

    for k, v in pairs(settings) do
        s[k] = v
    end

    return s
end

mason_lspconfig.setup_handlers({
    function(server_name)
        local present, settings = pcall(require, "chris468.lsp.servers." .. server_name)
        settings = present and settings or {}
        lspconfig[server_name].setup(with_capabilities(settings))
    end,
})
