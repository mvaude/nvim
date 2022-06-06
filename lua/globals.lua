local g = vim.g

--Set python environment
g.python3_host_prog = '/root/.local/share/venvs/python3_neovim/bin/python'

-- enable filetypee.lua
-- This feature is currently opt-in
-- as it does not yet completely match all of the filetypes covered by filetype.vim
g.do_filetype_lua = 1
-- disable filetype.vim
g.did_load_filetypes = 0
