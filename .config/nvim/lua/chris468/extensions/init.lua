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

require 'chris468.util.if-ext' ('packer', function(packer)

  packer.init()

  packer.startup(function(use)
    use {
      { 'wbthomason/packer.nvim' }, -- no tags
      { 'nvim-lua/plenary.nvim', tag='v0.*' },

      {
        'dracula/vim',
        branch = 'master',
        as = 'dracula'
      },

      {
        'nvim-tree/nvim-tree.lua',
        -- only has `nightly` tag
        config = function() require 'chris468.extensions.configure-nvim-tree' end,
      },

      {
        'nvim-telescope/telescope.nvim',
        -- tag = 'v0.*' , *lots* of changes since tag, fear bug fixes.
        requires = { 'nvim-lua/plenary.nvim' },
        config = function() require 'chris468.extensions.configure-nvim-tree' end,
      },

      { 'tommcdo/vim-exchange' }, -- no tags

      { 'tpope/vim-surround' }, -- tags are pretty old

      {
        'mfussenegger/nvim-dap',
        tag = '0.*',
        config = function() require 'chris468.extensions.configure-dap' end,
      },

      {
        "williamboman/mason.nvim",
        -- no tgs
        config = function() require 'chris468.extensions.configure-mason' end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        -- no tags
        requires = {
          "williamboman/mason.nvim",
          'neovim/nvim-lspconfig',
        },
        config = function() require 'chris468.extensions.configure-mason-lsp' end,
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        tag = 'v1.*',
        requires = {
          "williamboman/mason.nvim",
        },
        config = function() require 'chris468.extensions.configure-mason-dap' end,
      },

      { 'neovim/nvim-lspconfig' }, -- bug fixes since last tag
      {
        'L3MON4D3/LuaSnip',
        tag = 'v1.*',
        configure = function() require 'configure-luasnip' end,
      },
      { 'rafamadriz/friendly-snippets' }, -- no tabs
      { 'saadparwaiz1/cmp_luasnip' }, -- no tags
      { 'hrsh7th/cmp-buffer' },  -- no tags
      { 'hrsh7th/cmp-cmdline' }, -- no tags
      { 'hrsh7th/cmp-nvim-lsp' }, -- no tags
      { 'hrsh7th/cmp-nvim-lua' }, -- no tags
      { 'hrsh7th/cmp-path' }, -- no tags
      {
        'hrsh7th/nvim-cmp',
        -- no tags
        requires = 'L3MON4D3/LuaSnip', -- requires a snippet provider
        config = function() require 'chris468.extensions.configure-cmp' end,
      },
      {
        'jose-elias-alvarez/null-ls.nvim',
        -- no tags
        requires = 'nvim-lua/plenary.nvim',
        config = function() require 'chris468.extensions.configure-null-ls' end,
      },
      {
        'windwp/nvim-autopairs',
        -- no tags
        config = function() require 'chris468.extensions.configure-autopairs' end,
      },
      {
        'rafcamlet/nvim-luapad',
        -- outdated tags
        config = function() require 'chris468.extensions.configure-luapad' end,
      },

      {
        'lewis6991/gitsigns.nvim',
        tag = 'v0.*',
        config = function() require 'chris468.extensions.configure-gitsigns' end,
      },
      { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }, -- no tags

      {
        'nvim-treesitter/nvim-treesitter',
        tag = 'v0.8.*',
        config = function() require 'chris468.extensions.configure-nvim-treesitter' end,
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        -- no tags
        requires = 'nvim-treesitter/nvim-treesitter',
        config = function() require 'chris468.extensions.configure-nvim-dap-virtual-text' end,
      },

      {
        "rcarriga/nvim-dap-ui",
        tag = 'v3.*',
        requires = { "mfussenegger/nvim-dap" },
        config = function() require 'chris468.extensions.configure-nvim-dap-ui' end,
      },

      {
        'nvim-neotest/neotest',
        tag = 'v2.*',
        requires = {
          'nvim-treesitter/nvim-treesitter',
          'nvim-lua/plenary.nvim'
        },
        config = function() require 'chris468.extensions.configure-neotest' end,
      },

      {
        'nvim-neotest/neotest-python',
        -- no tags
        requires = { 'nvim-neotest/neotest' }
      },
      {
        'Issafalcon/neotest-dotnet',
        tag = 'v1.*',
        requires = { 'nvim-neotest/neotest' }
      },
      {
        'lukas-reineke/indent-blankline.nvim',
        tag = 'v2.*',
        config = function() require 'chris468.extensions.configure-indent_blankline' end,
      },

      {
        'nvim-lualine/lualine.nvim',
        -- tags look like only compat
        config = function() require 'chris468.extensions.configure-lualine' end,
      },
      {
        'ahmedkhalf/project.nvim',
         -- no tags
        requires = 'nvim-telescope/telescope.nvim',
        config = function() require 'chris468.extensions.configure-project' end,
      },

      { 'chrisbra/unicode.vim' }, -- unicode.vim tags are really old
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      vim.cmd [[ autocmd User PackerComplete echo 'Packages installed, restart needed' ]]
      require('packer').sync()
    end
  end)

end)

return not packer_bootstrap
