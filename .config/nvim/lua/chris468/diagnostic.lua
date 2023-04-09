local symbols = require("chris468.util.symbols")

local signs = {
    DiagnosticSignWarn = {
        text = symbols.warning,
    },
    DiagnosticSignInfo = {
        text = symbols.info,
    },
    DiagnosticSignHint = {
        text = symbols.hint,
    },
    DiagnosticSignError = {
        text = symbols.error,
    },
}

local original_handler = vim.diagnostic.handlers.signs

vim.diagnostic.handlers.signs = {
    show = function(n, b, d, o)
        original_handler.show(n, b, d, o)
        vim.diagnostic.handlers.signs = original_handler

        for name, config in pairs(signs) do
            vim.fn.sign_define(name, config)
        end
    end,
    hide = original_handler.hide,
}

local function update(always, buf)
    if #vim.lsp.get_active_clients({ bufnr = buf }) == 0 then
        return
    end

    local wid = vim.fn.bufwinid(buf)
    local wst = vim.w[wid]
    if always or wst._chris468_diag_loc_buf ~= buf then
        vim.diagnostic.setloclist({ winnr = wid, open = false })
        wst._chris468_diag_loc_buf = buf
    end
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function create_chris468_diagnostic_buffer_augroup(args)
    update(false, args.buf)
    local group = augroup("chris468_diagnostic_buffer", { clear = true })
    autocmd("CursorHold", {
        group = group,
        buffer = 0,
        callback = vim.diagnostic.open_float,
    })
    autocmd({ "BufEnter", "BufWinEnter", "DiagnosticChanged" }, {
        group = group,
        buffer = 0,
        callback = function(a)
            update(a.event == "DiagnosticChanged", a.buf)
        end,
    })
end

autocmd({ "BufWinEnter", "BufEnter", "LspAttach" }, {
    group = augroup("chris468_diagnostic", { clear = true }),
    callback = create_chris468_diagnostic_buffer_augroup,
})
