local types = require('openmw.types')
local I = require('openmw.interfaces')
local self = require("openmw.self")
local ui = require("openmw.ui")

local function tdSetEquipment(equipSlot)
    -- Get current equipment
    local equipped = types.Actor.equipment(self)

    -- Check what slot do we want to unequip, then unequip it
    if equipSlot == types.NPC.EQUIPMENT_SLOT.Boots then
        equipped[types.Actor.EQUIPMENT_SLOT.Boots] = nil
        ui.showMessage("Imga can't wear boots.")
    elseif equipSlot == types.NPC.EQUIPMENT_SLOT.Helmet then
        equipped[types.Actor.EQUIPMENT_SLOT.Helmet] = nil
        ui.showMessage("Male Imga can't wear helmets.")
    end
    
    -- Give actor the new equipment set
    types.Actor.setEquipment(self, equipped)

    -- Refresh UI since otherwise the player would see the item equipped on the paperdoll
    local currentMode =  I.UI.getMode()
    I.UI.setMode()
    I.UI.setMode(currentMode)
end

return {
eventHandlers = {
    tdSetEquipment = tdSetEquipment,
}
}