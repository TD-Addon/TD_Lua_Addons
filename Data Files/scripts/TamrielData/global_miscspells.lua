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

local onStart = {
    t_mysticism_passwall = function(caster, spell, effect, track)
        if types.Player.objectIsInstance(caster) then
            track.ignore = false
            caster:sendEvent('T_Passwall_Cast', effect.magnitudeThisFrame)
        end
    end
}

I.T_ActorMagic.addEffectStartHandler(function(caster, spell, effect, track)
    local handler = onStart[effect.id]
    if handler then
        handler(caster, spell, effect, track)
    end
end)

return {
    eventHandlers = {
        T_Passwall_teleportPlayer = teleportPlayer,
    }
}
