local core = require('openmw.core')
local self = require('openmw.self')

local state

local timer = math.random()

return {
    engineHandlers = {
        onInit = function(light)
            state = light
        end,
        onSave = function()
            return state
        end,
        onLoad = function(data)
            state = data
        end,
        onUpdate = function(dt)
            timer = timer + dt
            if timer < 1 then
                return
            end
            timer = timer - 1
            for _, item in pairs(self.type.inventory(self):getAll()) do
                return
            end
            core.sendGlobalEvent('T_BanishContainer', { container = self.object, light = state })
        end
    }
}
