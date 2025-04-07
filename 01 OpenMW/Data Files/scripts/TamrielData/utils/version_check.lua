local core = require('openmw.core')
local feature_data = require("scripts.TamrielData.utils.feature_data")

local V = { }

function V.isFeatureSupported(featureName)
    return core.API_REVISION and core.API_REVISION >= feature_data.get(featureName).requiredLuaApi
end

return V