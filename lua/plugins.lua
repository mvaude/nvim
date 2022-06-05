local settings = require('user')
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

-- returns the require for use in `config` parameter of packer's use
-- expects the name of the config file
local function get_config(name)
  return string.format('require("config/%s")', name)
end

-- bootstrap packer if not installed
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({
    'git',
    'clone',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })
  print('Installing packer...')
  vim.api.nvim_command('packadd packer.nvim')
end

-- initialize and configure packer
local packer = require('packer')

packer.init({
  enable = true, -- enable profiling via :PackerCompile profile=true
  threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
  -- Have packer use a popup window
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'rounded' })
    end,
  },
})

packer.startup(function(use)
  use('wbthomason/packer.nvim')

  use({
    'nvim-telescope/telescope.nvim',
    requires = {
      -- Mandatory
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      -- plugins
      { 'jvgrootveld/telescope-zoxide' },
      { 'crispgm/telescope-heading.nvim' },
      { 'nvim-telescope/telescope-symbols.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      { 'nvim-telescope/telescope-packer.nvim' },
      { 'nvim-telescope/telescope-project.nvim' },
    },
    config = get_config('telescope'),
  })

  use({
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = get_config('nvim-tree'),
    -- tag = 'nightly', -- optional, updated every week. (see issue #1193)
  })

  use({
    'nvim-treesitter/nvim-treesitter',
    -- run = ':TSUpdate',
    config = get_config('treesitter'),
  })
  -- Theme
  use({
    'EdenEast/nightfox.nvim',
    config = get_config('nightfox'),
  })
end)
