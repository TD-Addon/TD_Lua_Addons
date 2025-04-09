local version_warning = require("scripts.TamrielData.player_version_warning")
local restrict_equipment = require("scripts.TamrielData.player_restrict_equipment")
local magic_passwall = require("scripts.TamrielData.player_magic_passwall")

return {
    engineHandlers = {
        onActive = function ()
            version_warning.detectOpenMwVersionMismatchAndLogWarnings()
        end
    },
    eventHandlers = {
        T_UnequipImga = restrict_equipment and restrict_equipment.T_UnequipImga,
        T_Passwall_playerCast = magic_passwall and magic_passwall.onCastPasswall,
    }
}