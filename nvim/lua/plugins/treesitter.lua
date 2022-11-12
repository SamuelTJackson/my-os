require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "python", "json", "html", "gomod", "css", "javascript", "bash", "dockerfile", "yaml", "go", "typescript", "tsx",
        "markdown"
    }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true -- false will disable the whole extension
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>'
        }
    },

    indent = {enable = true},
    autopairs = {enable = true},

    context_commentstring = {enable = true}
}
