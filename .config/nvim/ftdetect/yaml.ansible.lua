local patterns = {
    "*/ansible/*",
    "*/playbooks/*",
    "*/roles/*",
}

local extensions = {
    "*.yml",
    "*.yaml",
}

local autocmd = vim.api.nvim_create_autocmd

for _, pattern in ipairs(patterns) do
    for _, extension in ipairs(extensions) do
        autocmd({ "BufRead", "BufNewFile" }, {
            pattern = pattern .. "/" .. extension,
            callback = function()
                vim.bo.filetype = "yaml.ansible"
            end,
        })
    end
end
