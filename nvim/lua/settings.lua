local vim = vim

vim.o.hidden = true --- Required to keep multiple buffers open multiple buffers
vim.o.completeopt = "menuone,noselect"
vim.o.encoding = "utf-8" --- The encoding displayed
vim.o.fileencoding = "utf-8" --- The encoding written to file
vim.o.cmdheight = 2 --- Give more space for displaying messages
vim.o.splitright = true --- Vertical splits will automatically be to the right
vim.o.updatetime = 100 --- Faster completion
vim.o.timeoutlen = 300 --- Faster completion
vim.o.clipboard = "unnamed,unnamedplus" --- Copy-paste between vim and everything else
vim.o.mouse = "a" --- Enable mouse
vim.o.smartcase = true --- Uses case in search
vim.o.smarttab = true --- Makes tabbing smarter will realize you have 2 vs 4
vim.bo.smartindent = true --- Makes indenting smart
vim.bo.shiftwidth = 4 --- Change a number of space characeters inseted for indentation
vim.o.shiftwidth = 4 --- Change a number of space characeters inseted for indentation
vim.o.showtabline = 4 --- Always show tabs
vim.o.tabstop = 4 --- Insert 2 spaces for a tab
vim.bo.tabstop = 4 --- Insert 2 spaces for a tab
vim.o.softtabstop = 4 --- Insert 2 spaces for a tab
vim.bo.softtabstop = 4 --- Insert 2 spaces for a tab
vim.o.showmode = false --- Don't show things like -- INSERT -- anymore
vim.o.autoindent = true --- Good auto indent
vim.o.errorbells = false --- Disables sound effect for errors
vim.wo.number = true --- Shows current line number
vim.wo.relativenumber = false --- Enables relative number
vim.wo.cursorline = true --- Highlight of current line
vim.wo.wrap = false --- Display long lines as just one line
vim.o.backup = false --- Recommended by coc
vim.o.writebackup = false --- Recommended by coc
vim.o.swapfile = false --- Recommended by coc
vim.o.emoji = false --- Fix emoji display
vim.o.undodir = "/home/samuel/.config/nvim/undodir" --- Dir for undos
vim.o.undofile = true --- Sets undo to file
vim.o.incsearch = true --- Start searching before pressing enter
vim.o.conceallevel = 0 --- Show `` in markdown files
vim.go.t_Co = "256" --- Support 256 colors
vim.go.t_ut = "" --- https://www.reddit.com/r/neovim/comments/nt0li1/weird_error_after_updating/
vim.go.termguicolors = true --- Correct terminal colors
vim.o.backspace = "indent,eol,start" --- Making sure backspace works
vim.o.lazyredraw = true --- Makes macros faster & prevent errors in complicated mappings
vim.o.scrolloff = 8 --- Always keep space when scrolling to bottom/top edge
vim.o.viminfo = "'100" --- Increase the size of file history
vim.cmd('set expandtab')
vim.cmd('set shortmess+=c') --- " Don't pass messages to |ins-completion-menu|
vim.cmd('set signcolumn=yes')
vim.cmd('set encoding=utf-8')
vim.opt.listchars = {eol = '⏎', tab = '├─'}

-- https://github.com/neovim/neovim/issues/13501#issuecomment-758602763
vim.o.exrc = true
vim.o.secure = true

-- colorschema
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])
