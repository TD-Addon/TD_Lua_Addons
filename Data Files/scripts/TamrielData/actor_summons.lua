local core = require('openmw.core')

if core.API_REVISION < 125 then
    return
end

local I = require('openmw.interfaces')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local util = require('openmw.util')
local magicData = require('MWSE.mods.TamrielData.magicdata')

local summons = {}
for _, values in pairs(magicData.td_summon_effects) do
    summons[values[1]:lower()] = values[3]
end

local state = {
    summons = {}
}

local function toKey(id, index)
    return id .. ',' .. index
end

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

I.T_ActorMagic.addEffectStartHandler(function(spell, effect, track)
    local creature = summons[effect.id]
    if creature == nil then
        return
    end
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(id, index)
    state.summons[key] = { id = id, index = index }
    core.sendGlobalEvent('T_Summon', { key = key, creature = creature, caster = self.object, position = getSafeSpawn() })
    track.ignore = false
end)

I.T_ActorMagic.addEffectEndHandler(function(id, index)
    local key = toKey(id, index)
    local summon = state.summons[key]
    if summon == nil then
        return
    end
    local creature = summon.creature
    if creature and creature:isValid() then
        core.sendGlobalEvent('T_Unsummon', { creature = creature })
    end
    state.summons[key] = nil
end)

return {
    eventHandlers = {
        T_Summoned = function(data)
            local summon = state.summons[data.key]
            if summon == nil then
                summon = {}
                state.summons[data.key] = summon
            end
            summon.creature = data.creature
        end,
        T_SummonDied = function(data)
            local summon = state.summons[data.key]
            if summon ~= nil and summon.id ~= nil and summon.index ~= nil then
                I.T_ActorMagic.removeEffect(summon.id, summon.index)
            end
        end,
        T_MarkSummon = function(data)
            state.caster = data.caster
            state.key = data.key
            self.type.stats.ai.fight(self).base = 30 -- we should probably be using dedicated creature variants
        end,
        Died = function()
            if state.key ~= nil then
                core.sendGlobalEvent('T_Unsummon', { creature = self.object })
                if state.caster:isValid() then
                    state.caster:sendEvent('T_SummonDied', { key = state.key })
                end
            end
        end
    },
    engineHandlers = {
        onSave = function()
            return state
        end,
        onLoad = function(data)
            state = data
        end
    }
}
