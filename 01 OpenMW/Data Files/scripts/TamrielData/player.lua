local types = require('openmw.types')
local I = require('openmw.interfaces')
local self = require("openmw.self")
local ui = require("openmw.ui")

local function T_UnequipImga(equipSlot)
    -- Get current equipment, give actor the new equipment set
    local equipped = types.Actor.equipment(self)
    equipped[equipSlot] = nil
    types.Actor.setEquipment(self, equipped)

    -- Check what slot do we want to unequip, then unequip it
    if equipSlot == types.NPC.EQUIPMENT_SLOT.Boots then
        ui.showMessage("Imga cannot wear boots.")
    elseif equipSlot == types.NPC.EQUIPMENT_SLOT.Helmet then
        ui.showMessage("Male Imga cannot wear helmets.")
    end

    -- Refresh UI since otherwise the player would see the item equipped on the paperdoll
    local currentMode =  I.UI.getMode()
    I.UI.setMode()
    I.UI.setMode(currentMode)
end

return {
eventHandlers = {
    T_UnequipImga = T_UnequipImga,
}
}