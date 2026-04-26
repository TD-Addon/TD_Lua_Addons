local core = require('openmw.core')

if not core.magic.effects.records['T_summon_Devourer'] and not core.magic.effects.records['T_conjuration_SanguineRose'] then
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
    summons = {},
    corruption = {},
    corruptionSummons = {}
}

local function toKey(actor, id, index)
    return actor.id .. ',' .. id .. ',' .. index
end

local function getSummon(effectId, caster)
    if effectId == 't_conjuration_sanguinerose' then
        return magicData.sanguineRoseDaedra[math.random(#magicData.sanguineRoseDaedra)]
    elseif effectId == 't_conjuration_corruptionsummon' then
        local target = state.corruption[caster.id]
        return target and target.id or 'T_Glb_Cre_Gremlin_01', effectId
    end
    return summons[effectId]
end

I.T_ActorMagic.addEffectStartHandler(function(caster, spell, effect, track)
    local creature, tag = getSummon(effect.id, caster)
    if not creature then
        return
    end
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(caster, id, index)
    state.summons[key] = { id = id, index = index, creatureId = creature, actor = caster, tag = tag }
    caster:sendEvent('T_GetSummonPosition', { key = key })
    track.ignore = false
end)

local function unsummon(creature)
    if creature:isValid() then
        state.corruptionSummons[creature.id] = nil
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

local function blockActivation()
    return false
end

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
                local corruption = {}
                for _, actorData in pairs(data.corruption) do
                    if actorData.actor:isValid() then
                        corruption[actorData.actor.id] = actorData
                    end
                end
                state.corruption = corruption
                local corruptionSummons = {}
                for _, actor in pairs(data.corruptionSummons) do
                    if actor:isValid() then
                        corruptionSummons[actor.id] = actor
                    end
                end
                state.corruptionSummons = corruptionSummons
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
            creature:sendEvent('T_MarkSummon', { index = effect.index, id = effect.id, caster = caster, tag = effect.tag })
            creature:sendEvent('AddVfx', { model = startVfx })
            effect.creatureId = nil
            effect.creature = creature
            if effect.tag == 't_conjuration_corruptionsummon' then
                state.corruptionSummons[creature.id] = creature
                I.Activation.addHandlerForObject(creature, blockActivation)
            end
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
    },
    interfaceName = 'T_SummonMagic',
    interface = {
        version = 1,
        setCorruptedId = function(caster, id)
            if id then
                state.corruption[caster.id] = { actor = caster, id = id }
            else
                state.corruption[caster.id] = nil
            end
        end,
        isCorruptionSummon = function(actor)
            return state.corruptionSummons[actor.id] or false
        end
    }
}
