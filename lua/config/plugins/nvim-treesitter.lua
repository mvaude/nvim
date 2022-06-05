require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    'bash',
    'beancount',
    'c',
    'cmake',
    'comment',
    'cooklang',
    'css',
    'dockerfile',
    'go',
    'gomod',
    'gowork',
    'graphql',
    'hcl',
    'html',
    'http',
    'javascript',
    'jsdoc',
    'json',
    'latex',
    'markdown',
    'python',
    'ql',
    'query',
    'regex',
    'rust',
    'scss',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { 'javascript' },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    use_languagetree = false,

    disable = { 'json' },

    -- additional_vim_regex_highlighting = false,
  },
})
