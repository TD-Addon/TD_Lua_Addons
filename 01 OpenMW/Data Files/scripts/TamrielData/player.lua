local version_warning = require("scripts.TamrielData.player_version_warning")
local restrict_equipment = require("scripts.TamrielData.player_restrict_equipment")

return {
    engineHandlers = {
        onActive = function ()
            version_warning.detectOpenMwVersionMismatchAndLogWarnings()
        end
    },
    eventHandlers = {
        T_UnequipImga = restrict_equipment and restrict_equipment.T_UnequipImga,
    }
}