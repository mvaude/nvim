-- This file can be loaded by calling `lua require('config.plugins')` from your init.lua

-- Only required if you have packer in your `opt` pack
vim.api.nvim_command([[packadd packer.nvim]])

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd(
  'BufWritePost',
  { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' }
)

return require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')
  use({
    'nvim-treesitter/nvim-treesitter',
    -- run = ':TSUpdate',
    config = function()
      require('config.plugins.nvim-treesitter')
    end,
  })
  -- Theme
  use({
    'EdenEast/nightfox.nvim',
    config = function()
      require('config.plugins.nightfox')
    end,
  })

  -- use {
  --   "ThePrimeagen/refactoring.nvim",
  --   requires = {
  --       {"nvim-lua/plenary.nvim"},
  --       {"nvim-treesitter/nvim-treesitter"}
  --   }
  -- }
end)
