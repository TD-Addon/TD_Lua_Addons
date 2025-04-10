if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("miscSpells") then
    return
end

local time = require('openmw_aux.time')
local world = require('openmw.world')
local types = require('openmw.types')

-- List of spells the global script should check for if they're active for the player
local spellIdToGlobalPlayerEvent = {}
spellIdToGlobalPlayerEvent["t_com_mys_uni_passwall"] = "T_Passwall_playerCast"


local function makeInitialValuesOfSpellHandledStates()
    local result = {}
    for spellId, _ in pairs(spellIdToGlobalPlayerEvent) do
        result[spellId] = false
    end
    return result
end
local isSpellAlreadyBeingHandled = makeInitialValuesOfSpellHandledStates()

local function handleSpellWithPlayerEvent(spell, player)
    for expected_spell_id, spell_event in pairs(spellIdToGlobalPlayerEvent) do
        if spell.id == expected_spell_id then
            if not isSpellAlreadyBeingHandled[spell.id] then
                player:sendEvent(spell_event, {})
                isSpellAlreadyBeingHandled[spell.id] = true
            end
            return
        end
    end
end

-- Check for active spells on the player every 0.X seconds and react if a Lua spell is found
local stopFn = time.runRepeatedly(function()
        local player = world.players[1]
        if player ~= nil then
            for _, spell in pairs(types.Actor.activeSpells(player)) do
                handleSpellWithPlayerEvent(spell, player)
            end
        end
    end,
    0.03 * time.second)

-- Once the spell's player script reports that it finished handling, mark it here also
local function onSpellHandlingFinished(data)
    if not data.spellId then return end
    isSpellAlreadyBeingHandled[data.spellId] = false
end

return {
    eventHandlers = {
        T_magic_spellHandlingFinished = onSpellHandlingFinished,
    }
}