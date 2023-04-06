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
    use 'wbthomason/packer.nvim'

    use 'dracula/vim'

    use 'nvim-tree/nvim-tree.lua'
    use { 'nvim-telescope/telescope.nvim', requires = {{ 'nvim-lua/plenary.nvim' }}}

    use 'tommcdo/vim-exchange'
    use 'tpope/vim-surround'

    use 'mfussenegger/nvim-dap'

    use "williamboman/mason.nvim"
    use { "williamboman/mason-lspconfig.nvim" }
    use { "jay-babu/mason-nvim-dap.nvim" }


    use 'neovim/nvim-lspconfig'
    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'saadparwaiz1/cmp_luasnip'

    use 'rafcamlet/nvim-luapad'

    use 'lewis6991/gitsigns.nvim'
    use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

    use { 'nvim-treesitter/nvim-treesitter', tag = 'v0.8.3' }
    use { 'theHamsta/nvim-dap-virtual-text', requires = 'nvim-treesitter/nvim-treesitter' }

    use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

    use {
      'nvim-neotest/neotest',
      requires = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-lua/plenary.nvim'
      }
    }

    use { 'nvim-neotest/neotest-python', requires = { 'nvim-neotest/neotest' } }
    use { 'Issafalcon/neotest-dotnet', requires = { 'nvim-neotest/neotest' } }
    use 'lukas-reineke/indent-blankline.nvim'

    use 'nvim-lualine/lualine.nvim'
    use { 'ahmedkhalf/project.nvim', requires = 'nvim-telescope/telescope.nvim' }

    use 'chrisbra/unicode.vim'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end)

  local require_all = require('chris468.util.require-all')
  require_all('chris468.extensions')

end)
