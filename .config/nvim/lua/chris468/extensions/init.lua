local fn = vim.fn
local stdpath = fn.stdpath
local ensure_packer = function()
  local install_path = stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require 'chris468.util.if-ext' ('packer', function(packer)

  local create_autocmds = require 'chris468.util.create-autocmds'
  create_autocmds({
    packer_user_config = {
      {
        event = 'BufWritePost',
        opts = {
          pattern = stdpath('config') .. '/lua/chris468/extensions/init.lua',
          command = 'source <afile> | PackerSync'
        }
      }
    }
  })

  packer.init()

  packer.startup(function(use)
    use {
      { 'wbthomason/packer.nvim' }, -- no tags
      { 'nvim-lua/plenary.nvim', tag='v0.*' },

      { 'dracula/vim', branch = 'master' },

      { 'nvim-tree/nvim-tree.lua' }, -- only has `nightly` tag

      {
        'nvim-telescope/telescope.nvim',
        -- tag = 'v0.*' , *lots* of changes since tag, fear bug fixes.
        requires = { 'nvim-lua/plenary.nvim' }
      },

      { 'tommcdo/vim-exchange' }, -- no tags

      { 'tpope/vim-surround' }, -- tags are pretty old

      { 'mfussenegger/nvim-dap', tag = '0.*' },

      { "williamboman/mason.nvim" }, -- no tgs
      { "williamboman/mason-lspconfig.nvim" }, -- no tags
      { "jay-babu/mason-nvim-dap.nvim", tag = 'v1.*' },

      { 'neovim/nvim-lspconfig' }, -- bug fixes since last tag
      { 'L3MON4D3/LuaSnip', tag = 'v1.*' },
      { 'saadparwaiz1/cmp_luasnip' }, -- no tags
      { 'hrsh7th/cmp-buffer' },  -- no tags
      { 'hrsh7th/cmp-cmdline' }, -- no tags
      { 'hrsh7th/cmp-nvim-lsp' }, -- no tags
      { 'hrsh7th/cmp-nvim-lua' }, -- no tags
      { 'hrsh7th/cmp-path' }, -- no tags
      { 'hrsh7th/nvim-cmp' }, -- no tags

      { 'rafcamlet/nvim-luapad' }, -- outdated tags

      { 'lewis6991/gitsigns.nvim', tag = 'v0.*' },
      { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }, -- no tags

      { 'nvim-treesitter/nvim-treesitter', tag = 'v0.8.*' },
      { 'theHamsta/nvim-dap-virtual-text', requires = 'nvim-treesitter/nvim-treesitter' }, -- no tags

      { "rcarriga/nvim-dap-ui", tag = 'v3.*', requires = {"mfussenegger/nvim-dap"} },

      {
        'nvim-neotest/neotest',
        tag = 'v2.*',
        requires = {
          'nvim-treesitter/nvim-treesitter',
          'nvim-lua/plenary.nvim'
        }
      },

      { 'nvim-neotest/neotest-python', requires = { 'nvim-neotest/neotest' } }, -- no tags
      { 'Issafalcon/neotest-dotnet', tag = 'v1.*', requires = { 'nvim-neotest/neotest' } },
      { 'lukas-reineke/indent-blankline.nvim', tag = 'v2.*' },

      { 'nvim-lualine/lualine.nvim' }, -- tags look like only compat
      { 'ahmedkhalf/project.nvim', requires = 'nvim-telescope/telescope.nvim' }, -- no tags

      { 'chrisbra/unicode.vim' }, -- unicode.vim tags are really old
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end)

  local require_all = require('chris468.util.require-all')
  require_all('chris468.extensions')

end)
