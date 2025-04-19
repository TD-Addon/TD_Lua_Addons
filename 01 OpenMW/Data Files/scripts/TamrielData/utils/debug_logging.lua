if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("debugLogging") then
    return
end

-- Use from player scripts

local settings = require("scripts.TamrielData.utils.settings")
local l10n = require('openmw.core').l10n("TamrielData")

local DL = {}

function DL.log(text, scopeName)
    if not settings.isFeatureEnabled["debugLogging"]() then return end

    print(string.format(
        "[%s][%s]: %s",
        l10n("TamrielData_main_modName"),
        scopeName or "",
        text))
end

return DL