local core = require('spotter.core')

local augroup = vim.api.nvim_create_augroup('SpotterClear', {clear=true})
local M = {
    augroup = vim.deepcopy(augroup), ---@type number
}

---Stop showing targets for f/t/F/T when cursor moves/buffer is left.
function M.hide_on_move()
    vim.api.nvim_create_autocmd({'CursorMoved', 'BufLeave'}, {
        group = augroup,
        once = true,
        callback = function()
            core.deactivate()
        end,
    })
end

---Stop showing targets for f/t/F/T after 'expire=' milliseconds
---optionally already stop showing them when cursor moves.
---NOTE: During operator pending mode the targets will never be hidden (due to libuv),
---if the timer expires during this time, they are hidden immediately afterwards.
function M.hide_on_expire(opts)
    opts = opts or {}
    opts = vim.tbl_extend('keep', opts, {
        hide_on_move = false,
        expire_ms = 3000,
    })
    assert(type(opts.hide_on_move) == 'boolean')
    assert(type(opts.expire_ms) == 'number')

    -- ensure correct, valid buffer
    local buf = vim.api.nvim_get_current_buf()
    local function hide()
        if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_call(buf, core.deactivate)
        end
    end

    -- hide after given time
    local timer = vim.defer_fn(hide, opts.expire_ms)

    -- hide on cursor move and abort timer
    if opts.hide_on_move then
        vim.api.nvim_create_autocmd({'CursorMoved', 'BufLeave'}, {
            group = augroup,
            once = true,
            callback = function()
                hide()
                timer:stop()
            end,
        })
    end
end

---Show (or toggle) targets for f/t/F/T motions.
---By deault hides on cursor move; to disable use: `hide_on_move=false`
function M.show(opts)
    opts = opts or {}

    if opts.toggle and core.is_active() then
        core.deactivate()
        return
    end

    core.activate(opts)

    if opts.expire_ms then
        M.hide_on_expire(opts) -- also clears on move if hide_on_move is true
        return
    end

    if opts.hide_on_move == false then
        return
    end
    M.hide_on_move()
end

function M.enable_default_maps()
    vim.keymap.set({'n', 'v'}, 'f', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='after'}<cr>f", {remap=false})
    vim.keymap.set({'n', 'v'}, 't', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='after'}<cr>t", {remap=false})
    vim.keymap.set({'n', 'v'}, 'F', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='before'}<cr>F", {remap=false})
    vim.keymap.set({'n', 'v'}, 'T', "<cmd>lua require'spotter'.show{expire_ms=1, hide_on_move=true, where='before'}<cr>T", {remap=false})
end

function M.disable_default_maps()
    vim.keymap.del({'n', 'v'}, 'f')
    vim.keymap.del({'n', 'v'}, 't')
    vim.keymap.del({'n', 'v'}, 'F')
    vim.keymap.del({'n', 'v'}, 'T')
end

return M
