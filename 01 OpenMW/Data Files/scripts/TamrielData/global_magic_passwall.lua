if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("miscSpells") then
    return
end

local core = require('openmw.core')
local types = require('openmw.types')
local world = require('openmw.world')
local crimes = require('openmw.interfaces').Crimes

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
        (ownerData.factionId and types.NPC.getFactionRank(data.player, ownerData.factionId) < ownerData.factionRank)

    if isTrespassing then
        crimes.commitCrime(
            data.player,
            {
                faction = ownerData.factionId,
                type = types.Player.OFFENSE_TYPE.Trespassing
            }
        )
    end
end

local function teleportPlayer(data)
    local teleportOptions = { onGround = true }
    if data.rotation then
        teleportOptions.rotation = data.rotation
    end
    data.player:teleport(data.cell, data.position, teleportOptions)

    triggerCrimeIfTrespassing(data)

    local effect = core.magic.effects.records[core.magic.EFFECT_TYPE.Open]
    local passwall_target_effect_model = types.Static.record(effect.hitStatic).model
    world.vfx.spawn(passwall_target_effect_model, data.position)
end

return {
    eventHandlers = {
        T_Passwall_teleportPlayer = teleportPlayer,
    }
}
