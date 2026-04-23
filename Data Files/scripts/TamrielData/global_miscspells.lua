local core = require('openmw.core')
local passwallEffect = core.magic.effects.records['T_mysticism_Passwall']

if not passwallEffect then
    return
end

local I = require('openmw.interfaces')
local types = require('openmw.types')
local world = require('openmw.world')

local passwall_target_effect_model = types.Static.records[passwallEffect.hitStatic].model

local function triggerCrimeIfTrespassing(data)
    if not data.targetObject or not data.targetObject.owner or not types.Lockable.isLocked(data.targetObject) then
        return
    end

    if data.targetObject.globalVariable and world.mwscript.getGlobalVariables(data.player)[data.targetObject.globalVariable] ~= 0 then
        return
    end

    local ownerData = data.targetObject.owner

    local isTrespassing =
        ownerData.recordId
        or
        (ownerData.factionId and types.NPC.getFactionRank(data.player, ownerData.factionId) == 0)
        or
        (ownerData.factionId and types.NPC.getFactionRank(data.player, ownerData.factionId) < (ownerData.factionRank or 1))

    if isTrespassing then
        I.Crimes.commitCrime(
            data.player,
            {
                faction = ownerData.factionId,
                type = types.Player.OFFENSE_TYPE.Trespassing
            }
        )
    end
end

local function teleportPlayer(data)
    data.player:teleport(data.cell, data.position, { onGround = true, rotation = data.rotation })

    triggerCrimeIfTrespassing(data)

    world.vfx.spawn(passwall_target_effect_model, data.position)
end

local function toKey(actor, id, index)
    return actor.id .. ',' .. id .. ',' .. index
end

local state = {
    effects = {}
}

local function store(target, spell, effect)
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(target, id, index)
    state.effects[key] = { id = id, index = index, actor = target, magnitude = effect.magnitudeThisFrame, effect = effect.id }
end

local onStart = {
    t_mysticism_passwall = function(target, spell, effect, track)
        if types.Player.objectIsInstance(target) then
            track.ignore = false
            target:sendEvent('T_Passwall_Cast', effect.magnitudeThisFrame)
        end
    end,
    t_mysticism_reflectdmg = function(target, spell, effect, track)
        track.ignore = false
    end,
    t_restoration_fortifycasting = function(target, spell, effect, track)
        local activeEffects = target.type.activeEffects(target)
        activeEffects:modify(-effect.magnitudeThisFrame, 'sound')
        store(target, spell, effect)
        track.ignore = false
    end,
}

local onEnd = {
    t_restoration_fortifycasting = function(effect)
        local activeEffects = effect.actor.type.activeEffects(effect.actor)
        activeEffects:modify(effect.magnitude, 'sound')
    end
}

I.T_ActorMagic.addEffectStartHandler(function(target, spell, effect, track)
    local handler = onStart[effect.id]
    if handler then
        handler(target, spell, effect, track)
    end
end)

I.T_ActorMagic.addEffectEndHandler(function(actor, id, index)
    local key = toKey(actor, id, index)
    local effect = state.effects[key]
    if effect then
        local handler = onEnd[effect.effect]
        if handler then
            handler(effect)
        end
        state.effects[key] = nil
    end
end)

return {
    engineHandlers = {
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data then
                state = data
                local effects = {}
                for _, actorData in pairs(data.effects) do
                    if actorData.actor:isValid() then
                        local key = toKey(actorData.actor, actorData.id, actorData.index)
                        effects[key] = actorData
                    end
                end
                state.effects = effects
            end
        end
    },
    eventHandlers = {
        T_Passwall_teleportPlayer = teleportPlayer,
    }
}
