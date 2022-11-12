local map = vim.api.nvim_set_keymap

local nore_silent = {noremap = true, silent = true}
local nore = {noremap = true}
local silent = {silent = true}

map("i", "jj", "<ESC>", nore)

map('n', '<leader>z', '<cmd>NeoZoomToggle<CR>',
    {noremap = true, silent = true, nowait = true})
-- Space to NOP to prevent Leader issues
map("n", "<Space>", "<NOP>", nore_silent)

-- Better window movement
map("n", "<C-h>", "<C-w>h", nore_silent)
map("n", "<C-j>", "<C-w>j", nore_silent)
map("n", "<C-k>", "<C-w>k", nore_silent)
map("n", "<C-l>", "<C-w>l", nore_silent)

-- Redo with U
map("n", "U", "<C-R>", nore_silent)

-- Move selected line / block of text in visual mode
map("x", "K", ":move '<-2<CR>gv-gv", nore_silent)
map("x", "J", ":move '>+1<CR>gv-gv", nore_silent)

-- Keep visual mode indenting
map("v", "<", "<gv", nore_silent)
map("v", ">", ">gv", nore_silent)

-- Save file by CTRL-S
map("n", "<C-s>", ":w<CR>", nore_silent)
map("i", "<C-s>", "<ESC> :w<CR>", nore_silent)

-- Make work uppercase
map("n", "<C-u>", "viwU<ESC>", nore)
map("i", "<C-u>", "<ESC>viwUi", nore)

-- Remove highlights
map("n", "<CR>", ":noh<CR><CR>", nore_silent)

-- Don't yank on delete char
map("n", "x", '"_x', nore_silent)
map("n", "X", '"_X', nore_silent)
map("v", "x", '"_x', nore_silent)
map("v", "X", '"_X', nore_silent)

-- Yank until the end of line
map("n", "Y", "y$", nore)

-- Quickfix
map("n", "<Space>qn", ":cn<CR>", silent)
map("n", "<Space>qc", ":cclose<CR>", silent)

-- Git
map("n", "<leader>gs", ":Git<CR>", nore_silent)
map("n", "<leader>gl", ":Gclog<CR>", nore_silent)
map("n", "<leader>gd", "::Gvdiffsplit master<CR>", nore_silent)
map("n", "<leader>gc", ":Git commit<CR>", nore_silent)
map("n", "<leader>ga", ":Git add %<CR>", nore_silent)
map("n", "<leader>gp", ":! git push<CR>", nore_silent)
map("n", "<leader>gpf", ":! git push -f<CR>", nore_silent)
map("n", "<leader>gf", ":Git fetch origin<CR>", nore_silent)
map("n", "<leader>gr", ":Git rebase -i origin/master<CR>", nore_silent)
map("n", "<leader>gb", ":GitBlameToggle<CR>", nore_silent)
map("n", "<leader>gbb",
    "<cmd>lua require('telescope.builtin').git_branches()<CR>", nore_silent)
map("n", "<leader>gtt", ":Git checkout --theirs %<CR>", nore_silent)
map("n", "<leader>gto", ":Git checkout --ours %<CR>", nore_silent)

-- DBUI
map("n", "<leader>sdb", ":tabnew<CR>:DBUI<CR>", nore_silent)

-- Nvim Tree
map("n", "nt", ":NvimTreeToggle<CR>", nore_silent)
map("n", "nf", ":NvimTreeFindFile<CR>", nore_silent)

-- Floaterm
-- map("n", "<F12>", ":FloatermNew! --height=0.8 --width=0.8 cd %:p:h<CR>", nore_silent)
-- map('t', '<F12>', [[<C-\><C-n>:lua require("lspsaga.floaterm").close_float_terminal()<CR>]], nore_silent)
map("n", "<F12>", ":lua require('utils').toggle_terminal()<CR>", nore_silent)
map("t", "<F12>", "<C-\\><C-n>:lua require('utils').toggle_terminal()<CR>",
    nore_silent)

map("n", "<leader>p", ":lua require('utils').backward()<CR>", nore_silent)
-- Telescope
map("n", "tf", "<cmd>lua require('telescope.builtin').find_files()<CR>",
    nore_silent)
map("n", "tg", "<cmd>lua require('telescope.builtin').live_grep()<CR>",
    nore_silent)
map("n", "tb", "<cmd>lua require('telescope.builtin').buffers()<CR>",
    nore_silent)
map("n", "tt", "<cmd>:Telescope tele_tab_select list<CR>", nore_silent)
map("n", "tfu", "<cmd>:Telescope tele_func_select list<CR>", nore_silent)

map("n", "<F9>", "<cmd>:TagbarToggle<CR>", nore_silent)
-- Tabs
map("n", "tc", "<cmd>:tabclose<CR>", nore_silent)

-- Kommentary
map("n", "<leader>cc", "<Plug>kommentary_line_default", {})
map("n", "<leader>c", "<Plug>kommentary_motion_default", {})
map("x", "<leader>c", "<Plug>kommentary_visual_default", {})

-- Select Treesitter Node
map('v', 'x', ':lua require"treesitter-unit".select()<CR>', nore_silent)
map('n', 'x', ':lua require"treesitter-unit".select()<CR>', nore_silent)
map('o', 'x', ':<c-u>lua require"treesitter-unit".select()<CR>', nore_silent)

-- Undo tree
map('n', '<leader>ut', ':UndotreeToggle<CR>', nore_silent)

-- dap debug
map('n', '<F4>', ':lua require("dapui").eval()<CR>', silent)
map('n', '<F5>', ':lua require"dap".continue()<CR>', silent)
map('n', '<F6>', ':lua require"dap".step_over()<CR>', silent)
map('n', '<F7>', ':lua require"dap".step_into()<CR>', silent)
map('n', '<F8>', ':lua require"dap".step_out()<CR>', silent)
map('n', '<F10>', ':lua require"dapui".toggle()<CR>', silent)
map('n', '<leader>dd', ":lua require('dap').disconnect()<CR>", silent)
map('n', '<leader>dc', ":lua require('dap').close()<CR>", silent)
map('n', '<leader>db', ':lua require"dap".toggle_breakpoint()<CR>', silent)

-- nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
-- nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
-- nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
-- nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
-- nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
-- nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
-- nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
-- nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>

-- spotify
map("n", "<leader>sn", "<Plug>(SpotifySkip)", silent) -- Skip the current track
map("n", "<leader>sp", "<Plug>(SpotifyPause)", silent) -- Pause/Resume the current track
map("n", "<leader>ss", "<Plug>(SpotifySave)", silent) -- Add the current track to your library
map("n", "<leader>so", ":Spotify<CR>", silent) -- Open Spotify Search window
map("n", "<leader>sd", ":SpotifyDevices<CR>", silent) -- Open Spotify Devices window

-- Bufferline
map("n", "L", ":BufferLineCycleNext<CR>", silent)
map("n", "H", ":BufferLineCyclePrev<CR>", silent)
map("n", "<leader>bp", ":BufferLinePick<CR>", silent)
map("n", "<leader>bc", ":BufferLinePickClose<CR>", silent)

return M
