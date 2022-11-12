local vim = vim
local u = require("utils")
local packer_exists = pcall(vim.cmd, 'packadd packer.nvim')

if not packer_exists then
    if vim.fn.input('Download packer.nvim? (y to confirm): ') ~= 'y' then
        return
    end

    local directory = table.concat({
        vim.fn.stdpath('data'), 'site', 'pack', 'packer', 'start'
    }, '/')
    vim.fn.mkdir(directory, 'p')

    local out = vim.fn.system(string.format('git clone %s %s',
                                            'https://github.com/wbthomason/packer.nvim',
                                            directory .. '/' .. 'packer.nvim'))

    print(out)
    print('Downloading packer.nvim')

    vim.cmd('packadd packer.nvim')
end

return require("packer").startup(function(use)
    -- package manager
    use("wbthomason/packer.nvim")

    -- Snipptes & Language & Syntax
    use("yorinasub17/vim-terragrunt")
    use("hashivim/vim-terraform")
    use({"windwp/nvim-autopairs", config = u.get_config("autopairs")})

    use({"norcalli/nvim-colorizer.lua", config = u.get_config("colorizer")})
    use("voldikss/vim-floaterm")

    use({"kyazdani42/nvim-tree.lua", config = u.get_config("nvim-tree")})
    use({
        "kyazdani42/nvim-web-devicons",
        config = u.get_config("nvim-web-devicons")
    })
    use("David-Kunz/treesitter-unit")

    
    -- Color
    use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

    -- Colorscheme
    use({"nvim-treesitter/nvim-treesitter", config = u.get_config("treesitter")})
    use("ryanoasis/vim-devicons")

    -- Status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true},
        config = u.get_config("lualine")
    }


    use {
        'akinsho/bufferline.nvim',
        config = u.get_config("bufferline"),
        requires = 'kyazdani42/nvim-web-devicons'
    }

end)
