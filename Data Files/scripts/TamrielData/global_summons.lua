local core = require('openmw.core')

if not core.magic.effects.records['T_summon_Devourer'] then
    return
end

local I = require('openmw.interfaces')
local types = require('openmw.types')
local world = require('openmw.world')
local magicData = require('MWSE.mods.TamrielData.magicdata')

local summons = {}
for _, values in pairs(magicData.td_summon_effects) do
    summons[values[1]:lower()] = values[3]
end
local startVfx = types.Static.records['VFX_Summon_Start'].model
local endVfx = types.Static.records['VFX_Summon_End'].model

local state = {
    summons = {}
}

local function toKey(actor, id, index)
    return actor.id .. ',' .. id .. ',' .. index
end

I.T_ActorMagic.addEffectStartHandler(function(caster, spell, effect, track)
    local creature = summons[effect.id]
    if not creature then
        return
    end
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(caster, id, index)
    state.summons[key] = { id = id, index = index, creatureId = creature, actor = caster }
    caster:sendEvent('T_GetSummonPosition', { key = key })
    track.ignore = false
end)

local function unsummon(creature)
    if creature:isValid() then
        world.vfx.spawn(startVfx, creature.position)
        creature:remove()
    end
end

I.T_ActorMagic.addEffectEndHandler(function(actor, id, index)
    local key = toKey(actor, id, index)
    local summon = state.summons[key]
    if not summon then
        return
    end
    local creature = summon.creature
    if creature then
        unsummon(creature)
    end
    state.summons[key] = nil
end)

return {
    engineHandlers = {
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data then
                state = data
                local summons = {}
                for _, actorData in pairs(data.summons) do
                    if actorData.actor:isValid() then
                        local key = toKey(actorData.actor, actorData.id, actorData.index)
                        summons[key] = actorData
                    elseif actorData.creature then
                        unsummon(actorData.creature)
                    end
                end
                state.summons = summons
            end
        end
    },
    eventHandlers = {
        T_Summon = function(data)
            local effect = state.summons[data.key]
            if not effect then
                return
            end
            local creature = world.createObject(effect.creatureId)
            local caster = effect.actor
            creature:teleport(caster.cell.name, data.position, { onGround = true })
            creature:sendEvent('StartAIPackage', { type = 'Follow', target = caster })
            creature:sendEvent('T_MarkSummon', { index = effect.index, id = effect.id, caster = caster })
            creature:sendEvent('AddVfx', { model = startVfx })
            effect.creatureId = nil
            effect.creature = creature
        end,
        T_Unsummon = function(data)
            unsummon(data.creature)
            local key = toKey(data.caster, data.id, data.index)
            local effect = state.summons[key]
            if effect then
                state.summons[key] = nil
                I.T_ActorMagic.removeEffect(data.caster, effect.id, effect.index)
            end
        end
    }
}
