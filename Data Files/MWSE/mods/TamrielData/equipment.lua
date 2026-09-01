local this = {}

local common = require("TamrielData.common")
local config = require("TamrielData.config")

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

-- bodypart id, name of NiTriShape to replace, name of the NiTriShape in the race's bodypart mesh to use instead (if multiple shapes are present), name of the relevant tes3raceBodyParts property, active bodyparts (left & right if applicable) that the bodypart might be on
local body_swap_shapes = {
	["T_C_ArgCmShirt01_C"] = { equipmentShapeName = "Tri Chest 0", bodyShapeName = "Tri Chest", raceBodyPartProperty = "chest", possibleActiveBodyParts = { tes3.activeBodyPart.chest } }
}

-- bodypart id, name of NiTriShape to replace the texture of, name of the NiTriShape in the race's bodypart mesh with the new texture, name of the relevant tes3raceBodyParts property, active bodyparts (left & right if applicable) that the bodypart might be on
local body_swap_textures = {
	--["T_C_ArgCmShirt01_C"] = { equipmentShapeName = "Tri Chest 0", bodyShapeName = "Tri Chest", raceBodyPartProperty = "chest", possibleActiveBodyParts = { tes3.activeBodyPart.chest } },		-- Included as an example (despite being the same as the entry in body_swap_shapes)
}

---@param equipment tes3clothing
---@param slots number[]
local function usesBodypartSlots(equipment, slots)
	for _, part in pairs(equipment.parts) do
		for _, slot in pairs(slots) do
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
		for _, itemStack in pairs(actor.object.inventory) do	-- Containers don't have mobiles, but the object property can access the instances for all of the applicable references
			if itemStack and itemStack.object and itemStack.object.objectType == tes3.objectType.armor and itemStack.object.slot == tes3.armorSlot.helmet and not itemStack.object.isClosedHelmet then
				if common.isFromTD(itemStack.object, false) or common.isFromPTR(itemStack.object, false) then
					if tes3.getObject(itemStack.object.id .. "H") and itemStack.count > 0 then
						replaceableHelmets[helmetNumber] = { itemStack.object.id, itemStack.count }
						helmetNumber = helmetNumber + 1
					end
				end
			end
		end

		for _, helmet in pairs(replaceableHelmets) do
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
	for _, clothingID in pairs(embedments) do
		tes3.getObject(clothingID).slot = tes3.clothingSlot.embedment
	end
end

---@param attachNode niNode
---@param item tes3clothing
---@param reference tes3reference
local function addEmbedment(attachNode, item, reference)
	local embedmentMesh = tes3.loadMesh(item.mesh, false)
	if embedmentMesh then
		embedmentMesh.name = "td_embedment"

		embedmentMesh.translation.x = 8.25
		embedmentMesh.translation.y = 7.5
		embedmentMesh.translation.z = 0
		local rotationMatrix = tes3matrix33.new()
		rotationMatrix:fromEulerXYZ(math.pi / 2, 0, math.pi / 2)					-- Should the weight and height of the actor be taken into consideration here as well?
		embedmentMesh.rotation = embedmentMesh.rotation * rotationMatrix			-- The calculation has to be split up like this so that things don't go horribly wrong
		embedmentMesh.scale = .6

		attachNode:attachChild(embedmentMesh)
		--if item.enchantment then													-- Right now this section makes the item's texture black when looking at the player in the inventory screen for unclear reasons.
		--	tes3.worldController:applyEnchantEffect(embedmentMesh, item.enchantment)
		--	embedmentMesh:updateEffects()
		--	embedmentMesh:updateProperties()
		--end

		reference.sceneNode:update()
		reference.sceneNode:updateProperties()
		reference.sceneNode:updateEffects()
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
	for _, cell in pairs(tes3.getActiveCells()) do
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
		elseif e.reference.mobile.object.race.id == "T_Bkm_Sarpa" then		-- Naga are not able to wear bracers, gauntlets, and gloves; helmets/hats and boots/shoes are accounted by them being a beast race
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.leftGauntlet or e.item.slot == tes3.armorSlot.rightGauntlet then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.sarpaGauntlet"))
						end

						return false
					end
				elseif e.item.slot == tes3.armorSlot.leftBracer or e.item.slot == tes3.armorSlot.rightBracer then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.sarpaBracer"))
						end

						return false
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.leftGlove or e.item.slot == tes3.clothingSlot.rightGlove then
					if e.item.parts[1] and e.item.parts[1].male then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.sarpaGlove"))
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
	if e.object and e.reference.baseObject.objectType == tes3.objectType.npc and common.argonian_races[e.reference.baseObject.race.id] then
		for _, part in pairs(e.object.parts) do
			if part.type == e.index then
				e.bodyPart = part.male
				return
			end
		end
	end
end

-- Valid meshes could have an NiNode as the root node rather than the NiTriShape, which getFirstShape returns
---@param node niNode
---@returns NiTriShape
local function getFirstShape(node)
	for shape in node:traverse({ type = ni.type.NiTriShape }) do return shape end
end

-- Different body parts being seamless or unsegmented (such as VSBR or the Tsaesci) will cause problems since TD's equipment for this feature has been made with the vanilla body parts in mind, so the textures and meshes of different body parts are checked to ensure that they are not the same
---@param raceBodyParts tes3raceBodyParts
local function raceFollowsConvention(raceBodyParts)
	if raceBodyParts.chest.mesh ~= raceBodyParts.neck.mesh and raceBodyParts.chest.mesh ~= raceBodyParts.forearm.mesh and raceBodyParts.chest.mesh ~= raceBodyParts.groin.mesh then
		local chest = tes3.loadMesh(raceBodyParts.chest.mesh):getObjectByName("Tri Chest")
		local neck = getFirstShape(tes3.loadMesh(raceBodyParts.neck.mesh))
		local forearm = getFirstShape(tes3.loadMesh(raceBodyParts.forearm.mesh))
		local groin = getFirstShape(tes3.loadMesh(raceBodyParts.groin.mesh))

		if chest and neck and forearm and groin then
			local chestTexturingProperty = chest.texturingProperty
			local neckTexturingProperty = neck.texturingProperty
			local forearmTexturingProperty = forearm.texturingProperty
			local groinTexturingProperty = groin.texturingProperty

			if chestTexturingProperty and neckTexturingProperty and forearmTexturingProperty and groinTexturingProperty then
				local chestTexture = chestTexturingProperty.baseMap.texture.fileName
				local neckTexture = neckTexturingProperty.baseMap.texture.fileName
				local forearmTexture = forearmTexturingProperty.baseMap.texture.fileName
				local groinTexture = groinTexturingProperty.baseMap.texture.fileName

				if chestTexture ~= neckTexture and chestTexture ~= forearmTexture and chestTexture ~= groinTexture then
					return true
				end
			end
		end
	end
end

-- Replaces a bodypart's NiTriShape with a shape from an actors racial bodyparts according to body_swap_shapes
---@param e bodyPartAssignedEventData
function this.addBodyShapeToClothing(e)
	-- getDirectChildrenByName only searches the children of a given node, not all of the nodes underneath it; this should prevent unintended behavior from the DFS of getObjectByName if another node (likely in a bodypart) happens to be the same as that being searched for
	---@param node niNode
	---@param name string
	---@returns NiTriShape
	local function getDirectChildByName(node, name)
		for _,child in pairs(node.children) do
			if child and child.name == name then return child end
		end
	end

	if e.bodyPart and e.bodyPart.partType == tes3.activeBodyPartLayer.clothing and body_swap_shapes[e.bodyPart.id] and not e.manager:getActiveBodyPart(tes3.activeBodyPartLayer.armor, e.index).bodyPart then
		timer.delayOneFrame(function()
			if e.manager:getActiveBodyPart(tes3.activeBodyPartLayer.armor, e.index).bodyPart then return end

			local activePart = e.manager:getActiveBodyPart(e.bodyPart.partType, e.index)
			if activePart and activePart.node then
				local shape = activePart.node:getObjectByName(body_swap_shapes[e.bodyPart.id].equipmentShapeName)
				shape.appCulled = true
				tes3ui.updateInventoryCharacterImage()
			end

			local bodyMesh
			if e.reference.object.female then
				if not raceFollowsConvention(e.reference.object.race.femaleBody) then return end	-- Is this check needed for shape replacements?
				bodyMesh = tes3.loadMesh(e.reference.object.race.femaleBody[body_swap_shapes[e.bodyPart.id].raceBodyPartProperty].mesh, false)
			else
				if not raceFollowsConvention(e.reference.object.race.maleBody) then return end
				bodyMesh = tes3.loadMesh(e.reference.object.race.maleBody[body_swap_shapes[e.bodyPart.id].raceBodyPartProperty].mesh, false)
			end

			local bodyShapeParent = niNode.new()
			bodyShapeParent.name = e.bodyPart.id		-- By naming the node after the bodyPart's ID, it can easily be found by different functions

			if bodyMesh:getObjectByName("Bip01") then
				local scale = tes3vector3.new(1 / e.reference.object.weight, 1 / e.reference.object.weight, 1 / e.reference.object.height)		-- Onion squares the height and weight values even though these seem correct?
				bodyShapeParent.rotation = tes3matrix33.new(bodyShapeParent.rotation.x * scale, bodyShapeParent.rotation.y * scale, bodyShapeParent.rotation.z * scale)		-- Apply racial scaling

				e.reference.sceneNode:attachChild(bodyShapeParent, true)
				local shape = bodyMesh:getObjectByName(body_swap_shapes[e.bodyPart.id].bodyShapeName)
				if shape.skinInstance then
					shape = shape:clone()

					shape.skinInstance.root = bodyShapeParent
					for i, bone in ipairs(shape.skinInstance.bones) do
						shape.skinInstance.bones[i] = e.reference.sceneNode:getObjectByName(bone.name)
					end

					bodyShapeParent:attachChild(shape, true)
				end
			else
				e.index = tes3.activeBodyPart.leftWrist
				local bodySlotName = table.invert(tes3.activeBodyPart)[e.index]
				local bodyAttachmentName = bodySlotName

				bodyAttachmentName = bodyAttachmentName:gsub("Pauldron", "Clavicle")
				bodyAttachmentName = bodyAttachmentName:gsub("Forearm", "Forearm1")			-- Hopefully ignoring the 2nd attachments does not cause problems
				bodyAttachmentName = bodyAttachmentName:gsub("Wrist", "Forearm1")
				bodyAttachmentName = bodyAttachmentName:gsub("UpperLeg", "Thigh")
				bodyAttachmentName = bodyAttachmentName:gsub("Knee", "Calf1")
				bodyAttachmentName = bodyAttachmentName:gsub("Ankle", "Calf1")

				bodySlotName = bodySlotName:gsub("left", "Left ")
				bodySlotName = bodySlotName:gsub("right", "Right ")

				local bodyAttachmentIndex = tes3.bodyPartAttachment[bodyAttachmentName]
				if not bodyAttachmentIndex then return end

				local boneNode = e.manager:getAttachNode(bodyAttachmentIndex).node			-- Despite its name getAttachNode gets the NiNodes for Bip01 bonesPerVertex, not the NiNodes that meshes are actually attached to (which are closer to activeBodyPart)
				local attachNode = getDirectChildByName(boneNode, bodySlotName)
				if not attachNode then return end

				bodyShapeParent:attachChild(bodyMesh, true)
				attachNode:attachChild(bodyShapeParent, true)
			end

			bodyShapeParent:update()
			bodyShapeParent:updateEffects()
			bodyShapeParent:updateProperties()

			e.reference.data.tamrielData = e.reference.data.tamrielData or {}
			e.reference.data.tamrielData.hasBodyUnderneathClothing = true		-- This is set to make it easier to verify that references should have their equipment updated in main.lua and handled by the removeBodyShapeWithClothing and hideBodyShapeUnderArmor; it is not ever set to nil given how difficult it would be to keep track of the bodyparts
		end, timer.real)
	end
end

-- Removes body meshes when the associated clothing is unequipped
---@param e unequippedEventData
function this.removeBodyShapeWithClothing(e)
	if e.item.objectType == tes3.objectType.clothing and common.hasDataField(e.reference, "hasBodyUnderneathClothing") then
		for _, part in pairs(e.item.parts) do
			local bodyPart = part:getPart(e.actor.female and not (common.argonian_races[e.actor.race.id] and config.femaleArgoniansUseMaleEquipment))
			if bodyPart and body_swap_shapes[bodyPart.id] then
				local attachNode = e.reference.sceneNode:getObjectByName(bodyPart.id)
				if attachNode then attachNode.parent:detachChild(attachNode) end
				--attachNode.appCulled = true
			end
		end
	end
end

-- Removes body meshes when armor is equipped on top of them
---@param e equippedEventData
function this.hideBodyShapeUnderArmor(e)
	if e.item.objectType == tes3.objectType.armor and common.hasDataField(e.reference, "hasBodyUnderneathClothing") then
		for _, part in pairs(e.item.parts) do
			local bodyPart = part:getPart(e.actor.female and not (common.argonian_races[e.actor.race.id] and config.femaleArgoniansUseMaleEquipment))
			if bodyPart then
				local activePart = e.reference.bodyPartManager:getActiveBodyPart(tes3.activeBodyPartLayer.clothing, part.type)
				if activePart.bodyPart and body_swap_shapes[activePart.bodyPart.id] then
					local attachNode = e.reference.sceneNode:getObjectByName(activePart.bodyPart.id)
					if attachNode then attachNode.parent:detachChild(attachNode) end
				end
			end
		end
	end
end

-- Replaces a bodypart's texture with one from the actor's racial bodyparts according to body_swap_textures
---@param e bodyPartAssignedEventData
function this.applyBodyTextureToClothing(e)
	if e.bodyPart and e.bodyPart.partType == tes3.activeBodyPartLayer.clothing and body_swap_textures[e.bodyPart.id] then
		timer.delayOneFrame(function()
			local activePart = e.manager:getActiveBodyPart(e.bodyPart.partType, e.index)
			if activePart and activePart.node then
				local bodyMesh
				if e.reference.object.female then
					if not raceFollowsConvention(e.reference.object.race.femaleBody) then return end
					bodyMesh = tes3.loadMesh(e.reference.object.race.femaleBody[body_swap_textures[e.bodyPart.id].raceBodyPartProperty].mesh, false)
				else
					if not raceFollowsConvention(e.reference.object.race.maleBody) then return end
					bodyMesh = tes3.loadMesh(e.reference.object.race.maleBody[body_swap_textures[e.bodyPart.id].raceBodyPartProperty].mesh, false)
				end

				local bodyShape
				if body_swap_textures[e.bodyPart.id].bodyShapeName and bodyMesh:getObjectByName("Bip01") then
					bodyShape = bodyMesh:getObjectByName(body_swap_textures[e.bodyPart.id].bodyShapeName)
				else
					bodyShape = getFirstShape(bodyMesh)
				end
				if not bodyShape then return end

				local bodyTexture = bodyShape.texturingProperty.baseMap
				local shape = activePart.node:getObjectByName(body_swap_textures[e.bodyPart.id].equipmentShapeName)

				if bodyTexture and shape then
					local replacementProperty = shape.texturingProperty:clone()
					replacementProperty.baseMap = niTexturingPropertyMap.new({
						texture = bodyTexture.texture,
						clampMode = bodyTexture.clampMode,
						filterMode = bodyTexture.filterMode,
						textCoords = bodyTexture.texCoordSet,	-- Replace textCoords with texCoordSet when MWSE is updated
					})
					shape.texturingProperty = replacementProperty

					shape:update()
					shape:updateProperties()
					tes3ui.updateInventoryCharacterImage()

					e.reference.data.tamrielData = e.reference.data.tamrielData or {}
					e.reference.data.tamrielData.hasBodyTextureOnClothing = true		-- A name distinct from addBodyShapeToClothing's is used here so that the other functions above do not need total run on NPCs that only have clothing with body textures
				end
			end
		end, timer.real)
	end
end

return this