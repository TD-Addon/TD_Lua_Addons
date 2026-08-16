local menu = require('openmw.menu')
if menu.getState() ~= menu.STATE.NoGame then
    return
end

local ui = require('openmw.ui')
local core = require('openmw.core')
local l10n = core.l10n("TamrielData")
local feature_data = require("scripts.TamrielData.utils.feature_data")
local version_check = require("scripts.TamrielData.utils.version_check")
local menu_popup = require('scripts.TamrielData.utils.menu_popup')

local function listEnabledButUnsupportedFeatures()
    local result = {}
    for featureName, _ in pairs(feature_data) do
        if version_check.isFeatureEnabled(featureName) and not version_check.isFeatureSupported(featureName) then
            table.insert(result, featureName)
        end
    end
    return result
end

if core.contentFiles and not core.contentFiles.has("Tamriel_Data.esm") then
    menu_popup.popup(l10n("TamrielData_main_modName"), l10n("TamrielData_main_noEsmLoaded"))
end

xpcall(
    function()
        require('MWSE.mods.TamrielData.magicdata')
    end,
    function()
        menu_popup.popup(l10n("TamrielData_main_mwseLuaMissing_Header"), l10n("TamrielData_main_mwseLuaMissing_Description"))
    end)

local wrongFeatures = listEnabledButUnsupportedFeatures()
if #wrongFeatures > 0 then
    local featuresWithApiMissing = ""
    for _, name in pairs(wrongFeatures) do
        featuresWithApiMissing = featuresWithApiMissing .. string.format(
            "\n- %s (%s)",
            name,
            feature_data[name].requiredLuaApi)
    end
    menu_popup.popup(l10n("TamrielData_main_luaVersionMismatch_Header"), l10n("TamrielData_main_luaVersionMismatch_Description", { currentRevision = core.API_REVISION, features = featuresWithApiMissing }))
end