local core = require('openmw.core')
local self = require('openmw.self')
local util = require('openmw.util')

local state = {}

return {
    eventHandlers = {
        Died = function()
            if state.caster ~= nil then
                core.sendGlobalEvent('T_Unsummon', { creature = self.object, caster = state.caster, id = state.id, index = state.index })
            end
        end
    },
    engineHandlers = {
        onInit = function(data)
            state.caster = data.caster
            state.id = data.id
            state.index = data.index
            if data.tag == 't_conjuration_corruptionsummon' then
                local ai = self.type.stats.ai
                ai.alarm(self).base = 0
                ai.fight(self).base = 50
                ai.flee(self).base = 0
                ai.hello(self).base = 0
            end
        end,
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data then
                state = data
            end
        end
    }
}
