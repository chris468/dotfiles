local ts = require("nvim-treesitter")
ts.setup({
    ensure_installed = { "lua", "vim", "python", "c_sharp" },
})
