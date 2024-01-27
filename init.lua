local M = require('spotter.user_utils')

function M.setup()
    vim.keymap.set({'n', 'v'}, '<leader>g', "<cmd>lua require'spotter'.show{expire_ms=5000, hide_on_move=true, toggle=true}<cr>", {remap=false})
    vim.keymap.set({'n', 'v'}, 'f', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='after'}<cr>f", {remap=false})
    vim.keymap.set({'n', 'v'}, 't', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='after'}<cr>t", {remap=false})
    vim.keymap.set({'n', 'v'}, 'F', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='before'}<cr>F", {remap=false})
    vim.keymap.set({'n', 'v'}, 'T', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='before'}<cr>T", {remap=false})
end

return M
