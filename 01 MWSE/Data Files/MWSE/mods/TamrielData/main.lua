--[[
	Tamriel Data MWSE-Lua Addon v1.2
	By mort and Kynesifnar
]]

-- Make sure we have an up-to-date version of MWSE.
if (mwse.buildDate == nil) or (mwse.buildDate < 20240617) then
    event.register(tes3.event.initialized, function()
        tes3.messageBox(
            "[Tamriel Data] Your MWSE is out of date!"
            .. " You will need to update to a more recent version to use this mod."
        )
    end)
    return
end

-- Util functions
function table.contains(table, element)
	for _,v in pairs(table) do
	  if v == element then
		return true
	  end
	end
	return false
end

local function getExteriorCell(cell, cellVisitTable)
	if cell.isOrBehavesAsExterior then
		return cell
	end
	
	for ref in tes3.iterate(cell.activators) do
		if ref.destination and not table.contains(cellVisitTable, ref.destination.cell) then
			table.insert(cellVisitTable, ref.destination.cell)
			return getExteriorCell(ref.destination.cell, cellVisitTable)
		end
	end
end

local function isInterventionCell(cell, regionList)
	for k,v in pairs(regionList) do
		local regionID, xLeft, xRight, yBottom, yTop = unpack(v)
			if (cell.region and cell.region.id == regionID) or cell.region == regionID then
				if not xLeft then
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

local config = require("tamrielData.config")
mwse.log("[Tamriel Data MWSE-Lua] Initialized Version 1.2")

-- Register the mod config menu (using EasyMCM library).
event.register(tes3.event.modConfigReady, function()
    require("tamrielData.mcm")
end)

if config.summoningSpells == true then
	tes3.claimSpellEffectId("T_summon_Devourer", 2090)
	tes3.claimSpellEffectId("T_summon_DremArch", 2091)
	tes3.claimSpellEffectId("T_summon_DremCast", 2092)
	tes3.claimSpellEffectId("T_summon_Guardian", 2093)
	tes3.claimSpellEffectId("T_summon_LesserClfr", 2094)
	tes3.claimSpellEffectId("T_summon_Ogrim", 2095)
	tes3.claimSpellEffectId("T_summon_Seducer", 2096)
	tes3.claimSpellEffectId("T_summon_SeducerDark", 2097)
	tes3.claimSpellEffectId("T_summon_Vermai", 2098)
	tes3.claimSpellEffectId("T_summon_AtroStormMon", 2099)
	tes3.claimSpellEffectId("T_summon_SummonIceWraith", 2100)
	tes3.claimSpellEffectId("T_summon_SummonDweSpectre", 2101)
	tes3.claimSpellEffectId("T_summon_SummonSteamCent", 2102)
	tes3.claimSpellEffectId("T_summon_SummonSpiderCent", 2103)
	tes3.claimSpellEffectId("T_summon_SummonWelkyndSpirit", 2104)
	tes3.claimSpellEffectId("T_summon_SummonAuroran", 2105)
end

-- unique id, spell id to override, spell name, creature id, effect mana cost, spell mana cost, icon, spell duration
local tr_summons = {	
	{ 2090, "T_Com_Cnj_SummonDevourer", "Summon Devourer", "T_Dae_Cre_Devourer_01", 52, 155, "td\\s\\tr_s_summ_dev.dds", 60},
	{ 2091, "T_Com_Cnj_SummonDremoraArcher", "Summon Dremora Archer", "T_Dae_Cre_Drem_Arch_01", 33, 98, "s\\Tx_S_Smmn_Drmora.tga", 60},
	{ 2092, "T_Com_Cnj_SummonDremoraCaster", "Summon Dremora Spellcaster", "T_Dae_Cre_Drem_Cast_01", 31, 93, "s\\Tx_S_Smmn_Drmora.tga", 60},
	{ 2093, "T_Com_Cnj_SummonGuardian", "Summon Guardian", "T_Dae_Cre_Guardian_01", 69, 207, "td\\s\\tr_s_sum_guard.dds", 60},
	{ 2094, "T_Com_Cnj_SummonLesserClannfear", "Summon Rock Chisel Clannfear", "T_Dae_Cre_LesserClfr_01", 22, 66, "s\\Tx_S_Smmn_Clnfear.tga", 60},
	{ 2095, "T_Com_Cnj_SummonOgrim", "Summon Ogrim", "ogrim", 33, 99, "td\\s\\tr_s_summ_ogrim.dds", 60},
	{ 2096, "T_Com_Cnj_SummonSeducer", "Summon Seducer", "T_Dae_Cre_Seduc_01", 52, 156, "td\\s\\tr_s_summ_sed.dds", 60},
	{ 2097, "T_Com_Cnj_SummonSeducerDark", "Summon Dark Seducer", "T_Dae_Cre_SeducDark_02", 75, 225, "td\\s\\tr_s_summ_d_sed.dds", 60},
	{ 2098, "T_Com_Cnj_SummonVermai", "Summon Vermai", "T_Dae_Cre_Verm_01", 29, 88, "td\\s\\tr_s_summ_vermai.dds", 60},
	{ 2099, "T_Com_Cnj_SummonStormMonarch", "Summon Storm Monarch", "T_Dae_Cre_MonarchSt_01", 60, 179, "s\\Tx_S_Smmn_StmAtnh.tga", 60},
	{ 2100, "T_Nor_Cnj_SummonIceWraith", "Summon Ice Wraith", "T_Sky_Cre_IceWr_01", 35, 104, "s\\Tx_S_Smmn_FrstAtrnh.tga", 60},
	{ 2101, "T_Dwe_Cnj_Uni_SummonDweSpectre", "Summon Dwemer Spectre", "dwarven ghost", 17, 52, "s\\Tx_S_Smmn_AnctlGht.tga", 60},
	{ 2102, "T_Dwe_Cnj_Uni_SummonSteamCent", "Summon Dwemer Steam Centurion", "centurion_steam", 29, 88, "s\\Tx_S_Smmn_Fabrict.dds", 60},
	{ 2103, "T_Dwe_Cnj_Uni_SummonSpiderCent", "Summon Dwemer Spider Centurion", "centurion_spider", 15, 46, "s\\Tx_S_Smmn_Fabrict.dds", 60},
	{ 2104, "T_Ayl_Cnj_SummonWelkyndSpirit", "Summon Welkynd Spirit", "T_Ayl_Cre_WelkSpr_01", 29, 78, "s\\Tx_S_Smmn_AnctlGht.tga", 60},
	{ 2105, "T_Com_Cnj_SummonAuroran", "Summon Auroran", "T_Dae_Cre_Auroran_01", 50, 130, "s\\Tx_S_Smmn_AnctlGht.tga", 60}
}

-- item id, pickup sound id, putdown sound id, equip sound id
local item_sounds = {	
	{ "T_Imp_Subst_Blackdrake_01", "Item Misc Up", "Item Misc Down", "bearsniff"},
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
	{ "Thirsk Region", nil, nil, nil, nil },
}

event.register(tes3.event.magicEffectsResolved, function()
	if config.summoningSpells == true then
		local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

		for k, v in pairs(tr_summons) do
			local effectID, spellID, spellName, creatureID, effectCost, spellCost, iconPath, duration = unpack(v)
			tes3.addMagicEffect{
				id = effectID,
				name = spellName,
				description = "",
				school = tes3.magicSchool.conjuration,
				baseCost = effectCost,
				speed = summonHungerEffect.speed,
				allowEnchanting = true,
				allowSpellmaking = true,
				appliesOnce = summonHungerEffect.appliesOnce,
				canCastSelf = true,
				canCastTarget = false,
				canCastTouch = false,
				casterLinked = summonHungerEffect.casterLinked,
				hasContinuousVFX = summonHungerEffect.hasContinuousVFX,
				hasNoDuration = summonHungerEffect.hasNoDuration,
				hasNoMagnitude = summonHungerEffect.hasNoMagnitude,
				illegalDaedra = summonHungerEffect.illegalDaedra,
				isHarmful = summonHungerEffect.isHarmful,
				nonRecastable = summonHungerEffect.nonRecastable,
				targetsAttributes = summonHungerEffect.targetsAttributes,
				targetsSkills = summonHungerEffect.targetsSkills,
				unreflectable = summonHungerEffect.unreflectable,
				usesNegativeLighting = summonHungerEffect.usesNegativeLighting,
				icon = iconPath,
				particleTexture = summonHungerEffect.particleTexture,
				castSound = summonHungerEffect.castSoundEffect.id,
				castVFX = summonHungerEffect.castVisualEffect.id,
				boltSound = summonHungerEffect.boltSoundEffect.id,
				boltVFX = summonHungerEffect.boltVisualEffect.id,
				hitSound = summonHungerEffect.hitSoundEffect.id,
				hitVFX = summonHungerEffect.hitVisualEffect.id,
				areaSound = summonHungerEffect.areaSoundEffect.id,
				areaVFX = summonHungerEffect.areaVisualEffect.id,
				lighting = {x = summonHungerEffect.lightingRed, y = summonHungerEffect.lightingGreen, z = summonHungerEffect.lightingBlue},
				size = summonHungerEffect.size,
				sizeCap = summonHungerEffect.sizeCap,
				onTick = function(eventData)
					eventData:triggerSummon(creatureID)
				end,
				onCollision = nil
			}
		end
	end

end)

local function fixVampireHeads(e)
	if e.index == tes3.activeBodyPart.head then
		if not e.object or e.object.objectType ~= tes3.objectType.armor then
			if e.reference.mobile then
				if e.reference.mobile.object then
					if e.reference.mobile.object.baseObject.head.id == "T_B_De_UNI_HeadOrlukhTR" then	-- Handles the unique head for Varos of the Orlukh bloodline
							e.bodyPart = e.reference.mobile.object.baseObject.head
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
end

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

event.register(tes3.event.loaded, function()
	if config.summoningSpells == true then
		for k,v in pairs(tr_summons) do
			local effectID, spellID, spellName, creatureID, effectCost, spellCost, iconPath, duration = unpack(v)

			local overridden_spell = tes3.getObject(spellID)
			overridden_spell.name = spellName
			overridden_spell.magickaCost = spellCost

			local effect = overridden_spell.effects[1]
			effect.id = effectID
			effect.duration = duration
		end
	end
	
	event.unregister(tes3.event.equip, restrictEquip)
	event.unregister(tes3.event.bodyPartAssigned, fixVampireHeads)
	event.unregister(tes3.event.playItemSound, improveItemSounds)
	event.unregister(tes3.event.spellTick, limitIntervention)
	event.unregister(tes3.event.magicCasted, limitInterventionMessage)
	event.unregister(tes3.event.spellTick, limitIntervention)
	
	if config.restrictEquipment == true then
		event.register(tes3.event.equip, restrictEquip)
	end
	
	if config.fixVampireHeads == true then
		event.register(tes3.event.bodyPartAssigned, fixVampireHeads)
	end
	
	if config.improveItemSounds == true then
		event.register(tes3.event.playItemSound, improveItemSounds)
	end
	
	if config.limitIntervention == true then
		event.register(tes3.event.magicCasted, limitInterventionMessage)
		event.register(tes3.event.spellTick, limitIntervention)
	end
	
	if config.fixPlayerRaceAnimations == true then
		if tes3.player.object.race.id == "T_Els_Ohmes-raht" or tes3.player.object.race.id == "T_Els_Suthay" then
			if tes3.player.object.female == false then
				tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_m.nif" })
			else
				tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_f.nif" })
			end
		end
	end
end)