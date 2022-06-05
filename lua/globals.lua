--Set python environment
vim.g.python3_host_prog = '/home/neovim/.local/share/venvs/python3_neovim'

-- enable filetypee.lua
-- This feature is currently opt-in
-- as it does not yet completely match all of the filetypes covered by filetype.vim
vim.g.do_filetype_lua = 1
-- disable filetype.vim
vim.g.did_load_filetypes = 0
