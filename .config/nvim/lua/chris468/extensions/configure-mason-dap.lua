local require_all = require("chris468.util.require-all")

local mason_nvim_dap = require("mason-nvim-dap")

local default_handler = {
    function(source_name)
        require("mason-nvim-dap.automatic_setup")(source_name)
    end,
}
local custom_handlers = require_all("chris468.dap.adapters")
local handlers = vim.tbl_extend("error", default_handler, custom_handlers)

mason_nvim_dap.setup({
    ensure_installed = {
        "python",
        "coreclr",
        "bash",
    },
    automatic_setup = true,
    handlers = handlers,
})
