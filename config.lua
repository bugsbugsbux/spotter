local M = {}

local read_only_defaults = {
    ns = vim.api.nvim_create_namespace('SpotterNvim'),
    augroup = vim.api.nvim_create_augroup('SpotterClear', {clear=true}),
}

local defaults = vim.tbl_extend('error', read_only_defaults, {
    ---@param opts? table
    inject_on_show = function(opts) ---@diagnostic disable-line:unused-local
        -- vim.wo.cursorline = false
    end,
    ---@param opts? table
    inject_on_hide = function(opts) ---@diagnostic disable-line:unused-local
        -- vim.wo.cursorline = true
    end,
    color_dim_line = 'Comment',
    color_targets = 'Search',
})

---Throws if invalid overrides are given.
local function validate(overrides, allow_readonly)
    assert(type(overrides) == 'table')

    -- is key valid?
    local keys = vim.tbl_keys(overrides)
    if not allow_readonly then
        for _, key in ipairs(keys) do assert(
            not vim.tbl_contains(vim.tbl_keys(read_only_defaults), key),
            'Read-only config key: ' .. tostring(key)
        ) end
    end
    for _,key in ipairs(vim.tbl_keys(overrides)) do assert(
        vim.tbl_contains(vim.tbl_keys(defaults), key),
        'Invalid config key: ' .. tostring(key)
    ) end

    -- is value valid?
    vim.validate{
        inject_on_show = {overrides.inject_on_show, 'function', true},
        inject_on_hide = {overrides.inject_on_hide, 'function', true},
        color_dim_line = {overrides.color_dim_line, 'string', true},
        color_targets = {overrides.color_targets, 'string', true},
    }
end

validate(defaults, true) -- make sure default config is valid

---Represents current config state. Not exposed to user.
local active = vim.deepcopy(defaults)

---Reset config to defaults.
function M.reset()
    active = vim.deepcopy(defaults)
end

---Return config or value of given key.
---@param key string?
function M.get(key)
    if key then
        return active[key]
    end
    return active
end

function M.set(overrides)
    overrides = overrides or {}
    validate(overrides)
    active = vim.tbl_deep_extend('force', M.get(), overrides)
end

---Validates overrides before resetting and then overriding config with new values.
function M.setup(overrides)
    overrides = overrides or {}
    validate(overrides)
    M.reset()
    active = vim.tbl_deep_extend('force', M.get(), overrides)
end

return M
