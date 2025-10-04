--[[
	Tamriel Data MWSE-Lua Addon v2.3
	By Kynesifnar, mort, and Rakanishu
]]

if not tes3.isModActive("Tamriel_Data.esm") then return end

local common = require("TamrielData.common")
local config = require("TamrielData.config")
local behavior = require("TamrielData.behavior")
local factions = require("TamrielData.factions")
local magic = require("TamrielData.magic")
local reputation = require("TamrielData.reputation")
local weather = require("TamrielData.weather")

mwse.log("[Tamriel Data MWSE-Lua] Initialized Version 2.3")

local player_data_defaults = {
	corruptionReferenceID = ""
}

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
	{ "T_Com_Subst_Perfume_06", "Item Potion Up", "Item Potion Down", "T_SndObj_SprayBottle"},
	{ "T_Imp_Subst_IndulcetPreserve_01", "Item Potion Up", "Item Potion Down", "Swallow"},
	{ "T_Imp_Subst_QuaestoVil_01", "Item Potion Up", "Item Potion Down", "Item Potion Down"},
	{ "T_Imp_Subst_QuaestoVil_02", "Item Potion Up", "Item Potion Down", "Item Potion Down"},
	{ "T_Imp_Subst_SiyatCigar_01", "Item Misc Up", "Item Misc Down", "T_SndObj_CigarDrag"},

	{ "T_IngSpice_OliveOil_01", "Item Potion Up", "Item Potion Down", "Drink"},
	{ "T_IngFood_Vinegar_01", "Item Potion Up", "Item Potion Down", "Drink"},
	{ "T_IngCrea_OrcBlood_01", "Item Potion Up", "Item Potion Down", "Drink"},
	{ "T_IngFlor_Siyat_01", "Item Potion Up", "Item Potion Down", "greneat"},
	{ "T_IngFood_Siyat_02", "Item Potion Up", "Item Potion Down", "greneat"},

	{ "misc_dwrv_coin00", "Item Gold Up", "Item Gold Down", "" },
	{ "misc_dwrv_cursed_coin00", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Ayl_CoinBig_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Ayl_CoinGold_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Ayl_CoinSquare_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_He_DirenniCoin_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Imp_CoinAlessian_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Imp_CoinReman_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Nor_CoinBarrowCopper_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Nor_CoinBarrowIron_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_Nor_CoinBarrowSilver_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_De_HlaaluCompanyScrip_01", "Item Gold Up", "Item Gold Down", "" },
	{ "T_De_HlaaluCompanyScrip_02", "Item Gold Up", "Item Gold Down", "" },

	{ "T_EnSc_Ayl_Blessed", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_CavernsOfTruth", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_DaedricHerald1", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_DaedricHerald2", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_Destroyed", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_Enter", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_FoamingWave1", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_FoamingWave2", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_FromLight", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_GodlyPower1", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_GodlyPower2", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_LoreArmor1", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_LoreArmor2", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_Wisdom1", "Item Misc Up", "Item Misc Down", "scroll" },
	{ "T_EnSc_Ayl_Wisdom2", "Item Misc Up", "Item Misc Down", "scroll" },
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
	{ "Kragen Moor Region", nil, nil, nil, nil },
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

-- region id, xcell left bound, xcell right bound, ycell top bound, ycell bottom bound
local kyne_intervention_regions = {
	{ "Colovian Barrowlands Region", nil, nil, nil, nil },
	{ "Drajkmyr Marsh Region", nil, nil, nil, nil },
	{ "Druadach Highlands Region", nil, nil, nil, nil },
	{ "Falkheim Region", nil, nil, nil, nil },
	{ "Gorvigh Mountains Region", nil, nil, nil, nil },
	{ "Hrimbald Plateau Region", nil, nil, nil, nil },
	{ "Hirsing Forest Region", nil, nil, nil, nil },
	{ "Jerall Mountains Region", nil, nil, nil, nil },
	{ "Kilkreath Mountains Region", nil, nil, nil, nil },
	{ "Kreathi Vale Region", nil, nil, nil, nil },
	{ "Lorchwuir Heath Region", nil, nil, nil, nil },
	{ "Mhorkren Hills Region", nil, nil, nil, nil },
	{ "Midkarth Region", nil, nil, nil, nil },
	{ "Northshore Region", nil, nil, nil, nil },
	{ "Reaver's Shore Region", nil, nil, nil, nil },
	{ "Rift Valley Region", nil, nil, nil, nil },
	{ "Skaldring Mountains Region", nil, nil, nil, nil },
	{ "Solitude Forest Region", nil, nil, nil, nil },
	{ "Solitude Forest Region S", nil, nil, nil, nil },
	{ "Sundered Hills Region", nil, nil, nil, nil },
	{ "Throat of the World Region", nil, nil, nil, nil },
	{ "Troll's Teeth Mountains Region", nil, nil, nil, nil },
	{ "Uld Vraech Region", nil, nil, nil, nil },
	{ "Valstaag Highlands Region", nil, nil, nil, nil },
	{ "Velothi Mountains Region", -41, -18, -8, 20 },
	{ "Vorndgad Forest Region", nil, nil, nil, nil },
	{ "White Plains Region", nil, nil, nil, nil },
	{ "Wuurthal Dale Region", nil, nil, nil, nil },
	{ "Ysheim Region", nil, nil, nil, nil },
	{ "Sea of Ghosts Region", -116, -20, 21, 40 },
	{ "Sea of Ghosts Region N", -116, -10, 21, 40 },
	{ nil, -116, -20, 21, 40 },
	{ "Brodir Grove Region", nil, nil, nil, nil },
	{ "Felsaad Coast Region", nil, nil, nil, nil },
	{ "Hirstaang Forest Region", nil, nil, nil, nil },
	{ "Moesring Mountains Region", nil, nil, nil, nil },
	{ "Isinfier Plains Region", nil, nil, nil, nil },
	{ "Thirsk Region", nil, nil, nil, nil }
}

-- xcell coordinate, ycell coordinate
local kyne_intervention_cells = {
	--{-112, 11} -- Taurus Hall, as an example
}

-- actor id, destination cell id, factor to multiply baseprice by
local travel_actor_prices = {
	{ "TR_m1_DaedrothGindaman", nil, 5},
	{ "Sky_xRe_DSE_Arvund", "Karthwasten", 2.273},		-- 22 to 50
	{ "Sky_xRe_KW_Aurius", "Dragonstar East", 2.273},		-- Markarth to DS/KW prices will probably need to be gone over too
}

-- bodypart id
local hats = {
	"T_A_ImpEpHat02_Hr",
	"T_C_BreEpHatWizard01_Hr",
	"T_C_BreEpHatWizard02_Hr",
	"T_C_ComCmHat01_Hr",
	"T_C_ComCmHat02_Hr",
	"T_C_ComCmHat03_Hr",
	"T_C_ComCmHat04_Hr",
	"T_C_ComCmHat05_Hr",
	"T_C_ComCmHat06_Hr",
	"T_C_ComEqHat01_Hr",
	"T_C_ComEtHat01_Hr",
	"T_C_ComEtHat02_Hr",
	"T_C_ComEtHat03_Hr",
	"T_C_ComEtHat04_Hr",
	"T_C_ComEtHat05_Hr",
	"T_C_ComFoolsHat01_Hr",
	"T_C_ComFoolsHat02_Hr",
	"T_C_ComCmCoif01_Hr",
	"T_C_ComCmCoif02_Hr",
	"T_C_ComEtClothCoif_Hr",
	"T_C_DeCmHatTelv01_Hr",
	"T_C_DeCmHatTelv02_Hr",
	"T_C_DeCmHatTelv03_Hr",
	"T_C_DeCmHatTelv04_Hr",
	"T_C_DeCmHatTelv05_Hr",
	"T_C_DeEpHatTelv01_Hr",
	"T_C_DeEpHatTelv02_Hr",
	"T_C_DeEpHatTelv03_Hr",
	"T_C_DeEtHatTelv01_Hr",
	"T_C_DeEtHatTelv02_Hr",
	"T_C_DeExHatTelv01_Hr",
	"T_C_DeExHatTelv02_Hr",
	"T_C_ImpCmHatColWest01_Hr",
	"T_C_ImpCmHatColWest02_Hr",
	"T_C_ImpEpColHat01_Hr",
	"T_C_ImpEpColHat02_Hr",
	"T_C_ImpEpHatColWest01_Hr",
	"T_C_ImpEpHatColWest02_Hr",
	"T_C_ImpEtHatColNorth01_Hr",
	"T_C_ImpEtHatColNorth02_Hr",
	"T_C_ImpEtHatColNorth03_Hr",
	"T_C_ImpEtHatColNorth04_Hr",
	"T_C_ImpEtHatColNorth05_Hr",
	"T_A_ReaLeatherHat01_Hr",
	"T_C_RgaCmHat01_Hr",
	"T_C_RgaCmHat02_Hr",
	"T_C_RgaCmHat03_Hr",
}

-- clothing id
local embedments = {
}

-- bodypart id
local male_imga_helmets = {
}

-- (cell ids), (journal topic id, journal index), global id, (container id, (container cell id, container cell x, container cell y), container position)
local react_cells = {
	--{ cells = { "" }, journal = { id = "", index = 0 }, global = "", container = { id = "", cell = { id = "", x = 0, y = 0 }, position = { 0, 0, 0} } }
}

local TD_ButterflyMothTooltip = {}

-- Taken from MWSE's documentation
---@param data table
---@param defaults table
local function initTableValues(data, defaults)
    for k,v in pairs(defaults) do
        if data[k] == nil then
            if type(v) ~= "table" then
                data[k] = v
            elseif v == {} then
                data[k] = {}
            else
                data[k] = {}
                initTableValues(data[k], v)
            end
        end
    end
end

--- @param e uiActivatedEventData
local function changeRaceMenuKhajiitNames(e)
	if tes3.findRace("T_Els_Suthay") and tes3.findRace("T_Els_Suthay").isPlayable then	-- Races (and ESPs that can enable races) cannot be accessed when config.lua runs, so this condition ensures that people who can only play as Suthay-raht just see it called "Khajiit" as in vanilla
    	local raceMenu = tes3ui.findMenu("MenuRaceSex")

    	if not raceMenu then return end

		local racePane = raceMenu:findChild("PartScrollPane_pane")

    	if not racePane then return end

		for _,layout in ipairs(racePane.children) do
			if layout.children[1] and layout.children[1].text == "Khajiit" then
				local race = layout.children[1]:getPropertyObject("MenuRaceSex_ListNumber")
				---@cast race tes3race

				if race.id == "Khajiit" then
					--layout.children[1].text = common.i18n("main.khajiit.khajiit") .. " (" .. common.i18n("main.khajiit.suthay-raht") .. ")"
					layout.children[1].text = common.i18n("main.khajiit.suthay-raht")	-- Unfortunately the vanilla pane is not wide enough to fully display the naming format above, so I am just using the form names here
				elseif race.id == "T_Els_Cathay" then
					layout.children[1].text = common.i18n("main.khajiit.cathay")
				elseif race.id == "T_Els_Cathay-raht" then
					layout.children[1].text = common.i18n("main.khajiit.cathay-raht")
				elseif race.id == "T_Els_Dagi-raht" then
					layout.children[1].text = common.i18n("main.khajiit.dagi-raht")
				elseif race.id == "T_Els_Ohmes" then
					layout.children[1].text = common.i18n("main.khajiit.ohmes")
				elseif race.id == "T_Els_Ohmes-raht" then
					layout.children[1].text = common.i18n("main.khajiit.ohmes-raht")
				elseif race.id == "T_Els_Suthay" then
					layout.children[1].text = common.i18n("main.khajiit.suthay")
				end
			end
		end

		--racePane:sortChildren(function(a, b) return a.children[1].text <= b.children[1].text end)	-- I would rather use this only when keeping "Khajiit" in the names
	end
end

-- The following function is based on one that G7 made for Graphic Herbalism
---@param e uiObjectTooltipEventData
local function butterflyMothTooltip(e)
	if e.reference and e.reference.baseObject.objectType == tes3.objectType.creature and common.isFromTD(e.reference.baseObject, false) then
		local refID = e.reference.baseObject.id
		local isButterfly = refID:find("Butterfly")
		local isMoth = refID:find("Moth")
		if isButterfly or isMoth then
			local visibleEffects = math.clamp(math.floor(tes3.mobilePlayer.alchemy.current / tes3.findGMST(tes3.gmst.fWortChanceValue).value), 0, 4)

			local first, second = refID:find("_%a+_")
			local region = refID:sub(first + 1, second - 1)

			-- The ID could be found by looking through the creatures script instead, but this should be quicker and will work as long as the format of the IDs remains consistent
			local ingredientID = "T_IngCrea_"
			if isButterfly then ingredientID = ingredientID .. "ButterflyWing" .. region .. refID:sub(-3)
			elseif refID == "T_Cyr_Fau_Moth_01" then ingredientID = "T_IngCrea_MoonMothWing_01"	-- Thanks to this item being older than the creatures, its ID has a different format than the other ingredients.
			elseif isMoth then ingredientID = ingredientID .. "MothWing" .. region .. refID:sub(-3) end

			local ingredient = tes3.getObject(ingredientID)

			if ingredient then
				local parent = e.tooltip:createBlock({ id = TD_ButterflyMothTooltip.parent })
				parent.flowDirection = "top_to_bottom"
				parent.childAlignX = 0.5
				parent.autoHeight = true
				parent.autoWidth = true

				local label = parent:createLabel({ id = TD_ButterflyMothTooltip.weight, text = string.format(common.i18n("main.tooltipWeight") .. ": %.2f", ingredient.weight) })
				label.wrapText = true

				local label = parent:createLabel({ id = TD_ButterflyMothTooltip.value, text = string.format(common.i18n("main.tooltipValue") .. ": %d", ingredient.value) })
				label.wrapText = true

				for i = 1, 4 do
					local effect = tes3.getMagicEffect(ingredient.effects[i])
					local target = math.max(ingredient.effectAttributeIds[i], ingredient.effectSkillIds[i])

					local block = parent:createBlock({ id = TD_ButterflyMothTooltip[i] })
					block.autoHeight = true
					block.autoWidth = true

					if effect == nil then
					elseif i > visibleEffects then
						local label = block:createLabel({ text = "?" })
						label.wrapText = true
					else
						local image = block:createImage({ path = ("icons\\" .. effect.icon) })
						image.wrapText = false
						image.borderLeft = 4

						local targetName
						if effect.targetsAttributes then
							targetName = tes3.findGMST(888 + target).value
						elseif effect.targetsSkills then
							targetName = tes3.findGMST(896 + target).value
						end

						local effectName
						if targetName then
							effectName = tes3.findGMST(1283 + effect.id).value:match("%S+") .. " " .. targetName
						else
							effectName = effect.name
						end

						local label = block:createLabel({ text = effectName })
						label.wrapText = false
						label.borderLeft = 4
					end
				end
			end
		end
	end
end

---@param e bodyPartAssignedEventData
local function hideWerewolfBodyParts(e)
	local werewolfBodyParts = {
		"WerewolfHair",
		"WerewolfHead",
		"WerewolfSkin",
		"WerewolfSkin.1st"
	}

	if e.bodyPart and table.contains(werewolfBodyParts, e.bodyPart.id) and not (tes3.getGlobal("T_Glob_WereInfected") == 0 or tes3.getGlobal("T_Glob_WereInfected") == 2) then return false end
end

---@param e equippedEventData
local function hatHelmetEquipped(e)
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
local function replaceHatCell(e)
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
local function replaceHatLeveledItem(e)
	if e.pick and e.pick.objectType == tes3.objectType.armor and e.pick.slot == tes3.armorSlot.helmet and not e.pick.isClosedHelmet then
		if common.isFromTD(e.pick, false) or common.isFromPTR(e.pick, false)then
			local hatItem = tes3.getObject(e.pick.id .. "H")
			if hatItem and not hatItem.sourceMod then e.pick = hatItem end
		end
	end
end

local function createHatObjects()
	for armor in tes3.iterateObjects(tes3.objectType.armor) do
		---@cast armor tes3armor
		if armor.slot == tes3.armorSlot.helmet and not armor.isClosedHelmet then	-- Closed helmets are not going to be hats by definition
			if common.isFromTD(armor, false) or common.isFromPTR(armor, false) then -- Only affect TD hats or unique variants from PTR
				if armor.id:find("Hat") or armor.name:find("Hat") or armor.icon:lower():find("hat") or armor.id:find("Hood") or armor.name:find("Hood") or armor.icon:lower():find("hood") then	-- Check whether these conditions are actually worth having
					for _,v in pairs(hats) do
						if armor.parts[1] and armor.parts[1].male and armor.parts[1].male.id == v and #(armor.id .. "H") < 32 then
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

local function changeEmbedmentsSlot()
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
local function embedmentLoaded(e)
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
local function embedmentMobileActivated(e)
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
local function embedmentUnequipped(e)
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
local function embedmentEquipped(e)
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
local function restrictRaceEquip(e)
	if e.reference.baseObject.objectType == tes3.objectType.npc then
		if e.reference.mobile.object.race.id == "T_Val_Imga" then
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.boots then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.imgaShoes"))
					end

					return false
				end

				if e.item.slot == tes3.armorSlot.helmet then
					if not e.reference.mobile.object.female then
						if e.item.parts[1] and e.item.parts[1].male and not table.contains(male_imga_helmets, e.item.parts[1].male.id) then
							if e.reference.mobile == tes3.mobilePlayer then
								tes3ui.showNotifyMenu(common.i18n("main.imgaHelm"))
							end

							return false
						end
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.shoes then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.imgaShoes"))
					end

					return false
				end

				if e.item.slot == tes3.clothingSlot.hat then
					if not e.reference.mobile.object.female then
						if e.item.parts[1] and e.item.parts[1].male and not table.contains(male_imga_helmets, e.item.parts[1].male.id) then
							if e.reference.mobile == tes3.mobilePlayer then
								tes3ui.showNotifyMenu(common.i18n("main.imgaHat"))
							end

							return false
						end
					end
				end
			end
		elseif e.reference.mobile.object.race.id == "T_Aka_Tsaesci" then
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.boots then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciShoes"))
					end

					return false
				end

				if e.item.slot == tes3.armorSlot.greaves then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.tsaesciPants"))
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
		elseif e.reference.mobile.object.race.id == "T_Cyr_Minotaur" then
			if e.item.objectType == tes3.objectType.armor then
				if e.item.slot == tes3.armorSlot.boots then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.minotaurShoes"))
					end

					return false
				end

				if e.item.slot == tes3.armorSlot.helmet then
					if e.item.parts[1] and e.item.parts[1].male and not table.contains(male_imga_helmets, e.item.parts[1].male.id) then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.minotaurHelm"))
						end

						return false
					end
				end
			end

			if e.item.objectType == tes3.objectType.clothing then
				if e.item.slot == tes3.clothingSlot.shoes then
					if e.reference.mobile == tes3.mobilePlayer then
						tes3ui.showNotifyMenu(common.i18n("main.minotaurShoes"))
					end

					return false
				end

				if e.item.slot == tes3.clothingSlot.hat then
					if e.item.parts[1] and e.item.parts[1].male and not table.contains(male_imga_helmets, e.item.parts[1].male.id) then
						if e.reference.mobile == tes3.mobilePlayer then
							tes3ui.showNotifyMenu(common.i18n("main.minotaurHat"))
						end

						return false
					end
				end
			end
		end
	end
end

---@param e bodyPartAssignedEventData
local function fixVampireHeadAssignment(e)
	if e.reference.baseObject.objectType == tes3.objectType.npc and e.index == tes3.activeBodyPart.head then
		if not e.object or e.object.objectType ~= tes3.objectType.armor then
			if e.reference.mobile and e.reference.mobile.object then
				if e.reference.mobile.object.baseObject.head.id == "T_B_De_UNI_HeadOrlukhTR" then	-- Handles the unique head for Varos of the Orlukh bloodline
						e.bodyPart = e.reference.mobile.object.baseObject.head
				elseif e.reference.mobile.object.baseObject.head.id == "T_B_Imp_UNI_HeadHerrius2PC" then	-- Handles the unique head for Herrius Thimistrel when he is openly a vampire
						e.bodyPart = e.reference.mobile.object.baseObject.head
				elseif e.reference.mobile.object.baseObject.head.id == "T_B_Imp_UNI_HeadHerriusPC" then	-- Handles the unique head for Herrius Thimistrel
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
				else
					if e.reference.mobile.hasVampirism and common.isFromPTR(e.reference, true) then	-- Sometimes the no head shows up on PTR vampires for unclear reasons. Hopefully this fixes that.
						if e.reference.baseObject.female then e.bodyPart = e.reference.baseObject.race.femaleBody.vampireHead
						else e.bodyPart = e.reference.baseObject.race.maleBody.vampireHead end
					end
				end
			end
		end
	end

	if e.index == tes3.activeBodyPart.hair then	-- Check for being an NPC too?
		if not e.object or e.object.objectType ~= tes3.objectType.armor then
			if e.reference.mobile and e.reference.mobile.object then
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

---@param e combatStartedEventData
local function vampireHeadCombatStarted(e)
	if e.actor.objectType == tes3.objectType.mobileNPC and e.actor.reference.bodyPartManager then
		local head = e.actor.reference.bodyPartManager:getActiveBodyPart(tes3.activeBodyPartLayer.base, tes3.activeBodyPart.head)
		if head.bodyPart and head.bodyPart.id == "T_B_Imp_UNI_HeadHerriusPC" then
			e.actor.reference:updateEquipment()		-- Will trigger fixVampireHeadAssignment via the bodyPartAssigned event
		end
	end
end

---@param e playItemSoundEventData
local function improveItemSounds(e)
	for _,v in pairs(item_sounds) do
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
	for _,v in pairs(travel_actor_prices) do
		local actorID, destinationID, factor = unpack(v, 1, 3)
		if e.reference.baseObject.id == actorID and (not destinationID or e.destination.cell.id == destinationID) then
			e.price = math.round(e.price * factor)	-- The price seems to work regardless, but I'm paranoid
			return
		end
	end

	if e.reference.mobile.objectType == tes3.objectType.mobileNPC then
		local providerInstance = e.reference.mobile.object
		if providerInstance.faction and providerInstance.faction.id:find("Mages") and providerInstance.factionRank > 3 then	-- Increase price of teleporting between MG networks
			e.price = e.price * 5;
		end
	end
end

---@param e itemDroppedEventData
local function markReactCellItem(e)
	for _,reactCell in pairs(react_cells) do
		for _,cellID in pairs(reactCell.cells) do
			if e.reference.cell.id == cellID then
				e.reference.data.tamrielData = e.reference.data.tamrielData or {}
				e.reference.data.tamrielData.playerItem = true
				break
			end
		end
	end
end

---@param e journalEventData
local function moveReactCellItems(e)
	for _,reactCell in pairs(react_cells) do
		if e.topic.id == reactCell.journal.id and e.index >= reactCell.journal.index then
			local hasRun = false
			for _,pastReactCellJournal in pairs(tes3.player.data.tamrielData.pastReactCellJournals) do							-- The pastReactCellJournals are checked so that cells are only gone through once.
				if reactCell.journal.id == pastReactCellJournal[1] and reactCell.journal.index == pastReactCellJournal[2] then	-- The reactCell values (and not the event data's) are used so that all cells are gone through if there are reactions to multiple journal indices and the index jumps over the lower indices
					hasRun = true
					break
				end
			end

			if not hasRun then
				local containerCell
				if reactCell.container.cell.id then containerCell = tes3.getCell({ id = reactCell.container.cell.id })		-- These conditions are needed to handle both interior and exterior containerCells
				else containerCell = tes3.getCell({ x = reactCell.container.cell.x, y = reactCell.container.cell.y }) end
				local playerItemsContainer

				if containerCell then
					for container in containerCell:iterateReferences(tes3.objectType.container, false) do
						if container.baseObject.id == reactCell.container.id and container.position == reactCell.container.position then
							playerItemsContainer = container
							break
						end
					end
				end

				if playerItemsContainer then
					for _,cellID in pairs(reactCell.cells) do
						local cell = tes3.getCell({ id = cellID })

						if cell then -- This doesn't yet go over items that have been placed in containers or disable items after adding them to playerItemsContainer
							for ref in cell:iterateReferences({ tes3.objectType.alchemy, tes3.objectType.ammunition, tes3.objectType.apparatus, tes3.objectType.armor, tes3.objectType.book, tes3.objectType.clothing, tes3.objectType.ingredient, tes3.objectType.light, tes3.objectType.lockpick, tes3.objectType.miscItem, tes3.objectType.probe, tes3.objectType.repairItem, tes3.objectType.weapon }) do
								if ref.data.tamrielData and ref.data.tamrielData.playerItem then
									local owner, requirement = tes3.getOwner({ reference = ref })
									local count, item, itemData = tes3.addItem({ reference = playerItemsContainer, item = ref.baseObject, itemData = ref.itemData, playSound = false })

									itemData.owner = owner				-- The ownership data is removed from itemData by addItem, so it must be added back here
									itemData.requirement = requirement
								end
							end
						end
					end
				end

				table.insert(tes3.player.data.tamrielData.pastReactCellJournals, { reactCell.journal.id, reactCell.journal.index })
			end
		end

		-- break cannot be used here because that might cause other suitable reactCells with different indices to be missed
	end
end

---@param cell tes3cell
---@param regionTable table
---@return boolean
local function isInterventionCell(cell, regionTable)
	for k,v in pairs(regionTable) do
		local regionID, xLeft, xRight, yBottom, yTop = unpack(v, 1, 5)
			if (cell.region and cell.region.id == regionID) or cell.region == regionID then
				if not xLeft then -- Checks whether cell boundaries are being used; if xLeft is nil, then all of the others should be too
					return true
				else
					if (cell.gridX >= xLeft) and (cell.gridX <= xRight) and (cell.gridY >= yBottom) and (cell.gridY <= yTop) then
						return true
					else
						return false
					end
				end
			end
	end

	return false
end

---@param e magicCastedEventData
local function limitInterventionMessage(e)
	for k,v in pairs(e.source.effects) do
		if v.id == tes3.effect.almsiviIntervention then
			local extCell = common.getExteriorCell(e.caster.cell)

			if not extCell or not isInterventionCell(extCell, almsivi_intervention_regions) then
				tes3ui.showNotifyMenu(common.i18n("main.rangeAlmsivi"))
			end
		elseif v.id == tes3.effect.T_intervention_Kyne then
			local extCell = common.getExteriorCell(e.caster.cell)

			if not extCell or not isInterventionCell(extCell, kyne_intervention_regions) then
				tes3ui.showNotifyMenu(common.i18n("main.rangeKyne"))
			end
		end
	end
end

---@param e spellTickEventData
local function limitIntervention(e)
	for _,v in pairs(e.source.effects) do
		if v.id == tes3.effect.almsiviIntervention then
			local cellVisitTable = { e.caster.cell }
			local extCell = common.getExteriorCell(e.caster.cell, cellVisitTable)

			if not extCell or not isInterventionCell(extCell, almsivi_intervention_regions) then
				return false
			end
		elseif v.id == tes3.effect.T_intervention_Kyne then
			local cellVisitTable = { e.caster.cell }
			local extCell = common.getExteriorCell(e.caster.cell, cellVisitTable)

			if not extCell or not isInterventionCell(extCell, kyne_intervention_regions) then
				return false
			end
		end
	end
end

-- Checks the player's race and replaces it with an animation file if one is needed
local function fixPlayerAnimations()
	if tes3.player.object.race.id == "T_Els_Ohmes-raht" or tes3.player.object.race.id == "T_Els_Suthay" then
		if tes3.player.object.female then
			tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_f.nif" })
		else
			tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_m.nif" })
		end
	elseif tes3.player.object.race.id == "T_Aka_Tsaesci" then
		tes3.loadAnimation({ reference = tes3.player, file = "pi_tsa_base_anim.nif" })
	elseif tes3.player.object.race.id == "T_Cyr_Minotaur" then
		tes3.loadAnimation({ reference = tes3.player, file = "pc_min_base_anim.nif" })
	end
end

-- Setup MCM
dofile("TamrielData.mcm")

event.register(tes3.event.loaded, function()

	-- Initialize player data
	local data = tes3.player.data
    data.tamrielData = data.tamrielData or {}
    local myData = data.tamrielData
    initTableValues(myData, player_data_defaults)

	if config.summoningSpells then
		event.register(tes3.event.determinedAction, magic.useCustomSpell, { unregisterOnLoad = true })
	end

	if config.boundSpells then
		--event.register(tes3.event.itemTileUpdated, magic.boundKnivesTileUpdate, { unregisterOnLoad = true })
		--event.register(tes3.event.playItemSound, magic.boundKnivesDropSound, { unregisterOnLoad = true })
		--event.register(tes3.event.itemDropped, magic.boundKnivesItemDropped, { priority = 1100, unregisterOnLoad = true })
	end

	if config.interventionSpells then
		magic.replaceInterventionMarkers(kyne_intervention_cells, "T_Aid_KyneInterventionMarker")
	end

	if config.miscSpells then
		event.register(tes3.event.uiSpellTooltip, magic.correctSpellTooltipUnit, { unregisterOnLoad = true })

		event.register(tes3.event.equip, magic.etherealEquipPotion, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.playItemSound, magic.etherealDropSound, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.itemDropped, magic.etherealItemDropped, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.activate, magic.etherealActivate, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.enchantChargeUse, magic.etherealEnchantChargeUse, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.spellCast, magic.etherealSpellCast, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.spellMagickaUse, magic.etherealspellMagickaUse, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.magicReflect, magic.etherealMagicReflect, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.absorbedMagic, magic.etherealAbsorbedMagic, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.spellResist, magic.etherealSpellResist, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.damage, magic.etherealDamage, { priority = 1000, unregisterOnLoad = true })
		event.register(tes3.event.simulate, magic.etherealOpacity, { priority = 10, unregisterOnLoad = true })		-- Priority is set so that the function runs before Detect Invisibility's opacity function, though that probably won't ever matter

		event.register(tes3.event.damage, magic.magickaWardEffect, { priority = -10, unregisterOnLoad = true })		-- Priority is set so that the function runs after Reflect Damage affects the damage

		event.register(tes3.event.spellMagickaUse, magic.bloodMagicCast, { unregisterOnLoad = true })

		timer.start{ duration = 0.0166667, iterations = -1, type = timer.simulate, callback = magic.prismaticLightTick }
		event.register(tes3.event.referenceActivated, magic.onPrismaticLightReferenceActivated, { unregisterOnLoad = true })
		event.register(tes3.event.referenceDeactivated, magic.onPrismaticLightReferenceDeactivated, { unregisterOnLoad = true })

		event.register(tes3.event.spellCast, magic.fortifyCastingOnSpellCast, { unregisterOnLoad = true })

		timer.start{ duration = 1, iterations = -1, type = timer.simulate, callback = magic.removeBlinkData }
		event.register(tes3.event.cellChanged, magic.removeBlinkData, { unregisterOnLoad = true })			-- Ensures that the player is not damaged by blinkFallDamageSmallJump if they enter a cell as they fall.
		event.register(tes3.event.simulated, magic.blinkFallDamageSmallJump, { unregisterOnLoad = true })
		event.register(tes3.event.damage, magic.blinkFallDamage, { unregisterOnLoad = true })

		tes3.getObject("T_B_GazeVeloth_Skeleton_01").partType = tes3.activeBodyPartLayer.base		-- I don't want these body parts to be associated with a race, so I set them to be base layer here rather than in the CS; the race name of the body part needs to be removed from the ESP that will be merged though
		tes3.getObject("T_B_GazeVeloth_SkeletonArg_01").partType = tes3.activeBodyPartLayer.base
		tes3.getObject("T_B_GazeVeloth_SkeletonKha_01").partType = tes3.activeBodyPartLayer.base
		tes3.getObject("T_B_GazeVeloth_SkeletonKha_02").partType = tes3.activeBodyPartLayer.base
		tes3.getObject("T_B_GazeVeloth_SkeletonOrc_01").partType = tes3.activeBodyPartLayer.base
		event.register(tes3.event.addTempSound, magic.gazeOfVelothBlockActorSound, { unregisterOnLoad = true })
		event.register(tes3.event.bodyPartAssigned, magic.gazeOfVelothBodyPartAssigned, { unregisterOnLoad = true })

		timer.start{ duration = 1, iterations = -1, type = timer.simulate, callback = magic.distractedReturnTick }
		event.register(tes3.event.referenceActivated, magic.onDistractedReferenceActivated, { unregisterOnLoad = true })
		event.register(tes3.event.referenceDeactivated, magic.onDistractedReferenceDeactivated, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.distractRemovedEffect, { unregisterOnLoad = true })

		event.register(tes3.event.activate, magic.corruptionBlockActivation, { unregisterOnLoad = true })
		event.register(tes3.event.mobileActivated, magic.corruptionSummoned, { unregisterOnLoad = true })

		timer.start{ duration = tes3.findGMST("fMagicDetectRefreshRate").value, iterations = -1, type = timer.simulate, callback = magic.detectValuablesTick }
		event.register(tes3.event.magicCasted, magic.detectValuablesTick, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.detectValuablesTick, { unregisterOnLoad = true })

		timer.start{ duration = tes3.findGMST("fMagicDetectRefreshRate").value, iterations = -1, type = timer.simulate, callback = magic.detectInvisibilityTick }
		event.register(tes3.event.magicCasted, magic.detectInvisibilityTick, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.detectInvisibilityTick, { unregisterOnLoad = true })
		event.register(tes3.event.calcHitChance, magic.detectInvisibilityHitChance, { filter = tes3.player.baseObject, unregisterOnLoad = true })
		event.register(tes3.event.simulate, magic.detectInvisibilityOpacity, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.invisibilityRemovedEffect, { unregisterOnLoad = true })
		event.register(tes3.event.spellTick, magic.invisibilityAppliedEffect, { unregisterOnLoad = true })
		event.register(tes3.event.mobileActivated, magic.onInvisibleMobileActivated, { unregisterOnLoad = true })
		event.register(tes3.event.mobileDeactivated, magic.onInvisibleMobileDeactivated, { unregisterOnLoad = true })

		timer.start{ duration = tes3.findGMST("fMagicDetectRefreshRate").value, iterations = -1, type = timer.simulate, callback = magic.detectEnemyTick }
		event.register(tes3.event.magicCasted, magic.detectEnemyTick, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.detectEnemyTick, { unregisterOnLoad = true })

		timer.start{ duration = tes3.findGMST("fMagicDetectRefreshRate").value, iterations = -1, type = timer.simulate, callback = magic.detectHumanoidTick }
		event.register(tes3.event.magicCasted, magic.detectHumanoidTick, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.detectHumanoidTick, { unregisterOnLoad = true })

		event.register(tes3.event.leveledItemPicked, magic.insightEffect, { unregisterOnLoad = true })

		event.register(tes3.event.spellResist, magic.radiantShieldSpellResist, { unregisterOnLoad = true })
		event.register(tes3.event.magicEffectRemoved, magic.radiantShieldBlindnessRemoved, { unregisterOnLoad = true })
		event.register(tes3.event.damaged, magic.radiantShieldDamaged, { unregisterOnLoad = true })

		event.register(tes3.event.damaged, magic.reflectDamageStun, { unregisterOnLoad = true })
		event.register(tes3.event.damagedHandToHand, magic.reflectDamageStun, { unregisterOnLoad = true })
		event.register(tes3.event.damage, magic.reflectDamageEffect, { unregisterOnLoad = true })
		event.register(tes3.event.damageHandToHand, magic.reflectDamageHHEffect, { unregisterOnLoad = true })

		event.register(tes3.event.cellChanged, magic.banishDaedraCleanup, { unregisterOnLoad = true })
		event.register(tes3.event.containerClosed, magic.deleteBanishDaedraContainer, { unregisterOnLoad = true })

		event.register(tes3.event.magicCasted, magic.passwallEffect, { unregisterOnLoad = true })
	end

	if config.provincialReputation then
		event.register(tes3.event.menuEnter, reputation.switchReputation, { filter = "MenuDialog", unregisterOnLoad = true })
		event.register(tes3.event.menuExit, reputation.switchReputation, { unregisterOnLoad = true })
		event.register(tes3.event.cellChanged, reputation.travelSwitchReputation, { unregisterOnLoad = true })

		event.register(tes3.event.uiRefreshed, reputation.uiRefreshedCallback, { filter = "MenuStat_scroll_pane", unregisterOnLoad = true })
		event.register(tes3.event.menuEnter, function(e) tes3ui.updateStatsPane() end, { unregisterOnLoad = true })
	end

	if config.provincialFactionUI then
		event.register(tes3.event.uiRefreshed, factions.uiRefreshedCallback, { priority = 5, filter = "MenuStat_scroll_pane", unregisterOnLoad = true })	-- Priority is set so that UI Expansion affects the tooltips and Tidy Charsheet moves the labels over to the left.
		event.register(tes3.event.menuEnter, function(e) tes3ui.updateStatsPane() end, { unregisterOnLoad = true })

		tes3.getFaction("Fighters Guild").name = common.i18n("main.morrowindFightersGuild")
		tes3.getFaction("Mages Guild").name = common.i18n("main.morrowindMagesGuild")
		tes3.getFaction("Thieves Guild").name = common.i18n("main.morrowindThievesGuild")
		tes3.getFaction("Imperial Legion").name = common.i18n("main.morrowindImperialLegion")
		tes3.getFaction("Dark Brotherhood").name = common.i18n("main.morrowindDarkBrotherhood")
	end

	if config.weatherChanges then
		weather.changeRegionWeatherChances()

		event.register(tes3.event.cellChanged, weather.manageWeathers, { unregisterOnLoad = true })
		event.register(tes3.event.weatherChangedImmediate, weather.manageWeathers, { unregisterOnLoad = true })
		event.register(tes3.event.weatherTransitionStarted, weather.manageWeathers, { unregisterOnLoad = true })

		event.register(tes3.event.cellChanged, weather.changeStormOrigin, { unregisterOnLoad = true })
		event.register(tes3.event.weatherChangedImmediate, weather.changeStormOrigin, { unregisterOnLoad = true })
		event.register(tes3.event.weatherTransitionStarted, weather.changeStormOrigin, { unregisterOnLoad = true })

		event.register(tes3.event.soundObjectPlay, weather.silenceCreatures, { unregisterOnLoad = true })
	end

	if config.hats then
		if not tes3.clothingSlot.hat then tes3.addClothingSlot({ slot = 24, name = "Hat", key = "hat" }) end
		createHatObjects()

		event.register(tes3.event.leveledItemPicked, replaceHatLeveledItem, { priority = -100, unregisterOnLoad = true })
		event.register(tes3.event.cellChanged, replaceHatCell, { unregisterOnLoad = true })
		event.register(tes3.event.equipped, hatHelmetEquipped, { unregisterOnLoad = true })
	end

	if config.embedments then
		if not tes3.clothingSlot.embedment then tes3.addClothingSlot({ slot = 25, name = "Embedment", key = "embedment" }) end
		changeEmbedmentsSlot()

		event.register(tes3.event.cellChanged, embedmentLoaded, { unregisterOnLoad = true })
		event.register(tes3.event.mobileActivated, embedmentMobileActivated, { unregisterOnLoad = true })
		event.register(tes3.event.equipped, embedmentEquipped, { unregisterOnLoad = true })
		event.register(tes3.event.unequipped, embedmentUnequipped, { unregisterOnLoad = true })
	end

	if config.creatureBehaviors then
		event.register(tes3.event.cellChanged, behavior.fixWelkyndSpiritLight, { unregisterOnLoad = true })
		event.register(tes3.event.playGroup, behavior.loopStridentRunnerNesting, { unregisterOnLoad = true })
		event.register(tes3.event.activate, behavior.onNestLoot, { priority = 250, unregisterOnLoad = true })	-- The priority is set so that the function is guranteed to work with GH even if the nests are removed from the blacklist
		event.register(tes3.event.combatStarted, behavior.onGroupAttacked, { unregisterOnLoad = true })

		--event.register(tes3.event.combatStart, behavior.claimCombatFleeing, { priority = 100, unregisterOnLoad = true })
		--event.register(tes3.event.combatStarted, behavior.claimCombatFleeing, { priority = 100, unregisterOnLoad = true })
		--event.register(tes3.event.musicChangeTrack, behavior.blockMusicFromFleeing, { unregisterOnLoad = true })
		--event.register(tes3.event.determinedAction, behavior.fleeFromPlayerCombatAction, { unregisterOnLoad = true })
		--timer.start{ duration = 5, iterations = -1, type = timer.simulate, callback = behavior.fleeFromPlayerTick }
		timer.start{ duration = 5, iterations = -1, type = timer.simulate, callback = behavior.creatureDetectionTick }	-- Morrowind's AI is updated every 5 seconds, which is why that value is used here.

		event.register(tes3.event.cellChanged, behavior.onFirstCellLoad, { unregisterOnLoad = true })
		event.register(tes3.event.mobileActivated, behavior.onMobileActivated, { unregisterOnLoad = true })
		event.register(tes3.event.mobileDeactivated, behavior.onMobileDeactivated, { unregisterOnLoad = true })
	end

	if config.fixPlayerRaceAnimations then
		fixPlayerAnimations()
	end

	if config.hideWerewolfMesh then
		event.register(tes3.event.bodyPartAssigned, hideWerewolfBodyParts, { unregisterOnLoad = true })
	end

	if config.restrictEquipment then
		event.register(tes3.event.equip, restrictRaceEquip, { unregisterOnLoad = true })
	end

	if config.fixVampireHeads then
		event.register(tes3.event.bodyPartAssigned, fixVampireHeadAssignment, { unregisterOnLoad = true })
		event.register(tes3.event.combatStarted, vampireHeadCombatStarted, { unregisterOnLoad = true })
	end

	if config.improveItemSounds then
		event.register(tes3.event.playItemSound, improveItemSounds, { unregisterOnLoad = true })
	end

	if config.adjustTravelPrices then
		event.register(tes3.event.calcTravelPrice, adjustTravelPrices, { unregisterOnLoad = true })
	end

	if config.handleReactCellItems then
		myData.pastReactCellJournals = {}
		event.register(tes3.event.itemDropped, markReactCellItem, { unregisterOnLoad = true })
		event.register(tes3.event.journal, moveReactCellItems, { unregisterOnLoad = true })
	end

	if config.khajiitFormCharCreation then
		event.register(tes3.event.uiActivated, changeRaceMenuKhajiitNames, { filter = "MenuRaceSex", unregisterOnLoad = true })
	end

	if config.butterflyMothTooltip then
		TD_ButterflyMothTooltip.parent = tes3ui.registerID("TD_ButterflyMothTooltip_Parent")
		TD_ButterflyMothTooltip.weight = tes3ui.registerID("TD_ButterflyMothTooltip_Weight")
		TD_ButterflyMothTooltip.value = tes3ui.registerID("TD_ButterflyMothTooltip_Value")
		TD_ButterflyMothTooltip[1] = tes3ui.registerID("TD_ButterflyMothTooltip_Effect_1")
		TD_ButterflyMothTooltip[2] = tes3ui.registerID("TD_ButterflyMothTooltip_Effect_2")
		TD_ButterflyMothTooltip[3] = tes3ui.registerID("TD_ButterflyMothTooltip_Effect_3")
		TD_ButterflyMothTooltip[4] = tes3ui.registerID("TD_ButterflyMothTooltip_Effect_4")

		event.register(tes3.event.uiObjectTooltip, butterflyMothTooltip, { priority = 200, unregisterOnLoad = true })
	end

	if config.limitIntervention then
		event.register(tes3.event.magicCasted, limitInterventionMessage, { unregisterOnLoad = true })
		event.register(tes3.event.spellTick, limitIntervention, { unregisterOnLoad = true })
	end

end)

event.register(tes3.event.initialized, function()
	--tes3.findRace("Argonian").abilities:add("T_Arg_Mys_BloodMagic")	-- This has to be done during initialization or Argonian players won't have the spell upon loading a save
end)