local u = require('utils')
local vim = vim
local b = vim.b
local status = require'nvim-spotify'.status
status:start()

local function get_git_branch()
    if b.gitsigns_status then
        local status = b.gitsigns_head
        local status_split = u.split_string(status, '-')
        local status_split_count = u.table_length(status_split)
        if (status_split_count > 1) then
            status = status_split[0]
        end
        return status
    end
    return ''
end

local function filename()
    return vim.fn.expand('%:~:.')
end

local function get_project()
    local file_path = vim.fn.expand("%:p:h")
    local git_dir = vim.fn.finddir(".git/..", file_path .. ";")
    local path_split = u.split_string(git_dir, '/')
    return path_split[#path_split]
end

require'lualine'.setup {
    options = {
        icons_enabled = true,
        theme = 'gruvbox',
        component_separators = {left = '', right = ''},
        section_separators = {left = '', right = ''},
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {get_git_branch},
        lualine_b = {get_project},
        lualine_c = {filename},
        lualine_x = {{status.listen}, {'encoding'}, {'filetype', icon_only = true}},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {status.listen}
    },
    tabline = {},
    extensions = {'nvim-tree', 'fugitive'}
}
