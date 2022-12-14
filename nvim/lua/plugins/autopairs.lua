local npairs = require("nvim-autopairs")
npairs.setup({})

_G.MUtils = _G.MUtils or {}
MUtils.completion_confirm = function()
    return npairs.autopairs_cr()
end

vim.api.nvim_set_keymap("i", "<cr>", "v:lua.MUtils.completion_confirm()", {expr = true, noremap = true})
