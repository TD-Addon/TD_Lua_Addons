local ui = require('openmw.ui')
local core = require('openmw.core')
local l10n = core.l10n("TamrielData")
local feature_data = require("scripts.TamrielData.utils.feature_data")
local version_check = require("scripts.TamrielData.utils.version_check")
local settings = require("scripts.TamrielData.utils.settings")

local function listEnabledButUnsupportedFeatures()
    local featureNames = feature_data.getFeatureNames()
    local result = {}
    for _, name in pairs(featureNames) do
        if settings.isFeatureEnabled[name]() and not version_check.isFeatureSupported(name) then
            table.insert(result, name)
        end
    end
    return result
end

local VW = {}

function VW.detectOpenMwVersionMismatchAndLogWarnings()
    if core.contentFiles and not core.contentFiles.has("Tamriel_Data.esm") then
        error(string.format("[%s]: %s", l10n("TamrielData_main_modName"), l10n("TamrielData_main_noEsmLoaded")))
    end

    local wrongFeatures = listEnabledButUnsupportedFeatures()
    if #wrongFeatures > 0 then
        for _, name in pairs(wrongFeatures) do
            print(table.concat({
                string.format("[%s][%s]: ", l10n("TamrielData_main_modName"), name),
                l10n("TamrielData_main_luaApiTooLow1"),
                feature_data.get(name).requiredLuaApi,
                l10n("TamrielData_main_luaApiTooLow2"),
                core.API_REVISION,
                l10n("TamrielData_main_luaApiTooLow3")
            }))
        end
        ui.showMessage(string.format("%s: %s", l10n("TamrielData_main_modName"), l10n("TamrielData_main_publicVersionMismatchWarning")))
    end
end

return VW