local version_warning = require("scripts.TamrielData.player_version_warning")
local restrict_equipment = require("scripts.TamrielData.player_restrict_equipment")
local magic = require("scripts.TamrielData.player_magic")

return {
    engineHandlers = {
        onActive = function ()
            version_warning.detectOpenMwVersionMismatchAndLogWarnings()
        end,
        onUpdate = function ()
            if magic ~= nil then
                magic.checkForAnyActiveSpells()
            end
        end
    },
    eventHandlers = {
        T_UnequipImga = restrict_equipment and restrict_equipment.T_UnequipImga,
    }
}