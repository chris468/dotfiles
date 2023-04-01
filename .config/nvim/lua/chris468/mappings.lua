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

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opt)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opt)

local function add_lsp_mappings()
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'gs', ext('telescope.builtin',
    function(t)
      t.lsp_dynamic_workspace_symbols { symbols = {
        'class', 'method', 'property', 'field', 'constructor',
        'enum', 'interface', 'function', 'enummember', 'struct', 'event',
        'operator'
      }
    }
    end), opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>s', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader><leader>', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>af', function() vim.lsp.buf.format { async = true } end, opts)
end

vim.cmd [[
  augroup LspMappings
    autocmd!
    autocmd LspAttach * silent lua require 'chris468.mappings'.add_lsp_mappings()
  augroup end
]]

return {
  add_lsp_mappings = add_lsp_mappings
}
