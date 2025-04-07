if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("miscSpells") then
    return
end

local time = require('openmw_aux.time')
local world = require('openmw.world')
local types = require('openmw.types')

-- List of spells the global script should check for if they're active for the player
local spellIdToGlobalPlayerEvent = {}
spellIdToGlobalPlayerEvent["T_Com_Mys_UNI_Passwall"] = "T_Passwall_playerCast"


local function makeInitialValuesOfSpellHandledStates()
    local result = {}
    for spellId, _ in pairs(spellIdToGlobalPlayerEvent) do
        result[string.lower(spellId)] = false
    end
    return result
end
local isSpellAlreadyBeingHandled = makeInitialValuesOfSpellHandledStates()

local function handleSpellWithPlayerEvent(spell, player)
    for expected_spell_id, spell_event in pairs(spellIdToGlobalPlayerEvent) do
        if spell.id == string.lower(expected_spell_id) then
            if not isSpellAlreadyBeingHandled[string.lower(spell.id)] then
                player:sendEvent(spell_event, {})
                isSpellAlreadyBeingHandled[spell.id] = true
            end
            return
        end
    end
end

-- Check for active spells on the player every 0.01 second and react if a Lua spell is found
local stopFn = time.runRepeatedly(function()
        local player = world.players[1]
        if player ~= nil then
            for _, spell in pairs(types.Actor.activeSpells(player)) do
                handleSpellWithPlayerEvent(spell, player)
            end
        end
    end,
    0.01 * time.second)

local function onSpellHandlingFinished(data)
    if not data.spellId then return end
    isSpellAlreadyBeingHandled[string.lower(data.spellId)] = false
end

return {
    eventHandlers = {
        T_magic_spellHandlingFinished = onSpellHandlingFinished,
    }
}