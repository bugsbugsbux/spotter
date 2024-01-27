local ns = vim.api.nvim_create_namespace('SpotterNvim')
local M = {
    ns = vim.deepcopy(ns),
}

-----------------------------------------------------
-- move this to config:
-----------------------------------------------------

local HLGRP_DIM = 'Comment'
local HLGRP_MARK = 'Search'

local function inject_on_activation()
    vim.wo.cursorline = false
    vim.o.cursorcolumn = true
end
local function inject_on_deactivation()
    vim.o.cursorline = true
    vim.o.cursorcolumn = false
end

-----------------------------------------------------

---@return boolean
function M.is_active()
    return 1 == #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {limit=1})
end

---@param row number First line is row 0
local function dim_line(row)
    vim.api.nvim_buf_add_highlight(0, ns, HLGRP_DIM, row, 0, -1)
end

---@param row number First line is row 0
---@param byte number Byte in line
local function highlight_char(row, byte)
    vim.api.nvim_buf_add_highlight(0, ns, HLGRP_MARK, row, byte, byte+1)
end

function M.activate(opts)
    opts = opts or {}
    opts = vim.tbl_extend('keep', opts, {
        where = nil -- 'before' | 'after'
    })

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

    inject_on_activation()
    dim_line(linenr-1)

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

function M.deactivate()
    inject_on_deactivation()
    --- buf, ns, 0based_startline, 0based_endline_or_neg1
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
