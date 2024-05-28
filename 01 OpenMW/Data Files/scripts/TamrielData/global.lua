local types = require('openmw.types')
local I = require('openmw.interfaces')

-- Store the item record here
local record

-- Equip slots for the items we want to check
local helmetSlot = types.NPC.EQUIPMENT_SLOT.Helmet
local bootsSlot = types.NPC.EQUIPMENT_SLOT.Boots

I.ItemUsage.addHandlerForType(types.Armor, function(armor, actor)
    -- Sanity checks, then check if we're Imga
    if not armor then return end
    if types.NPC.record(actor).race ~= "T_Val_Imga" then return end

    -- Get the item record
    record = types.Armor.record(armor)

    -- If it's boots or helmets, send event to actor that equipped it
    if record.type == types.Armor.TYPE.Boots then
        actor:sendEvent("tdSetEquipment", bootsSlot)
    elseif record.type == types.Armor.TYPE.Helmet and types.NPC.record(actor).isMale then
        actor:sendEvent("tdSetEquipment", helmetSlot)
    end

end)

I.ItemUsage.addHandlerForType(types.Clothing, function(clothing, actor)
    -- Sanity checks, then check if we're Imga
    if not clothing then return end
    if types.NPC.record(actor).race ~= "T_Val_Imga" then return end

    -- Get the item record
    record = types.Clothing.record(clothing)

    -- If it's shoes, send event to actor that equipped it
    if record.type == types.Clothing.TYPE.Shoes then
        actor:sendEvent("tdSetEquipment", bootsSlot)
    end

end)


return {
}
