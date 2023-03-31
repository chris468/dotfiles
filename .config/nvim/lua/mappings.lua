local opts = { noremap = true, silent = true }

vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>h", vim.cmd.tabprevious, opts)
vim.keymap.set("n", "<leader>l", vim.cmd.tabnext, opts)
vim.keymap.set("n", "<leader>n", vim.cmd.nohlsearch, opts)

local function ext(name, callback)
  return function()
    local result_ok, ext = pcall(require, name)
    print(result_ok)
    print(ext)
    if result_ok then
      callback(ext)
    end
  end
end

vim.keymap.set("n", "<leader>ef", ext('nvim-tree.api', function(t) t.tree.open() end), opts)
vim.keymap.set("n", "<leader>eF", ext('nvim-tree.api', function(t) t.tree.open({find_file = true}) end), opts)
vim.keymap.set("n", "<leader>et", ext('nvim-tree.api', function(t) t.tree.toggle() end), opts)

vim.keymap.set('n', '<leader>f', ext('telescope.builtin',
  function(t)
    if 0 == os.execute('git rev-parse >/dev/null 2>&1') then
      t.git_files()
    else
      t.find_files()
    end
  end), opts)
vim.keymap.set('n', '<leader>F', ext('telescope.builtin', function(t) t.find_files() end), opts)
vim.keymap.set('n', '<leader>t', ext('telescope.builtin', function(_) vim.cmd('Telescope') end), opts)
