local types = require('openmw.types')
local self = require('openmw.self')
local settings = require("scripts.TamrielData.utils.settings")
local magic_passwall = require("scripts.TamrielData.player_magic_passwall")

local checkFrequency = 30 -- No need to check for magic that often
local checkCounter = checkFrequency

local PM = {}

function PM.checkForAnyActiveSpells()
    checkCounter = checkCounter - 1
    if checkCounter > 0 then
        return
    end
    checkCounter = checkFrequency
    for _, spell in pairs(types.Actor.activeSpells(self)) do
        if spell.id == "t_com_mys_uni_passwall" then
            if settings.isFeatureEnabled["miscSpells"]() then
                types.Actor.activeSpells(self):remove(spell.activeSpellId)
                if magic_passwall then
                    magic_passwall.onCastPasswall()
                end
            end
        end
    end
end

return PM