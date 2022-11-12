local vim = vim
vim.g.mapleader = " "

require("init")

-- load .nvimrc project specific configs
local local_vimrc = vim.fn.getcwd() .. '/.nvimrc'
if vim.loop.fs_stat(local_vimrc) then
    vim.cmd('source ' .. local_vimrc)
end
