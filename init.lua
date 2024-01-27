local M = require('spotter.user_utils')

function M.setup(overrides)
    local conf = require('spotter.config')
    conf.setup(overrides)
    if conf.get('use_default_maps') then
        M.enable_default_maps()
    end
end

return M
