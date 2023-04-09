return function(augroups)
    for name, cmds in pairs(augroups) do
        local id = vim.api.nvim_create_augroup(name, {})
        for _, cmd in ipairs(cmds) do
            cmd.group = id
            vim.api.nvim_create_autocmd(cmd.event, cmd.opts)
        end
    end
end
