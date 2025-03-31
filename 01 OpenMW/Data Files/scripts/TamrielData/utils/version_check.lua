local core = require('openmw.core')

local V = { versionSupport = {} }

V.versionSupport["restrictEquipment"] = { API_REVISION = 44 }

function V.isFunctionalitySupported(functionalityName)
    if not V.versionSupport[functionalityName] then
        error(string.format("[Tamriel Data] Unknown functionality \"%s\"", functionalityName))
    end
    local requiredLuaApi = V.versionSupport[functionalityName].API_REVISION
    if (not core.API_REVISION) or (core.API_REVISION < requiredLuaApi) then
        print(string.format(
            "[Tamriel Data][%s]: functionality disabled, because it requires OpenMW 0.49+ with Lua API_REVISION %s or higher (you have %s). Consider updating OpenMW or turn the option off in Options > Scripts > Tamriel Data",
            functionalityName,
            requiredLuaApi,
            core.API_REVISION
        ))
        return false
    end
    return true
end

return V