local group = vim.api.nvim_create_augroup("chris468.autocmds.obsidian", { clear = true })

-- The plugin errors on load if there is no valid workspace. Instead of using
-- lazy spec to check only filetype, also check whether it's in an obsidian
-- vault.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(args)
    if not LazyVim.has("obsidian.nvim") or LazyVim.is_loaded("obsidian.nvim") then
      return true
    end

    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" then
      return
    end

    local obsidian = require("util.obsidian")
    if obsidian.find_obsidian_vault(path) then
      require("lazy").load({ plugins = { "obsidian.nvim" } })
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(args.buf) then
          return
        end

        -- If obsidian loads during this FileType event, it misses this buffer.
        -- Re-run obsidian's own FileType/BufEnter handlers once for this buffer.
        vim.api.nvim_exec_autocmds("FileType", {
          group = "obsidian_setup",
          buffer = args.buf,
          modeline = false,
        })
        vim.api.nvim_exec_autocmds("BufEnter", {
          group = "obsidian_setup",
          buffer = args.buf,
          modeline = false,
        })
      end)
      return true
    end
  end,
})
