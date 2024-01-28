local ns = vim.api.nvim_create_namespace('SpotterNvim')
local M = {
    ns = vim.deepcopy(ns),
}

---@return boolean
function M.is_active()
    return 1 == #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {limit=1})
end

---@param row number First line is row 0
local function dim_line(row)
    local color = require('spotter.config').get('color_dim_line')
    vim.api.nvim_buf_add_highlight(0, ns, color, row, 0, -1)
end

---@param row number First line is row 0
---@param byte number Byte in line
local function highlight_char(row, byte)
    local color = require('spotter.config').get('color_targets')
    vim.api.nvim_buf_add_highlight(0, ns, color, row, byte, byte+1)
end

function M.activate(opts)
    opts = opts or {}
    opts = vim.tbl_extend('keep', opts, {
        where = nil -- 'before' | 'after'
    })

    local conf = require('spotter.config')

    -- returns linenr (starting with 1) and cursor byte position (start with 0)
    local linenr, cursor = unpack(vim.api.nvim_win_get_cursor(0))

    local text = vim.api.nvim_buf_get_lines(0, linenr-1, linenr, false)[1]

    -- possible jumphighlights
    local chars = vim.split(text, '')
    local before = {} ---@type {str:number}
    local after = {} ---@type {str:number}
    for pos, char in ipairs(chars) do
        pos = pos-1
        if pos < cursor then
            before[char] = pos
        elseif pos > cursor and not after[char] then
            after[char] = pos
        end
    end

    conf.get('inject_on_show')(opts)
    if conf.get('dim_line') then
        dim_line(linenr-1)
    end

    local positions
    if opts.where then
        positions = ({before = before, after = after})[opts.where]
        positions = vim.tbl_values(positions)
    else
        positions = vim.list_extend(vim.tbl_values(before), vim.tbl_values(after))
    end

    for _, pos in ipairs(positions) do
        highlight_char(linenr-1, pos)
    end
end

function M.deactivate(opts)
    opts = opts or {}
    local conf = require('spotter.config')
    conf.get('inject_on_hide')(opts)
    --- buf, ns, 0based_startline, 0based_endline_or_neg1
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
