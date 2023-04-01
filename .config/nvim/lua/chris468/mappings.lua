local function ext(name, callback)
  return function()
    require 'chris468.util.if-ext'(name, function(e)
      callback(e)
    end)
  end
end

local function map(mappings)
  for _, m in pairs(mappings) do
    if not m.map or not m.cmd then
      print('map and cmd are required. skipping ' .. vim.inspect(m))
    else
      vim.keymap.set(
        m.mode or "n",
        m.map,
        m.cmd,
        m.opts or { noremap = true, silent = true }
      )
    end
  end
end

local mappings = {
  { map = "<Space>", cmd = "<Nop>", mode = "" },
  { map = "<leader>h", cmd = vim.cmd.tabprevious },
  { map = "<leader>l", cmd = vim.cmd.tabnext },
  { map = "<leader>n", cmd = vim.cmd.nohlsearch },

  { map = "<leader>ef", cmd = ext('nvim-tree.api', function(t) t.tree.open() end) },
  { map = "<leader>eF", cmd = ext('nvim-tree.api', function(t) t.tree.open({find_file = true}) end) },
  { map = "<leader>et", cmd = ext('nvim-tree.api', function(t) t.tree.toggle() end) },
  {
    map = '<leader>f',
    cmd = ext('telescope.builtin', function(t)
      if 0 == os.execute('git rev-parse >/dev/null 2>&1') then
        t.git_files()
      else
        t.find_files()
      end
    end)
  },
  { map = '<leader>F', cmd = ext('telescope.builtin', function(t) t.find_files() end) },
  { map = '<leader>t', cmd = ext('telescope.builtin', function(_) vim.cmd('Telescope') end) },

  { map = '[d', cmd = vim.diagnostic.goto_prev },
  { map = ']d', cmd = vim.diagnostic.goto_next },
}

local lsp_mappings = {
  { map = 'gd', cmd = vim.lsp.buf.definition },
  { map = 'gr', cmd = vim.lsp.buf.references },
  { map = 'gi', cmd = vim.lsp.buf.implementation },
  { map = 'gt', cmd = vim.lsp.buf.type_definition },
  {
    map = 'gs',
    cmd = ext('telescope.builtin',
      function(t)
        t.lsp_dynamic_workspace_symbols { symbols = {
          'class', 'method', 'property', 'field', 'constructor',
          'enum', 'interface', 'function', 'enummember', 'struct', 'event',
          'operator'
        }
      }
      end)
   },
  { map = '<leader>rn', cmd = vim.lsp.buf.rename },
  { map = 'K', cmd = vim.lsp.buf.hover },
  { map = '<leader>s', cmd = vim.lsp.buf.signature_help },
  { map = '<leader><leader>', cmd = vim.lsp.buf.code_action },
  { map = '<leader>af', cmd = function() vim.lsp.buf.format { async = true } end },
}

local function add_lsp_mappings()
  map(lsp_mappings)
end

vim.cmd [[
  augroup LspMappings
    autocmd!
    autocmd LspAttach * silent lua require 'chris468.mappings'.add_lsp_mappings()
  augroup end
]]

map(mappings)
return {
  add_lsp_mappings = add_lsp_mappings
}
