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
    state.summons[key] = { id = id, index = index, creatureId = creature }
    caster:sendEvent('T_GetSummonPosition', { key = key })
    track.ignore = false
end)

local function unsummon(creature)
    creature.enabled = false
    world.vfx.spawn(startVfx, creature.position)
end

I.T_ActorMagic.addEffectEndHandler(function(actor, id, index)
    local key = toKey(actor, id, index)
    local summon = state.summons[key]
    if not summon then
        return
    end
    local creature = summon.creature
    if creature and creature:isValid() then
        unsummon(creature)
    end
    state.summons[key] = nil
end)

return {
    eventHandlers = {
        T_Summon = function(data)
            local effect = state.summons[data.key]
            if not effect then
                return
            end
            local creature = world.createObject(effect.creatureId)
            local caster = data.caster
            creature:teleport(caster.cell.name, data.position, { onGround = true })
            creature:sendEvent('StartAIPackage', { type = 'Follow', target = caster })
            creature:sendEvent('T_MarkSummon', { key = data.key, caster = caster })
            creature:sendEvent('AddVfx', { model = startVfx })
            effect.creatureId = nil
            effect.creature = creature
        end,
        T_Unsummon = function(data)
            unsummon(data.creature)
            local effect = state.summons[data.key]
            if effect then
                state.summons[data.key] = nil
                I.T_ActorMagic.removeEffect(data.caster, effect.id, effect.index)
            end
        end
    }
}
