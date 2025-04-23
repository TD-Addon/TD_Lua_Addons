-- Responsible for setting a special global variable in game, so that TD-using mods
-- (like Tamriel Rebuilt) can check if this Lua Addon is used in mwscripts (by checking if it's >0).
-- The value is set to core.API_REVISION for the player entering the game.
-- This feature is always on.

local world = require('openmw.world')
local core = require('openmw.core')
local types = require('openmw.types')
local l10n = core.l10n("TamrielData")

local globalVariableName = "OPENMW_TDLUA"

local function setGlobalVariable(player)
    if not world or not world.mwscript or not core.API_REVISION or core.API_REVISION < 51 then return end

    local globalVariables = world.mwscript.getGlobalVariables(player)

    if globalVariables[globalVariableName] ~= nil then
        globalVariables[globalVariableName] = core.API_REVISION
    else
        error(string.format(
            "[%s][%s]: %s",
            l10n("TamrielData_main_modName"),
            types.Player.record(player).name,
            l10n("TamrielData_main_globalVariableNotDetected", { luaAddonGlobalVariableName = globalVariableName })
        ))
    end
end

return {
    engineHandlers = {
        onPlayerAdded = setGlobalVariable
    },
}