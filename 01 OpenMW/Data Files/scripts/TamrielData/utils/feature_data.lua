local features = {}

-- List of features which can be turned on or off in settings or which require a specific OpenMW version.
--  > requiredLuaApi is a minimum required core.API_REVISION number.
--  > settingsKey is a unique key for this feature in settings.lua and l10n.

features["restrictEquipment"] = {
    requiredLuaApi = 44,
    settingsKey = "Settings_TamrielData_page01Main_group01Main_restrictEquipment"
}
features["miscSpells"] = {
    requiredLuaApi = 71,
    settingsKey = "Settings_TamrielData_page01Main_group02Magic_miscSpells"
}

local F = {}

local l10n = require('openmw.core').l10n("TamrielData")

function F.get(featureName)
    if not features[featureName] then
        error(table.concat({
            string.format("[%s][%s]: ", l10n("TamrielData_main_modName"), featureName),
            l10n("TamrielData_main_unknownFeature")
        }))
        return
    end
    return features[featureName]
end

function F.getFeatureNames()
    local names = {}
    for featureName, _ in pairs(features) do
        table.insert(names, featureName)
    end
    return names
end

return F