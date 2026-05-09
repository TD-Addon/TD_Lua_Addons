local core = require('openmw.core')
local self = require('openmw.self')

return {
    engineHandlers = {
        onInactive = function()
            core.sendGlobalEvent('T_ActorInactive', self.object)
        end
    }
}
