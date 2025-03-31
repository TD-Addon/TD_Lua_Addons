local I = require('openmw.interfaces')
local storage = require('openmw.storage')

local l10nKey = 'TamrielData'
local settingsPageKey = "Settings_TamrielData_page01Main"

local S = {}

local function boolSetting(settingKey, default, storageForThisSetting)
    S[settingKey] = function() return storageForThisSetting:get(settingKey) end
    return {
        key = settingKey,
        renderer = 'checkbox',
        name = settingKey,
        description = settingKey .. '_Description',
        default = default
    }
end

I.Settings.registerPage({
    key = settingsPageKey,
    l10n = l10nKey,
    name = 'TamrielData_main_modName',
    description = settingsPageKey .. "_Description",
})

local group01StorageId = "Settings_TamrielData_page01Main_group01Main"
local group01MainPlayerStorage = storage.playerSection(group01StorageId)
I.Settings.registerGroup({
    key = group01StorageId,
    page = settingsPageKey,
    l10n = l10nKey,
    name = 'Settings_TamrielData_page01Main_group01Main',
    permanentStorage = true,
    settings = {
        boolSetting(
            'Settings_TamrielData_page01Main_group01Main_restrictEquipment',
            true,
            group01MainPlayerStorage),
    },
})

return S