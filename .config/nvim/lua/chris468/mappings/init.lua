local if_ext = require 'chris468.util.if-ext'
local util = require 'chris468.mappings.util'
local map, ext, temporarily_disable_relativenumber = util.map, util.ext, util.temporarily_disable_relativenumber

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

  { map = '<leader>R', cmd = temporarily_disable_relativenumber },
}

local function dap_mappings(dap)
  local debugger = require('chris468.mappings.debugger')(dap)
  return {
    { map = '<leader>dg', cmd = debugger.launch_or_continue },
    { map = '<leader>dG', cmd = debugger.prompt_or_continue },
    { map = '<leader>db', cmd = dap.toggle_breakpoint },
    { map = '<leader>ds', cmd = dap.terminate },
    { map = '<leader>dr', cmd = dap.restart },
    { map = '<leader>dp', cmd = dap.pause },
    { map = '<leader>o', cmd = dap.step_over },
    { map = '<leader>i', cmd = dap.step_into },
    { map = '<leader>u', cmd = dap.step_out },
    { map = '<leader>dv', cmd = ext('dapui', function(dapui) dapui.eval() end), mode = {'n', 'x'} },
    { map = '<leader>df', cmd = dap.focus_frame },
    { map = '<leader>dk', cmd = dap.up },
    { map = '<leader>dj', cmd = dap.down },

    -- nmap <silent> <leader>vwo           :VimspectorShowOutput<CR>
    -- nmap <silent> <leader>vws           :call chris468#focus_window('vimspector.StackTrace')<CR>
    -- nmap <silent> <leader>vww           :call chris468#focus_window('vimspector.Watches')<CR>
    -- nmap <silent> <leader>vwv           :call chris468#focus_window('vimspector.Variables')<CR>
    --
    -- prob not needed:
    -- nmap <silent> <leader>vx            :call vimspector#Reset( {'interactive': v:false } )<CR>
    -- " nmap <silent> <leader><F8>         <Plug>VimspectorJumpToNextBreakpoint
    -- " nmap <silent> <leader><S-F8>       <Plug>VimspectorJumpToPreviousBreakpoint
    -- " nmap <silent> <leader><S-F9>       <Plug>VimspectorAddFunctionBreakpoint
    -- " nmap <silent> <leader><M-8>        <Plug>VimspectorDisassemble
  }
end

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
  --- on cursor hold, to show full line diagnostics:  vim.diagnostic.open_float()
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
if_ext('dap', function(dap) map(dap_mappings(dap)) end)

return {
  add_lsp_mappings = add_lsp_mappings,
}
