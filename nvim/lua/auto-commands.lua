local u = require("utils")

u.create_augroup({
    "TextYankPost * silent! lua vim.highlight.on_yank{higroup='IncSearch',timeout=300}"
}, "highlight_yank")
