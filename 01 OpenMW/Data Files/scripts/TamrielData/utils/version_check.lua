local core = require('openmw.core')
local l10n = core.l10n("TamrielData")

local V = { versionSupport = {} }

V.versionSupport["restrictEquipment"] = { API_REVISION = 44 }

function V.isFunctionalitySupported(functionalityName)
    if not V.versionSupport[functionalityName] then
        error(table.concat({
            string.format("[%s][%s]: ", l10n("TamrielData_config_modName"), functionalityName),
            l10n("TamrielData_config_unknownFunctionality")
        }))
    end
    local requiredLuaApi = V.versionSupport[functionalityName].API_REVISION
    if (not core.API_REVISION) or (core.API_REVISION < requiredLuaApi) then
        print(table.concat({
            string.format("[%s][%s]: ", l10n("TamrielData_config_modName"), functionalityName),
            l10n("TamrielData_config_luaApiTooLow1"),
            requiredLuaApi,
            l10n("TamrielData_config_luaApiTooLow2"),
            core.API_REVISION,
            l10n("TamrielData_config_luaApiTooLow3")
        }))
        return false
    end
    return true
end

return V