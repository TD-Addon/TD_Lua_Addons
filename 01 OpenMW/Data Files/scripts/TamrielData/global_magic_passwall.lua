if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("miscSpells") then
    return
end

local core = require('openmw.core')
local types = require('openmw.types')
local world = require('openmw.world')
local crimes = require('openmw.interfaces').Crimes

local function triggerCrimeIfTrespassing(data)
    if not data.targetObjectOwnership then
        return
    end

    local isTrespassing =
        data.targetObjectOwnership.recordId
        or
        (data.targetObjectOwnership.factionId and types.NPC.getFactionRank(data.player, data.targetObjectOwnership.factionId) == 0)
        or
        (data.targetObjectOwnership.factionId and types.NPC.getFactionRank(data.player, data.targetObjectOwnership.factionId) < data.targetObjectOwnership.factionRank)

    if isTrespassing then
        crimes.commitCrime(
            data.player,
            {
                faction = data.targetObjectOwnership.factionId,
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
