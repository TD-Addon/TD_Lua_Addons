local core = require('openmw.core')

return {
    engineHandlers = {
        onInactive = function()
            core.sendGlobalEvent('T_ActorInactive', self.object)
        end
    }
}
