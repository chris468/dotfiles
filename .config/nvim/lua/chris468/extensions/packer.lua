local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require 'chris468.util.if-ext' ('packer', function(packer)

  vim.cmd([[
    augroup packer_user_config
      autocmd!
      autocmd BufWritePost packer.lua source <afile> | PackerSync
    augroup end
  ]])

  packer.init()

  return packer.startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'dracula/vim'

    use 'nvim-tree/nvim-tree.lua'
    use { 'nvim-telescope/telescope.nvim', requires = {{ 'nvim-lua/plenary.nvim' }}}

    use 'tommcdo/vim-exchange'
    use 'tpope/vim-surround'

    use 'mfussenegger/nvim-dap'

    use { "williamboman/mason.nvim", run = ":MasonUpdate" }
    use { "williamboman/mason-lspconfig.nvim" }
    use { "jay-babu/mason-nvim-dap.nvim" }


    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end)

end)
