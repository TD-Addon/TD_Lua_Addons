local core = require('openmw.core')

if not core.magic.effects.records['T_summon_Devourer'] then
    return
end

local I = require('openmw.interfaces')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local util = require('openmw.util')

local FRONT = 0
local BACK = 3
local LEFT = 2
local RIGHT = 1
local collisionType = nearby.COLLISION_TYPE.World + nearby.COLLISION_TYPE.Door

local function getSafeSpawn()
    local origin = self.position + util.vector3(0, 0, 20)
    local rotation = util.transform.rotateZ(self.rotation:getYaw())
    for direction = FRONT,BACK do
        local spawn
        if direction == FRONT then
            spawn = origin + rotation:apply(util.vector3(0, 120, 10))
        elseif direction == BACK then
            spawn = origin - rotation:apply(util.vector3(0, 120, 10))
        elseif direction == LEFT then
            spawn = origin - rotation:apply(util.vector3(120, 0, 10))
        elseif direction == RIGHT then
            spawn = origin + rotation:apply(util.vector3(120, 0, 10))
        end
        local result = nearby.castRay(spawn, origin, { collisionType = collisionType })
        if not result.hit then
            return spawn
        end
    end
    return origin
end

local state = {}

return {
    eventHandlers = {
        T_GetSummonPosition = function(data)
            local position = getSafeSpawn()
            data.position = position
            data.caster = self.object
            core.sendGlobalEvent('T_Summon', data)
        end,
        T_MarkSummon = function(data)
            state.caster = data.caster
            state.key = data.key
            self.type.stats.ai.fight(self).base = 30 -- we should probably be using dedicated creature variants
        end,
        Died = function()
            if state.key ~= nil then
                core.sendGlobalEvent('T_Unsummon', { creature = self.object, caster = state.caster, key = state.key })
            end
        end
    },
    engineHandlers = {
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
