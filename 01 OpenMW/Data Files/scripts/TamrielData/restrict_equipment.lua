if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("restrictEquipment") then
    return
end

local core = require('openmw.core')
local types = require('openmw.types')
local I = require('openmw.interfaces')
local self = require("openmw.self")
local ui = require("openmw.ui")
local l10n = core.l10n("TamrielData")
local settings = require("scripts.TamrielData.utils.settings")

local BOOTS_MESSAGE = core.getGMST('sNotifyMessage14')
local SHOES_MESSAGE = core.getGMST('sNotifyMessage15')

local RE = {}

function RE.T_UnequipImga(equipType)
    if not settings.isFeatureEnabled["restrictEquipment"]() then
        return
    end

    -- Get current equipment, give actor the new equipment set
    local equipped = types.Actor.equipment(self)

    if equipType == types.Armor.TYPE.Boots then
        equipped[types.NPC.EQUIPMENT_SLOT.Boots] = nil
        ui.showMessage(BOOTS_MESSAGE)
    elseif equipType == types.Armor.TYPE.Helmet then
        equipped[types.NPC.EQUIPMENT_SLOT.Helmet] = nil
        ui.showMessage(l10n("TamrielData_main_imgaHelm"))
    elseif equipType == types.Clothing.TYPE.Shoes then
        equipped[types.NPC.EQUIPMENT_SLOT.Boots] = nil
        ui.showMessage(SHOES_MESSAGE)
    end

    types.Actor.setEquipment(self, equipped)

    -- Refresh UI since otherwise the player would see the item equipped on the paperdoll
    local currentMode = I.UI.getMode()
    I.UI.setMode()
    I.UI.setMode(currentMode)
end

return RE
