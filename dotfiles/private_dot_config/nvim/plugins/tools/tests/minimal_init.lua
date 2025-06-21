vim.opt.runtimepath:prepend(".")
vim.cmd.runtime("plugin/plenary.vim")
vim.cmd.nnoremap([[,,x :luafile %<CR>]])
