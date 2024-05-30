local types = require('openmw.types')
local I = require('openmw.interfaces')

-- Store the item record here
local record

-- Equip slots for the items we want to check
local helmetSlot = types.Player.EQUIPMENT_SLOT.Helmet
local bootsSlot = types.Player.EQUIPMENT_SLOT.Boots

I.ItemUsage.addHandlerForType(types.Armor, function(armor, actor)
    -- Sanity checks, then check if we're Imga
    if not armor then return end
    if not types.Player.objectIsInstance(actor) then return end
    if types.Player.record(actor).race ~= "t_val_imga" then return end

    -- Get the item record
    record = types.Armor.record(armor)

    -- If it's boots or helmets, send event to actor that equipped it
    if record.type == types.Armor.TYPE.Boots then
        actor:sendEvent("T_UnequipImga", bootsSlot)
    elseif record.type == types.Armor.TYPE.Helmet and types.Player.record(actor).isMale then
        actor:sendEvent("T_UnequipImga", helmetSlot)
    end

end)

I.ItemUsage.addHandlerForType(types.Clothing, function(clothing, actor)
    -- Sanity checks, then check if we're Imga
    if not clothing then return end
    if not types.Player.objectIsInstance(actor) then return end
    if types.Player.record(actor).race ~= "t_val_imga" then return end

    -- Get the item record
    record = types.Clothing.record(clothing)

    -- If it's shoes, send event to actor that equipped it
    if record.type == types.Clothing.TYPE.Shoes then
        actor:sendEvent("T_UnequipImga", bootsSlot)
    end

end)
