local core = require('openmw.core')
local storage = require('openmw.storage')
local feature_data = require("scripts.TamrielData.utils.feature_data")

local V = { }

function V.isFeatureSupported(featureName)
    return core.API_REVISION and feature_data[featureName] and core.API_REVISION >= feature_data[featureName].requiredLuaApi
end

function V.isFeatureEnabled(featureName)
    local feature = feature_data[featureName]
    if not feature then
        return
    end
    local featureSettingsStorage = storage.playerSection(feature.settingsPlayerSectionStorageId)
    local value = featureSettingsStorage and featureSettingsStorage:get(feature.settingsKey)
    if value == nil then
        return feature.settingsEnabledByDefault
    end
    return value
end

return V