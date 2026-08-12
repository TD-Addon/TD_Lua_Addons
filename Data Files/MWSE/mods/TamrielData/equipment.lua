local this = {}

local common = require("TamrielData.common")

-- bodypart id
local hats = {
	["T_A_ImpEpHat02_Hr"] = true,
	["T_C_BreCmHat01a_Hr"] = true,
	["T_C_BreCmHat01b_Hr"] = true,
	["T_C_BreCmHat02_Hr"] = true,
	["T_C_BreCmHat03_Hr"] = true,
	["T_C_BreCmHat04a_Hr"] = true,
	["T_C_BreCmHat04b_Hr"] = true,
	["T_C_BreCmHat04c_Hr"] = true,
	["T_C_BreCmHat05a_Hr"] = true,
	["T_C_BreCmHat05b_Hr"] = true,
	["T_C_BreCmHat06_Hr"] = true,
	["T_C_BreCmHatChef_01_Hr"] = true,
	["T_C_BreEpHat01_Hr"] = true,
	["T_C_BreEpHat02_Hr"] = true,
	["T_C_BreEpHat03_Hr"] = true,
	["T_C_BreEpHat04_Hr"] = true,
	["T_C_BreEpHat05_Hr"] = true,
	["T_C_BreEpHat06a_Hr"] = true,
	["T_C_BreEpHat06b_Hr"] = true,
	["T_C_BreEpHat07_Hr"] = true,
	["T_C_BreEpHat08a_Hr"] = true,
	["T_C_BreEpHat08b_Hr"] = true,
	["T_C_BreEpHatOst01_Hr"] = true,
	["T_C_BreEpHatWizard01_Hr"] = true,
	["T_C_BreEpHatWizard02_Hr"] = true,
	["T_C_BreEtHat01_Hr"] = true,
	["T_C_BreEtHat02_Hr"] = true,
	["T_C_BreEtHat03_Hr"] = true,
	["T_C_BreExHat01_Hr"] = true,
	["T_C_BreExHat02_Hr"] = true,
	["T_C_ComCmHat01_Hr"] = true,
	["T_C_ComCmHat02_Hr"] = true,
	["T_C_ComCmHat03_Hr"] = true,
	["T_C_ComCmHat04_Hr"] = true,
	["T_C_ComCmHat05_Hr"] = true,
	["T_C_ComCmHat06_Hr"] = true,
	["T_C_ComEqHat01_Hr"] = true,
	["T_C_ComEtHat01_Hr"] = true,
	["T_C_ComEtHat02_Hr"] = true,
	["T_C_ComEtHat03_Hr"] = true,
	["T_C_ComEtHat04_Hr"] = true,
	["T_C_ComEtHat05_Hr"] = true,
	["T_C_ComFoolsHat01_Hr"] = true,
	["T_C_ComFoolsHat02_Hr"] = true,
	["T_C_ComCmCoif01_Hr"] = true,
	["T_C_ComCmCoif02_Hr"] = true,
	["T_C_ComEtClothCoif_Hr"] = true,
	["T_C_DeCmHatTelv01_Hr"] = true,
	["T_C_DeCmHatTelv02_Hr"] = true,
	["T_C_DeCmHatTelv03_Hr"] = true,
	["T_C_DeCmHatTelv04_Hr"] = true,
	["T_C_DeCmHatTelv05_Hr"] = true,
	["T_C_DeEpHatTelv01_Hr"] = true,
	["T_C_DeEpHatTelv02_Hr"] = true,
	["T_C_DeEpHatTelv03_Hr"] = true,
	["T_C_DeEtHatTelv01_Hr"] = true,
	["T_C_DeEtHatTelv02_Hr"] = true,
	["T_C_DeExHatTelv01_Hr"] = true,
	["T_C_DeExHatTelv02_Hr"] = true,
	["T_C_ImpCmHatColWest01_Hr"] = true,
	["T_C_ImpCmHatColWest02_Hr"] = true,
	["T_C_ImpEpColHat01_Hr"] = true,
	["T_C_ImpEpColHat02_Hr"] = true,
	["T_C_ImpEpHatColWest01_Hr"] = true,
	["T_C_ImpEpHatColWest02_Hr"] = true,
	["T_C_ImpEtHatColNorth01_Hr"] = true,
	["T_C_ImpEtHatColNorth02_Hr"] = true,
	["T_C_ImpEtHatColNorth03_Hr"] = true,
	["T_C_ImpEtHatColNorth04_Hr"] = true,
	["T_C_ImpEtHatColNorth05_Hr"] = true,
	["T_A_ReaLeatherHat01_Hr"] = true,
	["T_C_RgaCmHat01_Hr"] = true,
	["T_C_RgaCmHat02_Hr"] = true,
	["T_C_RgaCmHat03_Hr"] = true,
}

-- clothing id
local embedments = {
}

-- bodypart id
local male_imga_helmets = {
}

---@param equipment tes3clothing
---@param slots number[]
local function usesBodypartSlots(equipment, slots)
	for _,part in pairs(equipment.parts) do
		for _,slot in pairs(slots) do
			if part.type == slot then return true end
		end
	end
end

---@param e equippedEventData
function this.hatHelmetEquipped(e)
	if e.item.objectType == tes3.objectType.armor then
		if e.item.slot == tes3.armorSlot.helmet and tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.clothing, slot = tes3.clothingSlot.hat }) then
			e.mobile:unequip({ clothingSlot = tes3.clothingSlot.hat })
		end
	elseif e.item.objectType == tes3.objectType.clothing then
		if e.item.slot == tes3.clothingSlot.hat and tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet }) then
			e.mobile:unequip({ armorSlot = tes3.armorSlot.helmet })
		end
	end
end

---@param e cellChangedEventData
function this.replaceHatCell(e)
	for armor in e.cell:iterateReferences(tes3.objectType.armor) do
		if armor and armor.object and armor.object.slot == tes3.armorSlot.helmet and not armor.object.isClosedHelmet then
			if common.isFromTD(armor.object, false) or common.isFromPTR(armor.object, false) then
				if tes3.getObject(armor.object.id .. "H") then
					local hat = tes3.createReference({ object = armor.object.id .. "H", orientation = armor.orientation, position = armor.position, cell = armor.cell, scale = armor.scale })

					local armorOwner, requirement = tes3.getOwner({ reference = armor })
					if armorOwner then tes3.setOwner({ reference = hat, owner = armorOwner, requiredRank = requirement, requiredGlobal = requirement }) end

					armor:delete()
				end
			end
		end
	end

	local replaceableHelmets
	local helmetNumber
	for actor in e.cell:iterateReferences({ tes3.objectType.npc, tes3.objectType.creature, tes3.objectType.container }) do
		replaceableHelmets = {}
		helmetNumber = 1
		for _,itemStack in pairs(actor.object.inventory) do	-- Containers don't have mobiles, but the object property can access the instances for all of the applicable references
			if itemStack and itemStack.object and itemStack.object.objectType == tes3.objectType.armor and itemStack.object.slot == tes3.armorSlot.helmet and not itemStack.object.isClosedHelmet then
				if common.isFromTD(itemStack.object, false) or common.isFromPTR(itemStack.object, false) then
					if tes3.getObject(itemStack.object.id .. "H") and itemStack.count > 0 then
						replaceableHelmets[helmetNumber] = { itemStack.object.id, itemStack.count }
						helmetNumber = helmetNumber + 1
					end
				end
			end
		end

		for _,helmet in pairs(replaceableHelmets) do
			tes3.addItem({ reference = actor, item = helmet[1] .. "H", count = helmet[2], playSound = false })
			tes3.removeItem({ reference = actor, item = helmet[1], count = helmet[2], playSound = false })
		end
	end
end

---@param e leveledItemPickedEventData
function this.replaceHatLeveledItem(e)
	if e.pick and e.pick.objectType == tes3.objectType.armor and e.pick.slot == tes3.armorSlot.helmet and not e.pick.isClosedHelmet then
		if common.isFromTD(e.pick, false) or common.isFromPTR(e.pick, false)then
			local hatItem = tes3.getObject(e.pick.id .. "H")
			if hatItem and not hatItem.sourceMod then e.pick = hatItem end
		end
	end
end

function this.createHatObjects()
	for armor in tes3.iterateObjects(tes3.objectType.armor) do
		---@cast armor tes3armor
		if armor.slot == tes3.armorSlot.helmet and not armor.isClosedHelmet then	-- Closed helmets are not going to be hats by definition
			if common.isFromTD(armor, false) or common.isFromPTR(armor, false) then -- Only affect TD hats or unique variants from PTR
				if armor.id:find("Hat") or armor.name:find("Hat") or armor.icon:lower():find("hat") or armor.id:find("Hood") or armor.name:find("Hood") or armor.icon:lower():find("hood") then	-- Check whether these conditions are actually worth having
					for hatArmorID in pairs(hats) do
						if armor.parts[1] and armor.parts[1].male and armor.parts[1].male.id == hatArmorID and #(armor.id .. "H") < 32 then
							local hat = tes3.createObject({ objectType = tes3.objectType.clothing, id = armor.id .. "H", getIfExists = true })
							hat.name = armor.name
							hat.value = armor.value
							hat.weight = armor.weight
							hat.icon = armor.icon
							hat.mesh = armor.mesh
							hat.parts[1] = armor.parts[1]
							hat.script = armor.script
							hat.enchantment = armor.enchantment
							hat.enchantCapacity = armor.enchantCapacity
							hat.blocked = armor.blocked
							hat.slot = tes3.clothingSlot.hat
							break
						end
					end
				end
			end
		end
	end
end

function this.changeEmbedmentsSlot()
	for _,clothingID in pairs(embedments) do
		tes3.getObject(clothingID).slot = tes3.clothingSlot.embedment
	end
end

---@param attachNode niNode
---@param item tes3clothing
---@param reference tes3reference
local function addEmbedment(attachNode, item, reference)
	local embedmentMesh = tes3.loadMesh(item.mesh)
	if embedmentMesh then
		embedmentMesh = embedmentMesh:clone()
		embedmentMesh.name = "td_embedment"

		embedmentMesh.translation.x = 8.25
		embedmentMesh.translation.y = 7.5
		embedmentMesh.translation.z = 0
		local rotationMatrix = tes3matrix33.new()
		rotationMatrix:fromEulerXYZ(math.pi / 2, 0, math.pi / 2)
		embedmentMesh.rotation = embedmentMesh.rotation * rotationMatrix			-- The calculation has to be split up like this so that things don't go horribly wrong
		embedmentMesh.scale = .6

		attachNode:attachChild(embedmentMesh)
		--if item.enchantment then													-- Right now this section makes the item's texture black when looking at the player in the inventory screen for unclear reasons.
		--	tes3.worldController:applyEnchantEffect(embedmentMesh, item.enchantment)
		--	embedmentMesh:updateEffects()
		--	embedmentMesh:updateProperties()
		--end

		reference.sceneNode:update()
		reference.sceneNode:updateEffects()		-- updateProperties shouldn't be needed here
	end
end

---@param attachNode niNode
local function removeEmbedment(attachNode)
	local embedment = attachNode:getObjectByName("td_embedment")
	if embedment then
		attachNode:detachChild(embedment)
	end
end

---@param e cellChangedEventData
function this.embedmentLoaded(e)
	if e.previousCell then return end		-- mobileActivated is not triggered when loading a game, so cellChanged is used as well
	for _,cell in pairs(tes3.getActiveCells()) do
		for npc in cell:iterateReferences(tes3.objectType.npc, false) do
			local embedmentItem = tes3.getEquippedItem({ actor = npc, objectType = tes3.objectType.clothing, slot = tes3.clothingSlot.embedment })
			if embedmentItem then
				local helmet = tes3.getEquippedItem({ actor = npc, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet })
				if not helmet or not helmet.object.isClosedHelmet then
					local attachNode = npc.sceneNode:getObjectByName('Bip01 Head')
					if attachNode then
						addEmbedment(attachNode, embedmentItem.object, npc)
					end
				end
			end
		end
	end

	local embedmentItem = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.clothing, slot = tes3.clothingSlot.embedment })
	if embedmentItem then
		local helmet = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet })
		if not helmet or not helmet.object.isClosedHelmet then
			local attachNode = tes3.player.sceneNode:getObjectByName('Bip01 Head')
			if attachNode then
				addEmbedment(attachNode, embedmentItem.object, tes3.player)
			end
		end
	end
end

---@param e mobileActivatedEventData
function this.embedmentMobileActivated(e)
	if e.mobile.actorType == tes3.actorType.player or e.mobile.actorType == tes3.actorType.npc then
		local helmet = tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet })	-- This is causing an error for unclear reasons
		if not helmet or not helmet.object.isClosedHelmet then
			local embedmentItem = tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.clothing, slot = tes3.clothingSlot.embedment })
			if embedmentItem then
				local attachNode = e.reference.sceneNode:getObjectByName('Bip01 Head')
				if attachNode then
					addEmbedment(attachNode, embedmentItem.object, e.reference)
				end
			end
		end
	end
end

---@param e unequippedEventData
function this.embedmentUnequipped(e)
	if e.item.objectType == tes3.objectType.clothing and e.item.slot == tes3.clothingSlot.embedment then
		local attachNode = e.reference.sceneNode:getObjectByName('Bip01 Head')
		if attachNode then removeEmbedment(attachNode) end
	elseif e.item.objectType == tes3.objectType.armor and e.item.slot == tes3.armorSlot.helmet and e.item.isClosedHelmet then
		local attachNode = e.reference.sceneNode:getObjectByName('Bip01 Head')
		if attachNode then
			removeEmbedment(attachNode)
			local embedmentItem = tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.clothing, slot = tes3.clothingSlot.embedment })
			---@cast embedmentItem tes3equipmentStack
			if embedmentItem then
				addEmbedment(attachNode, embedmentItem.object, e.reference)
			end
		end
	end
end

---@param e equippedEventData
function this.embedmentEquipped(e)
	if e.item.objectType == tes3.objectType.clothing and e.item.slot == tes3.clothingSlot.embedment then
		local helmet = tes3.getEquippedItem({ actor = e.reference, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet })
		if not helmet or not helmet.object.isClosedHelmet then
			local attachNode = e.reference.sceneNode:getObjectByName('Bip01 Head')
			if attachNode then
				removeEmbedment(attachNode)
				addEmbedment(attachNode, e.item, e.reference)
			end
		end
	elseif e.item.objectType == tes3.objectType.armor and e.item.slot == tes3.armorSlot.helmet and e.item.isClosedHelmet then
		local attachNode = e.reference.sceneNode:getObjectByName('Bip01 Head')
		if attachNode then removeEmbedment(attachNode) end
	end
end

---@param e equipEventData
function this.restrictRaceEquip(e)
	if e.reference.baseObject.objectType == tes3.objectType.npc then
		if e.reference.mobile.object.race.id == "T_Val_Imga" then			-- Imga are not able to wear boots/shoes and male Imga cannot wear any helmets/hats due to their skull's crest unless the item is made specifically for them
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.boots and usesBodypartSlots(e.item, { tes3.activeBodyPart.leftFoot, tes3.activeBodyPart.rightFoot }) then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.imgaBoots"))
					end

					return false
				elseif e.item.slot == tes3.armorSlot.helmet then
					if not e.reference.mobile.object.female then
						if e.item.parts[1] and e.item.parts[1].male and not male_imga_helmets[e.item.parts[1].male.id] then
							if e.reference.mobile == tes3.mobilePlayer then
								tes3ui.showNotifyMenu(common.i18n("main.imgaHelm"))
							end

							return false
						end
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.shoes and usesBodypartSlots(e.item, { tes3.activeBodyPart.leftFoot, tes3.activeBodyPart.rightFoot }) then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.imgaShoes"))
					end

					return false
				elseif e.item.slot == tes3.clothingSlot.hat then
					if not e.reference.mobile.object.female then
						if e.item.parts[1] and e.item.parts[1].male and not male_imga_helmets[e.item.parts[1].male.id] then
							if e.reference.mobile == tes3.mobilePlayer then
								tes3ui.showNotifyMenu(common.i18n("main.imgaHat"))
							end

							return false
						end
					end
				end
			end
		elseif e.reference.mobile.object.race.id == "T_Aka_Tsaesci" then	-- Tsaesci are not able to wear greaves/pants or boots/shoes
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.boots then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciBoots"))
					end

					return false
				end

				if e.item.slot == tes3.armorSlot.greaves then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciGreaves"))
					end

					return false
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.shoes then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciShoes"))
					end

					return false
				end

				if e.item.slot == tes3.clothingSlot.pants then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciPants"))
					end

					return false
				end
			end
		elseif e.reference.mobile.object.race.id == "T_Cyr_Minotaur" then	-- Minotaurs are not able to any helmets/hats; boots/shoes are accounted by them being a beast race
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.helmet then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.minotaurHelm"))
						end

						return false
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.hat then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.minotaurHat"))
						end

						return false
					end
				end
			end
		elseif e.reference.mobile.object.race.id == "T_Bkm_Naga" then		-- Naga are not able to wear any helmets/hats; boots/shoes are accounted by them being a beast race
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.helmet then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.nagaHelm"))
						end

						return false
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.hat then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.nagaHat"))
						end

						return false
					end
				end
			end
		end

		if e.reference.mobile.object.female or e.reference.mobile.object.race.id ~= "T_Val_Imga" then	-- Actors who are not male Imga should not be able to wear headwear made for them
			if e.item.parts and e.item.parts[1] and e.item.parts[1].male and male_imga_helmets[e.item.parts[1].male.id] then
				if e.reference.mobile == tes3.mobilePlayer then
					if e.item.objectType == tes3.objectType.armor and e.item.slot == tes3.armorSlot.helmet then
						tes3ui.showNotifyMenu(common.i18n("main.maleImgaHelmet"))
					elseif e.item.objectType == tes3.objectType.clothing and e.item.slot == tes3.clothingSlot.hat then
						tes3ui.showNotifyMenu(common.i18n("main.maleImgaHat"))
					end
				end

				return false
			end
		end
	end
end

---@param e bodyPartAssignedEventData
function this.switchArgonianFemaleEquipment(e)
	if e.object and e.reference.baseObject.objectType == tes3.objectType.npc and common.td_argonian_races[e.reference.baseObject.race.id] then
		for _,part in pairs(e.object.parts) do
			if part.type == e.index then
				e.bodyPart = part.male
				return
			end
		end
	end
end

return this