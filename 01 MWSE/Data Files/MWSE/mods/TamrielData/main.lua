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

-- Util functions
function table.contains(table, element)
	for _,v in pairs(table) do
	  if v == element then
		return true
	  end
	end
	return false
end

---@param cell tes3cell
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

---@param cell tes3cell
local function isInterventionCell(cell, regionList)
	for k,v in pairs(regionList) do
		local regionID, xLeft, xRight, yBottom, yTop = unpack(v, 1, 5 )
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

if config.miscSpells == true then
	tes3.claimSpellEffectId("T_alteration_Passwall", 2106)
end

-- unique id, spell id to override, spell name, creature id, effect mana cost, spell mana cost, icon, spell duration, effect description
local td_summons = {	
	{ 2090, "T_Com_Cnj_SummonDevourer", "Summon Devourer", "T_Dae_Cre_Devourer_01", 52, 155, "td\\s\\tr_s_summ_dev.dds", 60, "This effect summons a devourer from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2091, "T_Com_Cnj_SummonDremoraArcher", "Summon Dremora Archer", "T_Dae_Cre_Drem_Arch_01", 33, 98, "s\\Tx_S_Smmn_Drmora.tga", 60, "This effect summons a dremora archer from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2092, "T_Com_Cnj_SummonDremoraCaster", "Summon Dremora Spellcaster", "T_Dae_Cre_Drem_Cast_01", 31, 93, "s\\Tx_S_Smmn_Drmora.tga", 60, "This effect summons a dremora spellcaster from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2093, "T_Com_Cnj_SummonGuardian", "Summon Guardian", "T_Dae_Cre_Guardian_01", 69, 207, "td\\s\\tr_s_sum_guard.dds", 60, "This effect summons a guardian from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2094, "T_Com_Cnj_SummonLesserClannfear", "Summon Rock Biter Clannfear", "T_Dae_Cre_LesserClfr_01", 22, 66, "s\\Tx_S_Smmn_Clnfear.tga", 60, "This effect summons a rock biter clannfear from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2095, "T_Com_Cnj_SummonOgrim", "Summon Ogrim", "ogrim", 33, 99, "td\\s\\tr_s_summ_ogrim.dds", 60, "This effect summons an ogrim from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2096, "T_Com_Cnj_SummonSeducer", "Summon Seducer", "T_Dae_Cre_Seduc_01", 52, 156, "td\\s\\tr_s_summ_sed.dds", 60, "This effect summons a seducer from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2097, "T_Com_Cnj_SummonSeducerDark", "Summon Dark Seducer", "T_Dae_Cre_SeducDark_02", 75, 225, "td\\s\\tr_s_summ_d_sed.dds", 60, "This effect summons a dark seducer from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2098, "T_Com_Cnj_SummonVermai", "Summon Vermai", "T_Dae_Cre_Verm_01", 29, 88, "td\\s\\tr_s_summ_vermai.dds", 60, "This effect summons a vermai from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2099, "T_Com_Cnj_SummonStormMonarch", "Summon Storm Monarch", "T_Dae_Cre_MonarchSt_01", 60, 179, "s\\Tx_S_Smmn_StmAtnh.tga", 60, "This effect summons a storm monarch from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2100, "T_Nor_Cnj_SummonIceWraith", "Summon Ice Wraith", "T_Sky_Cre_IceWr_01", 35, 104, "s\\Tx_S_Smmn_FrstAtrnh.tga", 60, "This effect summons an ice wraith from the Outer Realms. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to the Outer Realms.  If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2101, "T_Dwe_Cnj_Uni_SummonDweSpectre", "Summon Dwemer Spectre", "dwarven ghost", 17, 52, "s\\Tx_S_Smmn_AnctlGht.tga", 60, "This effect summons a dwemer spectre from the Outer Realms. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to the Outer Realms.  If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2102, "T_Dwe_Cnj_Uni_SummonSteamCent", "Summon Dwemer Steam Centurion", "centurion_steam", 29, 88, "s\\Tx_S_Smmn_Fabrict.dds", 60, "This effect summons an steam centurion from the Outer Realms. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to the Outer Realms.  If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2103, "T_Dwe_Cnj_Uni_SummonSpiderCent", "Summon Dwemer Spider Centurion", "centurion_spider", 15, 46, "s\\Tx_S_Smmn_Fabrict.dds", "This effect summons a centurion spider from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2104, "T_Ayl_Cnj_SummonWelkyndSpirit", "Summon Welkynd Spirit", "T_Ayl_Cre_WelkSpr_01", 29, 78, "s\\Tx_S_Smmn_AnctlGht.tga", 60, "This effect summons a welkynd spirit from the Outer Realms. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to the Outer Realms.  If summoned in town, the guards will attack you and the summoning on sight."},
	{ 2105, "T_Com_Cnj_SummonAuroran", "Summon Auroran", "T_Dae_Cre_Auroran_01", 50, 130, "s\\Tx_S_Smmn_AnctlGht.tga", 60, "This effect summons an auroran from Oblivion. It appears six feet in front of the caster and attacks any entity that attacks the caster until the effect ends or the summoning is killed. At death, or when the effect ends, the summoning disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."}
}

-- unique id, spell id to override, spell name, effect mana cost, spell mana cost, icon, spell duration, effect description
local td_miscs = {	
	{ 2106, "T_Com_Mys_UNI_Passwall", "Passwall", 750, 95, "td\\s\\tr_s_tele_passwall.tga", 0, "In an indoor area, this effect permits the caster to pass through a solid barrier to a vacant space behind it.  The effect will fail if the destination beyond the traversed barrier is filled with water, or if it lies above or below the caster."}
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

event.register(tes3.event.magicEffectsResolved, function()
	if config.summoningSpells == true then
		local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

		for k, v in pairs(td_summons) do
			local effectID, spellID, spellName, creatureID, effectCost, spellCost, iconPath, duration, effectDescription = unpack(v)
			tes3.addMagicEffect{
				id = effectID,
				name = spellName,
				description = effectDescription,
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
	
	if config.miscSpells == true then
		local levitateEffect = tes3.getMagicEffect(tes3.effect.levitate)

		local effectID, spellID, spellName, effectCost, spellCost, iconPath, duration, effectDescription = unpack(td_miscs[1])
		tes3.addMagicEffect{
			id = effectID,
			name = spellName,
			description = effectDescription,
			school = tes3.magicSchool.alteration,
			baseCost = effectCost,
			speed = levitateEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = false,
			canCastTouch = true,
			casterLinked = levitateEffect.casterLinked,
			hasContinuousVFX = false,
			hasNoDuration = true,
			hasNoMagnitude = true,
			illegalDaedra = false,
			isHarmful = false,
			nonRecastable = true,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			usesNegativeLighting = levitateEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = levitateEffect.particleTexture,
			castSound = levitateEffect.castSoundEffect.id,
			castVFX = levitateEffect.castVisualEffect.id,
			boltSound = "T_SndObj_Silence",
			boltVFX = "",
			hitSound = "T_SndObj_Silence",
			hitVFX = levitateEffect.hitVisualEffect.id,		-- Currently uses the VFX from levitate because otherwise Morrowind crashes when casting the effect on some actors despite this parameter being "optional"
			areaSound = "T_SndObj_Silence",
			areaVFX = "",
			lighting = {x = levitateEffect.lightingRed, y = levitateEffect.lightingGreen, z = levitateEffect.lightingBlue},
			size = levitateEffect.size,
			sizeCap = levitateEffect.sizeCap,
			onTick = function(eventData) eventData:trigger() end,
			onCollision = nil
		}
	end
end)

---@param wallPosition tes3vector3
---@param forward tes3vector3
---@param right tes3vector3
---@param up tes3vector3
---@param effect tes3effect
local function passwallCalculate(wallPosition, forward, right, up, unitRange)
	local nodeArr = tes3.mobilePlayer.cell.pathGrid.nodes
	local playerPosition = tes3.mobilePlayer.position

	local minDistance = 108
	local forwardOffset = 0

	local rightCoord = (right * 160)
	local upCoord = (up * 100)

	local startPosition = wallPosition + (forward * forwardOffset)
	local endPosition = wallPosition + (forward * (unitRange + forwardOffset))

	local point1 = startPosition - rightCoord - upCoord
	local point2 = endPosition + rightCoord + upCoord

	local bestDistance = unitRange
	local bestPosition = nil

	for _,node in pairs(nodeArr) do
		if (point1.x <= node.position.x and node.position.x <= point2.x) or (point1.x >= node.position.x and node.position.x >= point2.x) then
			if (point1.y <= node.position.y and node.position.y <= point2.y) or (point1.y >= node.position.y and node.position.y >= point2.y) then
				if (point1.z <= node.position.z and node.position.z <= point2.z) or (point1.z >= node.position.z and node.position.z >= point2.z) then
					local distance = startPosition:distance(node.position)
					if distance <= bestDistance and playerPosition:distance(node.position) >= minDistance then
						local targetY = tes3.rayTest{
							position = node.position - (forward * 20) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
							direction = forward,
							maxDistance = 40,
							root = {tes3.game.sceneGraphCollideString},	-- Only checks collisions? Maybe? There isn't any documentation, but it is capable of hitting stuff
							useBackTriangles = true,
						}
						local targetX = tes3.rayTest{
							position = node.position - (right * 20) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
							direction = right,
							maxDistance = 40,
							root = {tes3.game.sceneGraphCollideString},
							useBackTriangles = true,
						}
						
						if not targetY and not targetX then
							bestDistance = distance
							bestPosition = node.position
						end
					end
				end
			end
		end
	end

	local checkedNodeTable = { }
	for _,node in pairs(nodeArr) do
		for _,connectedNode in pairs(node.connectedNodes) do
			if not table.contains(checkedNodeTable, node) and not table.contains(checkedNodeTable, connectedNode) then			-- Only check each connection once
				if (startPosition:distance(node.position) <= 1024 and startPosition:distance(connectedNode.position) <= 1024) or (endPosition:distance(node.position) <= 1024 and endPosition:distance(connectedNode.position) <= 1024) then	-- Reasonable limit on how far nodes can be
					local increment = (connectedNode.position - node.position) / 15
					local connectionLength = connectedNode.position:distance(node.position)
					local incrementLength = connectionLength / 15

					local prevStartDistance = nil
					local prevEndDistance = nil

					local prevInVolume = false		-- Given that raytests are used to check for collision near the tested positions, the closest acceptable position might actually be further away, so positions should keep being checked until they are outside of the volume entirely
					
					for i=1,14,1 do
						local incrementPosition = node.position + (increment * i)
						local startDistance = incrementPosition:distance(startPosition)
						local endDistance = incrementPosition:distance(endPosition)

						if prevStartDistance and prevEndDistance and not prevInVolume and (startDistance > prevStartDistance and endDistance > prevEndDistance) or ((connectionLength - (incrementLength * i)) < startDistance and (connectionLength - (incrementLength * i)) < endDistance) then
							break		-- If incrementPosition is moving away or too far from the volume that the player can teleport within and was not inside of it then the loop will be broken out of for the sake of performance
						end

						prevInVolume = false

						if startDistance <= bestDistance and playerPosition:distance(incrementPosition) >= minDistance then
							if (point1.x <= incrementPosition.x and incrementPosition.x <= point2.x) or (point1.x >= incrementPosition.x and incrementPosition.x >= point2.x) then
								if (point1.y <= incrementPosition.y and incrementPosition.y <= point2.y) or (point1.y >= incrementPosition.y and incrementPosition.y >= point2.y) then
									if (point1.z <= incrementPosition.z and incrementPosition.z <= point2.z) or (point1.z >= incrementPosition.z and incrementPosition.z >= point2.z) then
										prevInVolume = true
										
										local targetY = tes3.rayTest{
											position = incrementPosition - (forward * 20) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
											direction = forward,
											maxDistance = 40,
											root = {tes3.game.sceneGraphCollideString},
											useBackTriangles = true,
										}
										local targetX = tes3.rayTest{
											position = node.position - (right * 20) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
											direction = right,
											maxDistance = 40,
											root = {tes3.game.sceneGraphCollideString},
											useBackTriangles = true,
										}
										
										if not targetY and not targetX then
											bestDistance = startDistance
											bestPosition = incrementPosition
										end
									end
								end
							end
						end
						
						prevStartDistance = startDistance
						prevEndDistance = endDistance
					end
				end
			end
		end

		table.insert(checkedNodeTable, node)
	end

	return bestPosition
end

---@param node niNode
local function hasAlphaBlend(node)
	for _,child in pairs(node.children) do
		if child.alphaProperty then
			if (child.alphaProperty.propertyFlags % 2) ~= 0 then
				return true
			end
		end

		if child.children then
			return hasAlphaBlend(child)
		end
	end
end

---@param e magicCastedEventData
local function passwallEffect(e)
	for k,v in pairs(e.source.effects) do
		if v.id == 2106 then
			if tes3.mobilePlayer.cell.isInterior and tes3.mobilePlayer.cell.pathGrid and not tes3.mobilePlayer.underwater and not tes3.worldController.flagTeleportingDisabled then
				local castPosition = tes3.mobilePlayer.position + tes3vector3.new(0, 0, 0.7 * tes3.mobilePlayer.height)	-- Position of where spells are casted
				local forward = (tes3.worldController.armCamera.cameraData.camera.worldDirection * tes3vector3.new(1, 1, 0)):normalized()
				local right = tes3.worldController.armCamera.cameraData.camera.worldRight:normalized()
				local up = tes3vector3.new(0, 0, 1)

				local unitRange = v.radius * 22.1

				local hitSound = "alteration hit"
				local hitVFX = "VFX_AlterationHit"
				
				local checkWard = tes3.rayTest{
					position = castPosition,
					direction = forward,
					findAll = true,
					maxDistance = 128 + unitRange,
					root = niTriShape,
					ignore = {tes3.player, tes3.game.worldPickRoot},
					useModelBounds = true,
					observeAppCullFlag  = false,
				}

				if checkWard then
					for _,detection in pairs(checkWard) do
						mwse.log(detection.reference.baseObject.id)
						if string.find(detection.reference.baseObject.id, "T_PasswallWard") then	-- Prevents teleporting through T_PasswallWard statics
							return
						end
					end
				end

				local target = tes3.rayTest{
					position = castPosition,
					direction = forward,
					maxDistance = 128,
					ignore = {tes3.player},
				}

				local hitReference, wallPosition = target and target.reference, target and target.intersection
				
				if hitReference then
					if hitReference.baseObject.objectType == tes3.objectType.static then
						if hitReference.baseObject.boundingBox.max:heightDifference(hitReference.baseObject.boundingBox.min) >= 192 then		-- Check how tall the targeted object is; this is Passwall, not Passtable
							local bestPosition = passwallCalculate(wallPosition, forward, right, up, unitRange)

							if bestPosition then
								tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
								local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
								tes3.mobilePlayer.position = bestPosition
							end
						end
					elseif hitReference.baseObject.objectType == tes3.objectType.activator then
						if hitReference.baseObject.boundingBox.max:heightDifference(hitReference.baseObject.boundingBox.min) >= 192 then
							local root = target.object
							while root.parent do	-- Gets root node of the targetted mesh
								root = root.parent
							end
							
							if not hasAlphaBlend(root) then		-- Prevents passing through activators with transparency, such as forcefields
								local bestPosition = passwallCalculate(wallPosition, forward, right, up, unitRange)

								if bestPosition then
									tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
									local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
									tes3.mobilePlayer.position = bestPosition
								end
							end
						end
					elseif hitReference.baseObject.objectType == tes3.objectType.door and ((string.find(string.lower(hitReference.baseObject.name), "door") or string.find(string.lower(hitReference.baseObject.name), "wooden gate") or string.find(string.lower(hitReference.baseObject.name), "palace gates") or
							string.find(string.lower(hitReference.baseObject.name), "stone gate") or string.find(string.lower(hitReference.baseObject.name), "old iron gate")) and
							not (string.find(string.lower(hitReference.baseObject.name), "trap") or string.find(string.lower(hitReference.baseObject.name), "cell") or string.find(string.lower(hitReference.baseObject.name), "tent"))) then
						if not hitReference.destination then
							local bestPosition = passwallCalculate(wallPosition, forward, right, up, unitRange)

							if bestPosition then
								tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
								local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
								tes3.mobilePlayer.position = bestPosition
							end
						elseif hitReference.destination and hitReference.destination.cell.isInterior then
							tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
							local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
							tes3.positionCell({ cell = hitReference.destination.cell, position = hitReference.destination.marker.position, orientation = hitReference.destination.marker.orientation, teleportCompanions = false })
						else
							tes3ui.showNotifyMenu("You must remain in a confined space.")
						end
					end
				end
			else
				tes3ui.showNotifyMenu("You must be in a confined space.")
			end

			return
		end
	end
end

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

-- Setup MCM
dofile("TamrielData.mcm")

event.register(tes3.event.loaded, function()
	if config.summoningSpells == true then
		for k,v in pairs(td_summons) do
			local effectID, spellID, spellName, creatureID, effectCost, spellCost, iconPath, duration, effectDescription = unpack(v)

			local overridden_spell = tes3.getObject(spellID)
			overridden_spell.name = spellName
			overridden_spell.magickaCost = spellCost

			local effect = overridden_spell.effects[1]
			effect.id = effectID
			effect.duration = duration
		end
	end

	if config.miscSpells == true then
		for k,v in pairs(td_miscs) do
			local effectID, spellID, spellName, effectCost, spellCost, iconPath, duration = unpack(v)

			local overridden_spell = tes3.getObject(spellID)
			overridden_spell.name = spellName
			overridden_spell.magickaCost = spellCost

			local effect = overridden_spell.effects[1]
			effect.id = effectID
			effect.duration = duration
		end
	end
	
	event.unregister(tes3.event.magicCasted, passwallEffect)
	event.unregister(tes3.event.equip, restrictEquip)
	event.unregister(tes3.event.bodyPartAssigned, fixVampireHeadAssignment)
	event.unregister(tes3.event.combatStarted, vampireHeadCombatStarted)
	event.unregister(tes3.event.playItemSound, improveItemSounds)
	event.unregister(tes3.event.calcTravelPrice, adjustTravelPrices)
	event.unregister(tes3.event.magicCasted, limitInterventionMessage)
	event.unregister(tes3.event.spellTick, limitIntervention)
	
	if config.miscSpells == true then
		event.register(tes3.event.magicCasted, passwallEffect)
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
		if tes3.player.object.race.id == "T_Els_Ohmes-raht" or tes3.player.object.race.id == "T_Els_Suthay" then
			if tes3.player.object.female == false then
				tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_m.nif" })
			else
				tes3.loadAnimation({ reference = tes3.player, file = "epos_kha_upr_anim_f.nif" })
			end
		end
	end
end)