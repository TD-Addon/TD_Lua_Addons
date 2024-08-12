--[[
	Tamriel Data MWSE-Lua Addon v1.2
	By mort and Kynesifnar
]]

-- Make sure we have an up-to-date version of MWSE.
if (mwse.buildDate == nil) or (mwse.buildDate < 20240806) then
    event.register(tes3.event.initialized, function()
        tes3.messageBox(
            "[Tamriel Data] Your MWSE is out of date!"
            .. " You will need to update to a more recent version to use this mod."
        )
    end)
    return
end

local common = require("tamrielData.common")
local config = require("tamrielData.config")
local magic = require("tamrielData.magic")
mwse.log("[Tamriel Data MWSE-Lua] Initialized Version 1.2")

-- item id, pickup sound id, putdown sound id, equip sound id
local item_sounds = {	
	{ "T_Imp_Subst_Blackdrake_01", "Item Misc Up", "Item Misc Down", "T_SndObj_DrugSniff"},
	{ "T_De_Subst_Greydust_01", "Item Misc Up", "Item Misc Down", "T_SndObj_DrugSniff"},
	{ "T_Nor_Subst_WasabiPaste_01", "Item Misc Up", "Item Misc Down", "Swallow"},
	{ "T_Imp_Subst_Aegrotat_01", "Item Misc Up", "Item Misc Down", "Swallow"},
	{ "T_De_Drink_PunavitResin_01", "Item Misc Up", "Item Misc Down", "Swallow"},
	{ "T_Com_Subst_Perfume_01", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Com_Subst_Perfume_02", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Com_Subst_Perfume_03", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Com_Subst_Perfume_04", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Com_Subst_Perfume_05", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Com_Subst_Perfume_06", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"}
}

-- region id, xcell left bound, xcell right bound, ycell top bound, ycell bottom bound
local almsivi_intervention_regions = {
	{ "Aanthirin Region", nil, nil, nil, nil },
	{ "Alt Orethan Region", nil, nil, nil, nil },
	{ "Armun Ashlands Region", nil, nil, nil, nil },
	{ "Arnesian Jungle Region", nil, nil, nil, nil },
	{ "Ascadian Isles Region", nil, nil, nil, nil },
	{ "Ashlands Region", nil, nil, nil, nil },
	{ "Azura's Coast Region", nil, nil, nil, nil },
	{ "Bitter Coast Region", nil, nil, nil, nil },
	{ "Boethiah's Spine Region", nil, nil, nil, nil },
	{ "Clambering Moor Region", nil, nil, nil, nil },
	{ "Dagon Urul Region", nil, nil, nil, nil },
	{ "Deshaan Plains Region", nil, nil, nil, nil },
	{ "Grazelands Region", nil, nil, nil, nil },
	{ "Grey Meadows Region", nil, nil, nil, nil },
	{ "Julan-Shar Region", nil, nil, nil, nil },
	{ "Lan Orethan Region", nil, nil, nil, nil },
	{ "Mephalan Vales Region", nil, nil, nil, nil },
	{ "Molag Mar Region", nil, nil, nil, nil },
	{ "Molag Ruhn Region", nil, nil, nil, nil },
	{ "Molagreahd Region", nil, nil, nil, nil },
	{ "Mournhold Region", nil, nil, nil, nil },
	{ "Mudflats Region", nil, nil, nil, nil },
	{ "Nedothril Region", nil, nil, nil, nil },
	{ "Old Ebonheart Region", nil, nil, nil, nil },
	{ "Othreleth Woods Region", nil, nil, nil, nil },
	{ "Red Mountain Region", nil, nil, nil, nil },
	{ "Roth Roryn Region", nil, nil, nil, nil },
	{ "Sacred Lands Region", nil, nil, nil, nil },
	{ "Salt Marsh Region", nil, nil, nil, nil },
	{ "Sheogorad", nil, nil, nil, nil },
	{ "Shipal-Shin Region", nil, nil, nil, nil },
	{ "Sundered Scar Region", nil, nil, nil, nil },
	{ "Telvanni Isles Region", nil, nil, nil, nil },
	{ "Thirr Valley Region", nil, nil, nil, nil },
	{ "Uld Vraech Region", nil, nil, nil, nil },
	{ "Velothi Mountains Region", nil, nil, nil, nil },
	{ "West Gash Region", nil, nil, nil, nil },
	{ "Sea of Ghosts Region", -40, 58, 17, 33 },
	{ "Padomaic Ocean Region", 30, 58, -61, 30 },
	{ nil, -40, 58 , -61, 33 },
	{ "Brodir Grove Region", nil, nil, nil, nil },
	{ "Felsaad Coast Region", nil, nil, nil, nil },
	{ "Hirstaang Forest Region", nil, nil, nil, nil },
	{ "Moesring Mountains Region", nil, nil, nil, nil },
	{ "Isinfier Plains Region", nil, nil, nil, nil },
	{ "Thirsk Region", nil, nil, nil, nil }
}

-- actor id, destination cell id, manual price, factor to multiply baseprice by
local travel_actor_prices = {
	{ "TR_m1_DaedrothGindaman", nil, nil, 5}
}

---@param e equipEventData
local function restrictEquip(e)
	if e.reference.mobile.object.race.id == "T_Val_Imga" then
		if e.item.objectType == tes3.objectType.armor then
			if e.item.slot == tes3.armorSlot.boots then
				if e.reference.mobile == tes3.mobilePlayer then
					tes3ui.showNotifyMenu("Imga cannot wear shoes.")
				end
				
				return false
			end
			
			if e.item.slot == tes3.armorSlot.helmet then
				if e.reference.mobile.object.female == false then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu("Male Imga cannot wear helmets.")
					end
					
					return false
				end
			end
		end
		
		if e.item.objectType == tes3.objectType.clothing then
			if e.item.slot == tes3.clothingSlot.shoes then
				if e.reference.mobile == tes3.mobilePlayer then
					tes3ui.showNotifyMenu("Imga cannot wear shoes.")
				end
				
				return false
			end
		end
	end
end

---@param e bodyPartAssignedEventData
local function fixVampireHeadAssignment(e)
	if e.index == tes3.activeBodyPart.head then
		if not e.object or e.object.objectType ~= tes3.objectType.armor then
			if e.reference.mobile then
				if e.reference.mobile.object then
					if e.reference.mobile.object.baseObject.head.id == "T_B_De_UNI_HeadOrlukhTR" then	-- Handles the unique head for Varos of the Orlukh bloodline
							e.bodyPart = e.reference.mobile.object.baseObject.head
					end

					if e.reference.mobile.object.baseObject.head.id == "T_B_Imp_UNI_HeadHerriusPC" then	-- Handles the unique head for Herrius Thimistrel
						if e.reference.mobile.inCombat or e.reference.mobile.isDead then
							e.bodyPart = tes3.getObject("T_B_Imp_UNI_HeadHerrius2PC")
						else
							e.bodyPart = tes3.getObject("T_B_Imp_UNI_HeadHerriusPC")
						end
					end
					
					if e.reference.mobile == tes3.mobilePlayer then										-- Handles the player's head when wearing Namira's Shroud						
						if tes3.player.object:hasItemEquipped("T_Dae_UNI_RobeShroud") then		
							e.bodyPart = e.reference.mobile.object.baseObject.head
						end
					end
				end
			end
		end
	end

	if e.index == tes3.activeBodyPart.hair then
		if not e.object or e.object.objectType ~= tes3.objectType.armor then
			if e.reference.mobile then
				if e.reference.mobile.object then
					if e.reference.mobile.object.baseObject.hair.id == "T_B_Imp_UNI_HairHerriusPC" then	-- Handles the unique hair for Herrius Thimistrel
						if e.reference.mobile.inCombat or e.reference.mobile.isDead then
							e.bodyPart = tes3.getObject("T_B_Imp_UNI_HairHerrius2PC")
						else
							e.bodyPart = tes3.getObject("T_B_Imp_UNI_HairHerriusPC")
						end
					end
				end
			end
		end
	end
end

---@param e combatStartedEventData
local function vampireHeadCombatStarted(e)
	if e.actor.reference.bodyPartManager then
		if e.actor.reference.bodyPartManager:getActiveBodyPart(0, 0).bodyPart.id == "T_B_Imp_UNI_HeadHerriusPC" then
			e.actor.reference:updateEquipment()		-- Will trigger fixVampireHeadAssignment via the bodyPartAssigned event
		end
	end
end

---@param e playItemSoundEventData
local function improveItemSounds(e)
	for k,v in pairs(item_sounds) do
		local itemID, upSound, downSound, useSound = unpack(v)
		
		if e.item.id == itemID then
			if e.state == tes3.itemSoundState.up then
				tes3.playSound{ sound = upSound }
			elseif e.state == tes3.itemSoundState.down then
				tes3.playSound{ sound = downSound }
			elseif e.state == tes3.itemSoundState.consume then
				tes3.playSound{ sound = useSound }
			end
			
			return false	-- Block the vanilla behavior and stop iterating through item_sounds 
		end
	end
end

---@param e calcTravelPriceEventData
local function adjustTravelPrices(e)
	for k,v in pairs(travel_actor_prices) do
		local actorID, destinationID, manualPrice, priceFactor = unpack(v, 1, 4 )
		if e.reference.baseObject.id == actorID then
			if not destinationID or e.destination.cell.id == destinationID then
				if manualPrice then
					e.price = manualPrice
				else
					e.price = e.price * priceFactor
				end

				return true
			end
		end
	end
	
	if e.reference.mobile.objectType == tes3.objectType.mobileNPC then
		local providerInstance = e.reference.mobile.object
		if string.find(providerInstance.faction.name, "Mages Guild") and providerInstance.factionRank > 3 then	-- Increase price of teleporting between MG networks
			e.price = e.price * 5;
		end
	end
end

---@param e magicCastedEventData
local function limitInterventionMessage(e)
	for k,v in pairs(e.source.effects) do
		if v.id == tes3.effect.almsiviIntervention then
			local cellVisitTable = { e.caster.cell }
			local extCell = getExteriorCell(e.caster.cell, cellVisitTable)

			if not extCell or not isInterventionCell(extCell, almsivi_intervention_regions) then
				tes3ui.showNotifyMenu("The power of Almsivi does not extend to these lands.")
			end
		end
	end
end

---@param e spellTickEventData
local function limitIntervention(e)
	for k,v in pairs(e.source.effects) do
		if v.id == tes3.effect.almsiviIntervention then
			local cellVisitTable = { e.caster.cell }
			local extCell = getExteriorCell(e.caster.cell, cellVisitTable)
			
			if not extCell or not isInterventionCell(extCell, almsivi_intervention_regions) then
				return false
			end
		end
	end
end

-- Checks the player's race and replaces it with an animation file if one is needed. Should eventually be expanded for races such as Tsaesci, Minotaurs, etc.
local function fixPlayerAnimations()
	if tes3.player.object.race.id == "T_Els_Ohmes-raht" or tes3.player.object.race.id == "T_Els_Suthay" then
		if tes3.player.object.female == true then
			tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_f.nif" })
		else
			tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_m.nif" })
		end
	end
end

-- Setup MCM
dofile("TamrielData.mcm")

event.register(tes3.event.loaded, function()
	
	event.unregister(tes3.event.magicCasted, magic.passwallEffect)
	event.unregister(tes3.event.equip, restrictEquip)
	event.unregister(tes3.event.bodyPartAssigned, fixVampireHeadAssignment)
	event.unregister(tes3.event.combatStarted, vampireHeadCombatStarted)
	event.unregister(tes3.event.playItemSound, improveItemSounds)
	event.unregister(tes3.event.calcTravelPrice, adjustTravelPrices)
	event.unregister(tes3.event.magicCasted, limitInterventionMessage)
	event.unregister(tes3.event.spellTick, limitIntervention)

	if config.miscSpells == true then
		event.register(tes3.event.magicCasted, magic.passwallEffect)
	end

	if config.restrictEquipment == true then
		event.register(tes3.event.equip, restrictEquip)
	end
	
	if config.fixVampireHeads == true then
		event.register(tes3.event.bodyPartAssigned, fixVampireHeadAssignment)
		event.register(tes3.event.combatStarted, vampireHeadCombatStarted)
	end
	
	if config.improveItemSounds == true then
		event.register(tes3.event.playItemSound, improveItemSounds)
	end

	if config.adjustTravelPrices == true then
		event.register(tes3.event.calcTravelPrice, adjustTravelPrices)
	end
	
	if config.limitIntervention == true then
		event.register(tes3.event.magicCasted, limitInterventionMessage)
		event.register(tes3.event.spellTick, limitIntervention)
	end
	
	if config.fixPlayerRaceAnimations == true then
		fixPlayerAnimations()
	end
end)