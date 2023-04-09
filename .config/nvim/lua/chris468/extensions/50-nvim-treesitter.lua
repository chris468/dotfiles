require("chris468.util.if-ext")("nvim-treesitter", function(ts)
    ts.setup({
        ensure_installed = { "lua", "vim", "python", "c_sharp" },
    })
end)
