local M = {}
local vim = vim
local cmd = vim.cmd

function M.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do cmd('autocmd ' .. autocmd) end
    cmd('augroup END')
end

function M.split_string(input, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    local i = 0
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function M.table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function addToSet(set, key) set[key] = true end

local function setContains(set, key) return set[key] ~= nil end

local existing_terms = {}
local open = true

M.toggle_terminal = function()
    open = not open
    if open then
        vim.cmd("FloatermToggle")
        return
    end

    local buffer = vim.fn.expand('%')
    if setContains(existing_terms, buffer) then
        vim.cmd("FloatermToggle")
    else
        vim.cmd("FloatermNew! --height=0.8 --width=0.8 cd %:p:h && clear")
        addToSet(existing_terms, buffer)
    end
end

M.stop_debug = function()
    vim.cmd("lua require('dap').disconnect()")
    vim.cmd("require('dap').close()")
end

function M.get_config(name) return string.format('require("plugins/%s")', name) end

local jumpbackward = function(num)
    vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-o>"]])
end

local jumpforward = function(num)
    vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-i>"]])
end
M.backward = function()
    local getjumplist = vim.fn.getjumplist()
    local jumplist = getjumplist[1]
    if #jumplist == 0 then return end

    -- plus one because of one index
    local i = getjumplist[2] + 1
    local j = i
    local curBufNum = vim.fn.bufnr()
    local targetBufNum = curBufNum

    while j > 1 and
        (curBufNum == targetBufNum or
            not vim.api.nvim_buf_is_valid(targetBufNum)) do
        j = j - 1
        targetBufNum = jumplist[j].bufnr
    end
    if targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
        jumpbackward(i - j)
        vim.api.nvim_buf_delete(curBufNum, {})
    end
end

M.forward = function()
    local getjumplist = vim.fn.getjumplist()
    local jumplist = getjumplist[1]
    if #jumplist == 0 then return end

    local i = getjumplist[2] + 1
    local j = i
    local curBufNum = vim.fn.bufnr()
    local targetBufNum = curBufNum

    -- find the next different buffer
    while j < #jumplist and
        (curBufNum == targetBufNum or vim.api.nvim_buf_is_valid(targetBufNum) ==
            false) do
        j = j + 1
        targetBufNum = jumplist[j].bufnr
    end
    while j + 1 <= #jumplist and jumplist[j + 1].bufnr == targetBufNum and
        vim.api.nvim_buf_is_valid(targetBufNum) do j = j + 1 end
    if j <= #jumplist and targetBufNum ~= curBufNum and
        vim.api.nvim_buf_is_valid(targetBufNum) then jumpforward(j - i) end
end
return M
