local version_warning = require("scripts.TamrielData.version_warning")
local restrict_equipment = require("scripts.TamrielData.restrict_equipment")

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