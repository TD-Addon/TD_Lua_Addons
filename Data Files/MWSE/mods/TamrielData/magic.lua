local this = {}

local common = require("TamrielData.common")
local config = require("TamrielData.config")

local passwallAlteration = config.passwallAlteration	-- Magic effects are resolved when the game begins, but just checking config.passwallAlteration would cause the hit sound and VFX to change even if the game is not restarted
local passwallIcon = "td\\s\\td_s_passwall.tga"
if passwallAlteration then
	passwallIcon = "td\\s\\td_s_passwall_alt.tga"
end

local northMarkerCos = 0
local northMarkerSin = 0
local mapWidth = 0
local mapHeight = 0
local multiWidth = 0
local multiHeight = 0
local interiorMapOriginX = 0
local interiorMapOriginY = 0
local interiorMultiOriginX = 0
local interiorMultiOriginY = 0
local mapOriginGridX = 0
local mapOriginGridY = 0
local multiOriginGridX = 0
local multiOriginGridY = 0

local corruptionActorID = "T_Glb_Cre_Gremlin_01"	-- A funny default, just in case
local corruptionTargetReference = nil
local corruptionCasted = false

local blinkIndicator
local blinkGround

local mouseOverInventory = true
local mouseOverContainer = false

if config.summoningSpells then
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
	tes3.claimSpellEffectId("T_summon_IceWraith", 2100)
	tes3.claimSpellEffectId("T_summon_DweSpectre", 2101)
	tes3.claimSpellEffectId("T_summon_SteamCent", 2102)
	tes3.claimSpellEffectId("T_summon_SpiderCent", 2103)
	tes3.claimSpellEffectId("T_summon_WelkyndSpirit", 2104)
	tes3.claimSpellEffectId("T_summon_Auroran", 2105)
	tes3.claimSpellEffectId("T_summon_Herne", 2107)
	tes3.claimSpellEffectId("T_summon_Morphoid", 2108)
	tes3.claimSpellEffectId("T_summon_Draugr", 2109)
	tes3.claimSpellEffectId("T_summon_Spriggan", 2110)
	tes3.claimSpellEffectId("T_summon_BoneldGr", 2117)
	tes3.claimSpellEffectId("T_summon_Ghost", 2126)
	tes3.claimSpellEffectId("T_summon_Wraith", 2127)
	tes3.claimSpellEffectId("T_summon_Barrowguard", 2128)
	tes3.claimSpellEffectId("T_summon_MinoBarrowguard", 2129)
	tes3.claimSpellEffectId("T_summon_SkeletonChampion", 2130)
	tes3.claimSpellEffectId("T_summon_AtroFrostMon", 2131)
	tes3.claimSpellEffectId("T_summon_SpiderDaedra", 2146)
end

if config.boundSpells then
	tes3.claimSpellEffectId("T_bound_Greaves", 2111)
	tes3.claimSpellEffectId("T_bound_Waraxe", 2112)
	tes3.claimSpellEffectId("T_bound_Warhammer", 2113)
	tes3.claimSpellEffectId("T_bound_HammerResdayn", 2114)
	tes3.claimSpellEffectId("T_bound_RazorResdayn", 2115)
	tes3.claimSpellEffectId("T_bound_Pauldrons", 2116)
	tes3.claimSpellEffectId("T_bound_ThrowingKnives", 2118)
	tes3.claimSpellEffectId("T_bound_Greatsword", 2145)
end

if config.interventionSpells then
	tes3.claimSpellEffectId("T_intervention_Kyne", 2122)
end

if config.miscSpells then
	tes3.claimSpellEffectId("T_mysticism_Passwall", 2106)
	tes3.claimSpellEffectId("T_mysticism_BanishDae", 2119)
	tes3.claimSpellEffectId("T_mysticism_ReflectDmg", 2120)
	tes3.claimSpellEffectId("T_mysticism_DetHuman", 2121)
	tes3.claimSpellEffectId("T_alteration_RadShield", 2123)
	tes3.claimSpellEffectId("T_alteration_Wabbajack", 2124)
	tes3.claimSpellEffectId("T_mysticism_Insight", 2125)
	tes3.claimSpellEffectId("T_restoration_ArmorResartus", 2132)
	tes3.claimSpellEffectId("T_restoration_WeaponResartus", 2133)
	tes3.claimSpellEffectId("T_conjuration_Corruption", 2134)
	tes3.claimSpellEffectId("T_conjuration_CorruptionSummon", 2135)
	tes3.claimSpellEffectId("T_illusion_DistractCreature", 2136)
	tes3.claimSpellEffectId("T_illusion_DistractHumanoid", 2137)
	tes3.claimSpellEffectId("T_destruction_GazeOfVeloth", 2138)
	tes3.claimSpellEffectId("T_mysticism_DetEnemy", 2139)
	tes3.claimSpellEffectId("T_alteration_WabbajackHelper", 2140)
	tes3.claimSpellEffectId("T_mysticism_DetInvisibility", 2141)
	tes3.claimSpellEffectId("T_mysticism_Blink", 2142)
	tes3.claimSpellEffectId("T_restoration_FortifyCasting", 2143)
	tes3.claimSpellEffectId("T_illusion_PrismaticLight", 2144)
	tes3.claimSpellEffectId("T_mysticism_BloodMagic", 2147)
	tes3.claimSpellEffectId("T_conjuration_SanguineRose", 2148)
	tes3.claimSpellEffectId("T_mysticism_DetValuables", 2149)
	tes3.claimSpellEffectId("T_mysticism_MagickaWard", 2150)
	tes3.claimSpellEffectId("T_illusion_Ethereal", 2151)
end

local magicData = require("TamrielData.magicdata")

local prismaticReferences = {}

local distractedReferences = {}	-- Should probably decide on a consistent naming scheme for tables

local invisibleReferences = {}

local etherealReferences = {}

-- (part of) lowercase static/activator id
local passWallObjectBlacklist = {
	"shelf",
	"bed",
	"bar_door",
	"bardoor",
	"ladder",
	"wallscreen",
	"t_ayl_dngruin_ceilingspike",
	"t_ayl_dngruin_guillotine",
	"trapdoor",
	"t_com_var_metalrod",
	"t_dreu_furn_cagerod_01",
	"active_mh_forcefield",
}

-- (part of) lowercase door id
local passWallDoorBlacklist = {
	"trap",
	"trp",
	"ladder",
	"hatch",
	"ex_emp_tower_01_b",
	"ex_r_pcfort_d_02",
	"t_de_setred_door",
	"velothi_sewer_door",
	"jaildoor",
	"t_imp_setnord_doorcellar",
	"t_nor_set_doorcellar",
	"t_imp_setkva_cellardoor",
	"t_de_setind_doorjailin",
	"t_nor_setbarbarian_door",
	"t_de_set_i_tent_01_door",
	"t_de_set_x_tent_01_door",
	"t_de_set_i_tent_02_door",
	"t_de_set_x_tent_02_door",
	"t_orc_setnomad_door",
	"t_rga_setnomadrl_x_door",
	"t_com_setcir_door",
	"grate",
	"fence",
	"door_cavern_doors",
	"ex_de_sn_gate",
	"ex_s_fence_gate",
	"t_bre_dngcrypt_gate",
	"t_com_var_gatemystica",
	"t_de_setind_doorgate",
	"t_de_setind_gatefloodalm",
	"t_he_dngdirenni_door",
	"t_imp_legion_gatebig_02",
	"t_imp_legion_gatesmall_02",
	"t_imp_legionmw_gatestrong_01",
	"t_imp_setgravey_doorex",
	"t_nor_setpalisade_gate",
	"bm_karstcav_door",
	"bm_kartaag_door",
	"bm_ka_door_dark",
	"door_load_darkness00",
	"t_glb_blackdoor",
	"t_cyr_cavegc_doorin_01",
	"t_sky_cave_doornat",
	"t_sky_cave_door_",
	"cave_doorin_",
	"t_pi_cave_doorin_01",
	"t_de_dngship_doordarkhole_01",
}

-- race id, skeleton base body part id, skeleton "clothing" body part id
local raceSkeletonBodyParts = {
	{ "Argonian", "T_B_GazeVeloth_SkeletonArg_01", "T_C_GazeVeloth_SkeletonArg_01" },	-- Use the other Argonian skeletons too depending on the hair mesh of the target?
	{ "Breton", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "Dark Elf", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "High Elf", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "Imperial", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "Khajiit", "T_B_GazeVeloth_SkeletonKha_01", "T_C_GazeVeloth_SkeletonKha_01" },
	{ "Nord", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "Orc", "T_B_GazeVeloth_SkeletonOrc_01", "T_C_GazeVeloth_SkeletonOrc_01" },
	{ "Redguard", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "Wood Elf", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Cnq_ChimeriQuey", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Cnq_Keptu", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Els_Cathay", "T_B_GazeVeloth_SkeletonKha_02", "T_C_GazeVeloth_SkeletonKha_02" },
	{ "T_Els_Cathay-raht", "T_B_GazeVeloth_SkeletonKha_01", "T_C_GazeVeloth_SkeletonKha_01" },
	{ "T_Els_Dagi-raht", "T_B_GazeVeloth_SkeletonKha_01", "T_C_GazeVeloth_SkeletonKha_01" },
	{ "T_Els_Ohmes", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Els_Ohmes-raht", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Els_Suthay", "T_B_GazeVeloth_SkeletonKha_02", "T_C_GazeVeloth_SkeletonKha_02" },
	{ "T_Els_Tojay", "T_B_GazeVeloth_SkeletonKha_02", "T_C_GazeVeloth_SkeletonKha_02" },
	{ "T_Hr_Riverfolk", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Mw_Malahk_Orc", "T_B_GazeVeloth_SkeletonOrc_01", "T_C_GazeVeloth_SkeletonOrc_01" },
	{ "T_Pya_SeaElf", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Sky_Hill_Giant", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },		-- Giants should eventually get their own skeleton mesh though
	{ "T_Sky_Reachman", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },
	{ "T_Yne_Ynesai", "T_B_GazeVeloth_Skeleton_01", "T_C_GazeVeloth_Skeleton_01" },		-- Imga and Tsaesci skeletons will take more effort
}

local wabbajackCreatures = {
	"T_Mw_UNI_GrahlWabbajack",	-- This version of the Grahl does not have fireregenScript attached to it; I saw a crash occur while it was being executed, but I am not sure why.
	"scamp",
	"T_Glb_Cre_LandDreu_01",
	"T_Glb_Cre_TrollCave_03",
	"mudcrab",
	"T_Ham_Fau_Goat_01",
	"Rat",
	"golden saint"
}

-- actor id
local gazeOfVelothImmuneActors = {
	["vivec_god"] = true,
	["almalexia"] = true,
	["Almalexia_warrior"] = true,
	["divayth fyr"] = true,
	["wulf"] = true,
	["Sky_qRe_KWMG6_Azra"] = true,
}

-- script id
local safeScripts = {
	["nolore"] = true,
	["slaveScript"] = true,
	["fortloreboozeScript"] = true,
	["TR_m3_Kha_Methats_sc"] = true,
	["TR_m3_NPC_OE_commonNoLore"] = true,
	["TR_m3_NPC_OE_poorNoLore"] = true,
	["TR_m3_NPC_OE_richNoLore"] = true,
	["TR_m3_NPC_OE_towerNoLore"] = true,
	["TR_m4_AA_Vf_NPC_NoLoresc"] = true,
	["TR_m7_NPC_RuddyEggsNoLore"] = true,
	["TR_m7_Ns_KhanVolnyr_sc"] = true,
	["TR_m3_q_kharg"] = true,
	["TR_m3_Kha_AtroLordDis_sc"] = true,
	["TR_m3_Kha_Black_Heart_Script"] = true,
	["TR_m3_Kha_ClannLordDis_sc"] = true,
	["TR_m3_Kha_FireScamp_sc"] = true,
	["TR_m1_Lornie_Slave_scpt"] = true,
	["TR_m4_OranSlave_Sc"] = true,
	["TR_m1_T_CouncilorSc"] = true,
	["TR_m2_T_CouncilorSc"] = true,
	["TR_NecMQ_MovingNPCScript"] = true,
	["TR_m1_FW_TG3_HrongalDrink"] = true,
	["TR_m1_MinTalScript"] = true,
	["TR_m1_NPC_DiceGambler"] = true,
	["TR_m2_NPC_DiceGambler"] = true,
	["TR_m3_NPC_DiceGambler"] = true,
	["TR_m3_NPC_DiceGamblerNoLore"] = true,
	["TR_m3_NPC_DiceGamblerOECom"] = true,
	["TR_m3_NPC_DiceGamblerOEPoor"] = true,
	["TR_m4_NPC_DiceGambler"] = true,
	["TR_m5_NPC_DiceGambler"] = true,
	["TR_m6_NPC_DiceGambler"] = true,
	["TR_m7_NPC_DiceGambler"] = true,
	["TR_m1_NPC_Fervas_Shulisa"] = true,
	["TR_m1_NPC_Gilen_Indothan"] = true,
	["TR_m1_NPC_Malvas_Relvani"] = true,
	["TR_m1_T_Seducer"] = true,
	["TR_m3_q_vampambush"] = true,
}

---@param table table
function this.replaceSpells(table)
	for _,v in pairs(table) do
		local overridden_spell = tes3.getObject(v[1])
		if overridden_spell then
			overridden_spell.castType = tes3.spellType[v[2]]
			if v[3] then overridden_spell.name = common.i18n("magic." .. v[3]) end
			if v[4] then overridden_spell.magickaCost = v[4] end
			for i = 1, 8, 1 do
				local effect_row = v[4 + i]
				if not effect_row then
					break	-- This condition exists so that the tables don't have to have dozens of fields if they have less than 8 effects
				end

				local effect = overridden_spell.effects[i]
				effect.id = tes3.effect[effect_row.id]
				effect.attribute = effect_row.attribute
				effect.skill = effect_row.skill
				effect.rangeType = tes3.effectRange[effect_row.range]
				effect.radius = effect_row.area or 0
				effect.duration = effect_row.duration or 0
				effect.min = effect_row.min or 0
				effect.max = effect_row.max or 0
			end
		end
	end
end

---@param table table
function this.replaceEnchantments(table)
	for _,v in pairs(table) do
		local overridden_enchantment = tes3.getObject(v[1])
		---@cast overridden_enchantment tes3enchantment
		if overridden_enchantment then
			overridden_enchantment.castType = tes3.enchantmentType[v[2]]
			for i = 1, 8, 1 do
				local effect_row = v[2 + i]
				if not effect_row then
					for j = i, 8, 1 do
						local effect = overridden_enchantment.effects[i]
						effect.id = -1
						effect.attribute = -1
						effect.skill = -1
					end

					break
				end

				local effect = overridden_enchantment.effects[i]
				effect.id = tes3.effect[effect_row.id]
				effect.attribute = effect_row.attribute
				effect.skill = effect_row.skill
				effect.rangeType = tes3.effectRange[effect_row.range]
				effect.radius = effect_row.area or 0
				effect.duration = effect_row.duration or 0
				effect.min = effect_row.min or 0
				effect.max = effect_row.max or 0
			end
		end
	end
end

---@param table table
function this.replaceIngredientEffects(table)
	for _,v in pairs(table) do
		local ingredient = tes3.getObject(v[1])
		if ingredient then
			for i = 1, 4, 1 do
				local effect_row = v[1 + i]
				if effect_row then
					ingredient.effects[i] = effect_row.id
					ingredient.effectAttributeIds[i] = effect_row.attribute or -1
					ingredient.effectSkillIds[i] = effect_row.skill or -1
				end
			end
		end
	end
end

---@param table table
function this.replacePotions(table)
	for _,v in pairs(table) do
		local potion = tes3.getObject(v[1])
		if potion then
			if v[2] then potion.name = common.i18n("magic." .. v[2]) end
			for i = 1, 8, 1 do
				local effect = potion.effects[i]
				local effect_row = v[2 + i]
				if effect_row then
					effect.id = tes3.effect[effect_row.id]
					effect.duration = effect_row.duration or 0
					effect.min = effect_row.magnitude or 0
					effect.max = effect_row.magnitude or 0
				else
					effect.id = -1
					effect.duration = -1
					effect.min = -1
					effect.max = -1
				end
			end
		end
	end
end

---@param table table
function this.editItems(table)
	for _,v in pairs(table) do
		local overridden_item = tes3.getObject(v[1])
		if overridden_item then
			if v[2] then overridden_item.name = common.i18n("magic." .. v[2]) end
			if v[3] then overridden_item.value = v[3] end
		end
	end
end

---@param actor tes3mobileNPC
---@param table table< table< string, tes3.spellType, string|nil, number, tes3.effect, tes3.effectRange, number, number, number, number > >
---@return table< table< string, tes3.effect > >
local function checkActorSpells(actor, table)
	local customSpells = { }
	local customSpellIndex = 1
	for _,v in pairs(table) do
		if actor.object.spells:contains(v[1]) and actor.magicka.current > v[4] then
			customSpells[customSpellIndex] = { v[1], { tes3.effect[v[5].id] } }
			customSpellIndex = customSpellIndex + 1
		end
	end

	return customSpells
end

---@param session tes3combatSession
---@param spells table< table< string, tes3.effect > >
local function equipActorSpell(session, spells)
	for _,v in pairs(spells) do
		if #session.mobile:getActiveMagicEffects({ effect = v[2] }) == 0 then
			session.selectedAction = 6
			local spell = tes3.getObject(v[1])
			session.selectedSpell = spell
			session.mobile:equipMagic({ source = spell })
			return
		end
	end
end

---@param e determinedActionEventData
function this.useCustomSpell(e)
	local customSpells
	--if (e.session.selectedAction > 3 and e.session.selectedAction < 7) or e.session.selectedAction == 8 then	-- These conditions require that the actor is already casting a spell, which can't happen if they are unable to cast a non-MWSE spell
		if config.summoningSpells then
			customSpells = checkActorSpells(e.session.mobile, magicData.td_summon_spells)

			if customSpells then
				equipActorSpell(e.session, customSpells)
				return
			end
		end

		if config.boundSpells then
			customSpells = checkActorSpells(e.session.mobile, magicData.td_bound_spells)

			if customSpells then
				equipActorSpell(e.session, customSpells)
				return
			end
		end
	--end
end

---@param sourceInstance tes3magicSourceInstance
local function restoreCharge(sourceInstance)
	sourceInstance.itemData.charge = sourceInstance.itemData.charge + tes3.calculateChargeUse({ mobile = sourceInstance.caster.mobile, enchantment = sourceInstance.item.enchantment })
	if sourceInstance.itemData.charge > sourceInstance.item.enchantment.maxCharge then sourceInstance.itemData.charge = sourceInstance.item.enchantment.maxCharge end
end

---@param inventory tes3itemStack[]
local function hasScriptedItem(inventory)
	for _,itemStack in pairs(inventory) do
		if itemStack.object.script then return true end
	end
end

-- MWSE still does not have proper support for custom effect tooltips, so this function accounts for one of the several cases where they do not work.
---@param e uiSpellTooltipEventData
function this.correctSpellTooltipUnit(e)
	for index,effect in ipairs(e.spell.effects) do
		if effect.id >= 2106 and effect.id <= 2200 then		-- Safe range for TD misc effects. Might need to be adjusted in the future.
			local unit
			local pointUnit

			if effect.id == tes3.effect.T_mysticism_DetHuman or effect.id == tes3.effect.T_mysticism_DetEnemy or effect.id == tes3.effect.T_mysticism_DetInvisibility or effect.id == tes3.effect.T_mysticism_DetValuables or effect.id == tes3.effect.T_mysticism_Blink then
				unit = " " .. tes3.findGMST(tes3.gmst.sfeet).value .. " "
			elseif effect.id == tes3.effect.T_mysticism_ReflectDmg then
				unit = tes3.findGMST(tes3.gmst.spercent).value .. "% "		-- tes3.findGMST(tes3.gmst.spercent).value alone doesn't work. "% " doesn't work either, but for some reason the two together actually make % appear.
			end

			if unit then
				if effect.max == 1 then
					pointUnit = " pt "
				else
					pointUnit = " pts "
				end

				if e.spell.castType == tes3.spellType.spell then
					e.tooltip.children[1].children[2].children[index + 1].children[2].children[1].text = e.tooltip.children[1].children[2].children[index + 1].children[2].children[1].text:gsub(pointUnit, unit, 1)
				elseif e.spell.castType == tes3.spellType.power then
					e.tooltip.children[1].children[2].children[index].children[2].children[1].text = e.tooltip.children[1].children[2].children[index].children[2].children[1].text:gsub(pointUnit, unit, 1)
				end
			end
		end
	end
end


---@param e uiPreEventEventData
local function modifyCastingChanceMultiFillbar(e)
	local multiMenu = e.source
	if not multiMenu then
		return
	end

	local fortifyCastingEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_restoration_FortifyCasting })
	local bloodMagicEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_BloodMagic })
	if #fortifyCastingEffects > 0 or #bloodMagicEffects > 0 then
		local magicLayout = multiMenu:findChild("MenuMulti_bottom_row_left"):findChild("MenuMulti_icons"):findChild("MenuMulti_magic_layout")
		if not magicLayout then
			return
		end

		local colorBar = magicLayout:findChild("PartFillbar_colorbar_ptr")
		local magicIcon = magicLayout:findChild("MenuMulti_magic_icon")
		if not colorBar or not magicIcon then
			return
		end

		local fortifyMagnitude = 0
		if #fortifyCastingEffects > 0 then
			for _,v in pairs(fortifyCastingEffects) do
				fortifyMagnitude = fortifyMagnitude + v.magnitude
			end
		end

		local hasBloodMagic = false
		if #bloodMagicEffects > 0 then hasBloodMagic = true end

		local spell = magicIcon:getPropertyObject("MagicMenu_Spell")
		if not spell then return end
		---@cast spell tes3spell
		local castChance

		if (not hasBloodMagic and spell.magickaCost > tes3.mobilePlayer.magicka.current) or (hasBloodMagic and spell.magickaCost / 2 > tes3.mobilePlayer.magicka.current) then
			castChance = 0
		else
			castChance = spell:calculateCastChance({ caster = tes3.player, checkMagicka = false })
			castChance = castChance + fortifyMagnitude
		end

		local width = math.clamp(castChance / 100, .001, 1)
		colorBar.widthProportional = width
	end
end

---@param e uiActivatedEventData
function this.onMenuMultiActivated(e)
	e.element:registerAfter(tes3.uiEvent.preUpdate, modifyCastingChanceMultiFillbar)
end

---@param e uiPreEventEventData
local function modifyCastingChanceSpellmakingMenu(e)
	local spellmakingMenu = e.source
	if not spellmakingMenu then return end

	local fortifyCastingEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_restoration_FortifyCasting })	-- The spellmaking menu does not consider the player's current magicka, so only Fortify Casting is involved here
	if #fortifyCastingEffects > 0 then
		local magnitude = 0
		for _,v in pairs(fortifyCastingEffects) do
			magnitude = magnitude + v.magnitude
		end

		local spellChance = spellmakingMenu:findChild("MenuSpellmaking_SpellChance")
		if not spellChance then return end
		if not spellChance.text then return end

		local effectProperty = spellChance:getPropertyFloat("MenuSpellmaking_Effect")

		if effectProperty == 0 or effectProperty == 99999 then return end -- This is true if no effects have been added or if all of the previously selected effects have been removed, both of which should give a spellChance of 0

		if effectProperty > 0 then		-- effectProperty appears to have 0.7 added to it when positive and 0.3 subtracted from it when negative, hence the condition and calculations here
			spellChance.text = math.round(effectProperty - 0.7) + magnitude
		else
			spellChance.text = math.round(effectProperty + 0.3) + magnitude
		end
	end
end

---@param e uiActivatedEventData
function this.onMenuSpellmakingActivated(e)
	e.element:registerAfter(tes3.uiEvent.preUpdate, modifyCastingChanceSpellmakingMenu)
end

---@param e uiPreEventEventData
local function modifyCastingChanceMenuPercents(e)
	local magicMenu = e.source
	if not magicMenu then return end

	local spellLayout = magicMenu:findChild("MagicMenu_spell_layout")
	if not spellLayout then return end

	local spellPercents = spellLayout:findChild("MagicMenu_spell_percents")
	if not spellPercents then return end

	local fortifyCastingEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_restoration_FortifyCasting })
	local bloodMagicEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_BloodMagic })
	if #fortifyCastingEffects > 0 or #bloodMagicEffects > 0 then
		local fortifyMagnitude = 0
		if #fortifyCastingEffects > 0 then
			for _,v in pairs(fortifyCastingEffects) do
				fortifyMagnitude = fortifyMagnitude + v.magnitude
			end
		end

		local hasBloodMagic = false
		if #bloodMagicEffects > 0 then hasBloodMagic = true end

		for _,percent in ipairs(spellPercents.children) do
			if percent.text ~= "/100" then
				local spell = percent:getPropertyObject("MagicMenu_Spell")
				---@cast spell tes3spell
				local castChance

				if (not hasBloodMagic and spell.magickaCost > tes3.mobilePlayer.magicka.current) or (hasBloodMagic and spell.magickaCost / 2 > tes3.mobilePlayer.magicka.current) then
					castChance = 0
				else
					castChance = spell:calculateCastChance({ caster = tes3.player, checkMagicka = false })
					castChance = castChance + fortifyMagnitude
				end

				if castChance > 0.5 then
					castChance = math.round(castChance)

					if castChance >= 100 then
						percent.text = "/100"
						percent.autoWidth = true
						--percent.width = 28
					else
						percent.text = "/" .. castChance
						percent.autoWidth = true
					end
				end
			end
		end
	end
end

---@param e uiActivatedEventData
function this.onMenuMagicActivated(e)
	e.element:registerAfter(tes3.uiEvent.preUpdate, modifyCastingChanceMenuPercents)
end

---@param e equipEventData
function this.etherealEquipPotion(e)
	if e.item.objectType == tes3.objectType.alchemy and #e.reference.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then return false end
end

---@param e playItemSoundEventData
function this.etherealDropSound(e)
	if e.state == tes3.itemSoundState.down and #tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then return false end
end

---@param e itemDroppedEventData
function this.etherealItemDropped(e)
	if #tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		tes3.addItem({ item = e.reference.baseObject.id, reference = tes3.player, count = e.reference.stackSize, playSound = false })
		e.reference:disable()
		return false
	end
end

---@param e activateEventData
function this.etherealActivate(e)
	if e.activator.mobile and e.activator.mobile.getActiveMagicEffects and #e.activator.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 and not (e.target.mobile and not (e.target.baseObject.objectType == tes3.objectType.npc and e.activator.mobile.isSneaking)) then return false end	-- The player should still be able to talk, but not pickpocket
end

-- Cast once enchantments cannot be accounted for infuriatingly
---@param e enchantChargeUseEventData
function this.etherealEnchantChargeUse(e)
	if e.isCast and #e.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		e.charge = 1000000
		return false
	end
end

---@param e spellCastEventData
function this.etherealSpellCast(e)
	if #e.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 and not e.source:hasEffect(tes3.effect.T_illusion_Ethereal) then
		e.castChance = 0
		return false
	end
end

---@param e spellMagickaUseEventData
function this.etherealspellMagickaUse(e)
	if #e.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		e.cost = 0
		return false
	end
end

---@param e magicReflectEventData
function this.etherealMagicReflect(e)
	if #e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		e.reflectChance = 0
		return false
	end
end

---@param e absorbedMagicEventData
function this.etherealAbsorbedMagic(e)
	if #e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		e.absorb = 0
		return false
	end
end

---@param e spellResistEventData
function this.etherealSpellResist(e)
	if #e.target.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 and e.caster ~= e.target then	-- Making the player resist all of their own effects is weird in general, but somehow prevents ever applying the ethereal effect as well 
		e.resistedPercent = 100
		return false
	end
end

---@param e damageEventData
function this.etherealDamage(e)
	if (e.attacker and #e.attacker:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0) or #e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) > 0 then
		timer.delayOneFrame(function() e.mobile:hitStun({ cancel = true })	end)	-- The hit stun is only applied on the next frame
		return false
	end
end

-- Ideally recalculating the opacity wouldn't be needed for ethereal, but the inability to prevent scroll usage means that it should be done
---@param e simulateEventData
function this.etherealOpacity(e)
	for actor in pairs(etherealReferences) do
		local chameleonEffects = actor.mobile:getActiveMagicEffects({ effect = tes3.effect.chameleon })
		local chameleonMagnitude = 0
		if #chameleonEffects > 0 then
			for _,v in pairs(chameleonEffects) do
				chameleonMagnitude = chameleonMagnitude + v.magnitude
			end

			if chameleonMagnitude > 100 then chameleonMagnitude = 100 end
		end

		local invisibilityEffects = actor.mobile:getActiveMagicEffects({ effect = tes3.effect.invisibility })
		local invisibilityMagnitude = 0
		if #invisibilityEffects > 0 then
			invisibilityMagnitude = 1
		end

		actor.mobile.animationController.opacity = math.clamp(math.clamp(.7 - .75 * chameleonMagnitude, .25, 1) * (1 - invisibilityMagnitude), 0, 0.99999)	-- This doesn't currently take Detect Invisibility into account, though it shouldn't ever need to (and vice versa)
	end
end

---@param e tes3magicEffectTickEventData
local function etherealEffect(e)
	if (not e:trigger()) then
		return
	end

	if e.effectInstance.state < tes3.spellState.ending then
		e.sourceInstance.caster.mobile.mobToMobCollision = false
		e.sourceInstance.caster.mobile.chameleon = e.sourceInstance.caster.mobile.chameleon + 30
		etherealReferences[e.sourceInstance.caster] = true
	else
		e.sourceInstance.caster.mobile.mobToMobCollision = true
		e.sourceInstance.caster.mobile.chameleon = e.sourceInstance.caster.mobile.chameleon - 30
		etherealReferences[e.sourceInstance.caster] = nil

		local chameleonEffects = e.sourceInstance.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.chameleon })
		local chameleonMagnitude = 0
		if #chameleonEffects > 0 then
			for _,v in pairs(chameleonEffects) do
				chameleonMagnitude = chameleonMagnitude + v.magnitude
			end

			if chameleonMagnitude > 100 then chameleonMagnitude = 100 end

			chameleonMagnitude = chameleonMagnitude / 100
		end

		local invisibilityEffects = e.sourceInstance.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.invisibility })
		local invisibilityMagnitude = 0
		if #invisibilityEffects > 0 then
			invisibilityMagnitude = 1
		end
		e.sourceInstance.caster.mobile.animationController.opacity = math.clamp(math.clamp(1 - .75 * chameleonMagnitude, .25, 1) * (1 - invisibilityMagnitude), 0, 0.99999)	-- A value of 1 is naturally not supported by the engine, so it is set to 0.99999 until MWSE's developers fix that bug
	end
end

---@param e itemTileUpdatedEventData
function this.boundKnivesTileUpdate(e)
	if e.item.id == "T_Com_Bound_ThrowingKnife_01" then
		if e.menu.name == "MenuBarter" then
			e.element:register("mouseClick", function(event)		-- Handles the extremely unlikely case of trying to buy a bound item
				tes3.messageBox(tes3.findGMST(tes3.gmst.sBarterDialog10).value)
			end)
		else
			if tes3ui.findMenu("MenuBarter") then
				e.element:register("mouseClick", function(event)	-- Handles the much more plausible cause of trying to sell a bound item
					tes3.messageBox(tes3.findGMST(tes3.gmst.sBarterDialog9).value)
				end)
			else
				e.menu:registerBefore(tes3.uiEvent.mouseOver, function (event) mouseOverInventory = true end)
				e.menu:registerBefore(tes3.uiEvent.mouseLeave, function (event) mouseOverInventory = false end)
				if tes3ui.findMenu("MenuContainer") then
					tes3ui.findMenu("MenuContainer"):registerBefore(tes3.uiEvent.mouseOver, function (event) mouseOverContainer = true end)		-- These should really look at the actual inventory space of the MenuContainer, not the whole menu
					tes3ui.findMenu("MenuContainer"):registerBefore(tes3.uiEvent.mouseLeave, function (event) mouseOverContainer = false end)
				end

				e.element:registerBefore("mouseDown", function(event)
					if mouseOverInventory then	-- This condition should be expanded to check for other parts of the player's UI once MWSE actually has a way to regsiter events to the second click
						return true				-- Proceed as normal
					elseif mouseOverContainer then
						tes3.messageBox(tes3.findGMST(tes3.gmst.sContentsMessage1).value)	-- Handles the player trying to put a bound item in a container
						return false
					else
						tes3.messageBox(tes3.findGMST(tes3.gmst.sBarterDialog12).value)		-- Handles the player trying to drop a bound item
						return false
					end
				end, {priority = 1000})

				--if include("UI Expansion.common") and include("UI Expansion.common").config.components and tes3.worldController.inputController:isAltDown() then???
			end
		end
	end
end

---@param e playItemSoundEventData
function this.boundKnivesDropSound(e)
	if e.state == tes3.itemSoundState.down and e.item.id == "T_Com_Bound_ThrowingKnife_01" then return false end
end

---@param e itemDroppedEventData
function this.boundKnivesItemDropped(e)
	if e.reference.baseObject.id == "T_Com_Bound_ThrowingKnife_01" then
		tes3.addItem({ item = e.reference.baseObject.id, reference = tes3.player, count = e.reference.stackSize, playSound = false })
		tes3.messageBox(tes3.findGMST(tes3.gmst.sBarterDialog12).value)
		e.reference:disable()
		return false
	end
end

---@param e tes3magicEffectTickEventData
local function boundKnivesEffect(e)
	if (not e:trigger()) then
		return
	end

	if e.effectInstance.state < tes3.spellState.ending then
		tes3.addItem({ item = "T_Com_Bound_ThrowingKnife_01", count = 60 - tes3.getItemCount({ item = "T_Com_Bound_ThrowingKnife_01", reference = e.sourceInstance.caster }), reference = e.sourceInstance.caster })
		e.sourceInstance.caster.mobile:equip({ item = "T_Com_Bound_ThrowingKnife_01" })
	else
		tes3.removeItem({ item = "T_Com_Bound_ThrowingKnife_01", reference = e.effectInstance.target, count = 999, playSound = false })
	end
end

---@param e damageEventData
function this.magickaWardEffect(e)
	if e.damage > 0 then
		local magickaWardEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_MagickaWard })
		if #magickaWardEffects > 0 then
			local difficultyTerm = 0	-- Annoyingly MWSE's damage-related events do not make the actual damage available in the event data
			if tes3.worldController.difficulty < 0 then
				difficultyTerm = tes3.worldController.difficulty / tes3.findGMST(tes3.gmst.fDifficultyMult).value
			else
				difficultyTerm = tes3.worldController.difficulty * tes3.findGMST(tes3.gmst.fDifficultyMult).value
			end

			local trueDamage = e.damage * (1 + difficultyTerm)
			local magickaDamage = trueDamage * 0.5

			if e.mobile.magicka.current >= magickaDamage then
				e.damage = (trueDamage - magickaDamage) / (1 + difficultyTerm)
				e.mobile.magicka.current = e.mobile.magicka.current - magickaDamage
			elseif e.mobile.magicka.current > 0 then
				e.damage = (trueDamage - e.mobile.magicka.current) / (1 + difficultyTerm)
				e.mobile.magicka.current = 0
			end
		end
	end
end

---@param e spellMagickaUseEventData
function this.bloodMagicCast(e)
	local bloodMagicEffects = e.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_BloodMagic })
	if #bloodMagicEffects > 0 then
		e.cost = e.cost / 2
		e.caster.mobile:applyDamage({ damage = e.cost, applyArmor = false, playerAttack = false })
	end
end

function this.prismaticLightTick()
	for ref in pairs(prismaticReferences) do
		---@cast ref tes3reference
		local lightNode = ref:getAttachedDynamicLight()
		lightNode.light.diffuse = common.hsvToRGB(ref.data.tamrielData.prismaticLightHue, .3, 1)

		ref.data.tamrielData.prismaticLightHue = ref.data.tamrielData.prismaticLightHue + 1
		if ref.data.tamrielData.prismaticLightHue > 359 then ref.data.tamrielData.prismaticLightHue = 0 end
	end
end

---@param e referenceActivatedEventData
function this.onPrismaticLightReferenceActivated(e)
	if e.reference.mobile then
		local prismaticLightEffects = e.reference.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_PrismaticLight })

		if #prismaticLightEffects > 0 then	-- Just replace this with a check for prismaticLightHue?
			prismaticReferences[e.reference] = true
		end
	end
end

---@param e referenceActivatedEventData
function this.onPrismaticLightReferenceDeactivated(e)
	prismaticReferences[e.reference] = nil
end

---@param e tes3magicEffectTickEventData
local function prismaticLightEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target
	local prismaticLightEffects = target.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_PrismaticLight })

	if e.effectInstance.state < tes3.spellState.ending then
		prismaticReferences[target] = true

		local lightNode = target:getOrCreateAttachedDynamicLight()

		if lightNode.light.name == "prismaticLightAttachment" then		-- True if an instance of prismatic light is being applied to an actor that already has one or more
			local totalMagnitude = 0

			for _,v in pairs(prismaticLightEffects) do
				totalMagnitude = totalMagnitude + v.effectInstance.effectiveMagnitude
			end

			lightNode.light:setRadius(totalMagnitude * 22.1)
		else
			lightNode.light.name = "prismaticLightAttachment"
			target.data.tamrielData = target.data.tamrielData or {}
			target.data.tamrielData.prismaticLightHue = math.random(0, 359)
			lightNode.light.diffuse = common.hsvToRGB(target.data.tamrielData.prismaticLightHue, .3, 1)
			lightNode.light:setRadius(e.effectInstance.effectiveMagnitude * 22.1)
			lightNode.light.translation = lightNode.light.translation + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height)
		end
	else
		prismaticReferences[target] = nil

		local lightNode = target:getOrCreateAttachedDynamicLight()

		if lightNode.light.name == "prismaticLightAttachment" then	-- If this is not true, then some other MWSE addon has replaced the light and it should not be removed here
			if #prismaticLightEffects > 1 then	-- 1 is checked rather than 0 because the effect being removed will still be counted here
				local totalMagnitude = 0

				for _,v in pairs(prismaticLightEffects) do
					totalMagnitude = totalMagnitude + v.effectInstance.effectiveMagnitude
				end

				totalMagnitude = totalMagnitude - e.effectInstance.effectiveMagnitude	-- The radius is rounded to the nearest whole number, so doing these calculations ensures that it will be correct afterwards

				lightNode.light:setRadius(totalMagnitude * 22.1)
			else
				target.data.tamrielData.prismaticLightHue = nil
				target:deleteDynamicLightAttachment(true)
			end
		end
	end
end

---@param e spellCastEventData
function this.fortifyCastingOnSpellCast(e)
	local fortifyCastingEffects = e.caster.mobile:getActiveMagicEffects({ effect = tes3.effect.T_restoration_FortifyCasting })
	if #fortifyCastingEffects > 0 then
		local magnitude = 0
		for _,v in pairs(fortifyCastingEffects) do
			magnitude = magnitude + v.magnitude
		end

		e.castChance = e.castChance + magnitude
	end
end

function this.blinkIndicator()
	-- The indicator either needs to be hidden because the player is no longer ready to cast Blink or so that the raytests don't hit it
	if not blinkIndicator.appCulled then
		blinkIndicator.appCulled = true
		tes3.worldController.vfxManager.worldVFXRoot:detachChild(blinkIndicator)
		blinkGround.appCulled = true
		tes3.worldController.vfxManager.worldVFXRoot:detachChild(blinkGround)
	end

	if not tes3.worldController.flagTeleportingDisabled and tes3.mobilePlayer.castReady and tes3.mobilePlayer.currentSpell and not tes3.mobilePlayer.isKnockedDown and not tes3.mobilePlayer.isKnockedOut then
		for _,effect in ipairs(tes3.mobilePlayer.currentSpell.effects) do
			-- The calculations below mostly match those of Blink itself
			if effect.id == tes3.effect.T_mysticism_Blink then
				local range = effect.max * 22.1

				local obstacles = tes3.rayTest{
					position = tes3.getPlayerEyePosition(),
					direction = tes3.getPlayerEyeVector(),
					maxDistance = range,
					findAll = true,
					accurateSkinned = true,
					observeAppCullFlag = false
				}

				if obstacles then
					for _,obstacle in ipairs(obstacles) do
						local validObstacle = true
						if obstacle.reference then
							if obstacle.reference.baseObject.id:find("T_Aid_PasswallWard_") or obstacle.reference.baseObject.id:find("T_Dae_Ward_") then
							elseif obstacle.reference.disabled then
								validObstacle = false
							elseif obstacle.reference.id == tes3.player.id or (obstacle.reference.baseObject.objectType == tes3.objectType.creature or obstacle.reference.baseObject.objectType == tes3.objectType.npc) and obstacle.reference.mobile.isDead then
								validObstacle = false
							else
								local mesh = tes3.loadMesh(obstacle.reference.baseObject.mesh)
								if mesh.extraData then
									repeat
										if mesh.extraData.string and mesh.extraData.string:lower():find("nc") then validObstacle = false end
									until not mesh.extraData.next
								end
							end
						elseif obstacle.object.name and obstacle.object.name:startswith("Water ") then
							validObstacle = false
						elseif obstacle.object.parent and obstacle.object.parent.name and (obstacle.object.parent.name == "Precipitation Rain Root" or obstacle.object.parent.name == "BM_Snow_01") then
							validObstacle = false
						elseif obstacle.object and obstacle.object.parent and obstacle.object.parent.parent and obstacle.object.parent.parent.name and obstacle.object.parent.parent.name == "COPY VFX_MysticismCast" then		-- Without this, the indicator will move right next to the player while casting
							validObstacle = false
						end

						if validObstacle then
							range = obstacle.distance - (tes3.mobilePlayer.boundSize2D.y / 2) - 16
							break
						end
					end
				end

				if range >= 48 then	-- Having it automatically appear right in front of the player when they blink next to a wall feels awkward
					local destination = tes3.mobilePlayer.position + tes3vector3.new(0, 0, tes3.mobilePlayer.height) + tes3.getPlayerEyeVector() * range

					local heightCheck = tes3.rayTest{
						position = destination + tes3vector3.new(0, 0, tes3.mobilePlayer.height),
						direction = tes3vector3.new(0, 0, -1),
						accurateSkinned = true,
						observeAppCullFlag = false
					}

					local groundPosition
					if heightCheck and heightCheck.distance then
						if heightCheck.reference and heightCheck.reference == tes3.player then	-- Stop the ground mesh from being placed on top of the player, which might otherwise happen if they are looking up
						else
							if tes3.player.cell.waterLevel and heightCheck.intersection.z <= tes3.player.cell.waterLevel and not tes3.player.mobile.underwater and destination.z > tes3.player.cell.waterLevel + 48 then		-- If the player and their destination are above water, then the ground mesh should be too so that it is visible
								groundPosition = tes3vector3.new(heightCheck.intersection.x, heightCheck.intersection.y, tes3.player.cell.waterLevel + 6)
							else
								groundPosition = tes3vector3.new(heightCheck.intersection.x, heightCheck.intersection.y, heightCheck.intersection.z + 24)
							end
					 		if heightCheck.distance < 196 then destination = tes3vector3.new(destination.x, destination.y, destination.z + 196 - heightCheck.distance) end
						end
					end

					tes3.worldController.vfxManager.worldVFXRoot:attachChild(blinkIndicator, true)
					blinkIndicator.appCulled = false
					blinkIndicator:clearTransforms()

					blinkIndicator:update()
					blinkIndicator:updateProperties()
					blinkIndicator:updateNodeEffects()

					blinkIndicator.translation = destination
					blinkIndicator:update()

					if groundPosition then
						tes3.worldController.vfxManager.worldVFXRoot:attachChild(blinkGround, true)
						blinkGround.appCulled = false
						blinkGround:clearTransforms()

						blinkGround:update()
						blinkGround:updateProperties()
						blinkGround:updateNodeEffects()

						blinkGround.translation = groundPosition
						blinkGround:update()
					end
				end

				return
			end
		end
	end
end

function this.removeBlinkData()
	if not (tes3.mobilePlayer.isFalling or tes3.mobilePlayer.isJumping) and (tes3.player.data.tamrielData.hasBlinked or tes3.player.data.tamrielData.blinkVelocity) then
		tes3.player.data.tamrielData.hasBlinked = nil	-- Prevent blinkFallDamage from taking effect when it shouldn't due to the player blinking and not taking fall damage afterwards
		tes3.player.data.tamrielData.blinkVelocity = nil
	end
end

function this.blinkFallDamageSmallJump()
	if tes3.player.data.tamrielData.hasBlinked then
		if not tes3.mobilePlayer.isFalling and not tes3.mobilePlayer.isJumping and tes3.player.data.tamrielData.blinkVelocity and #tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_illusion_Ethereal }) == 0 then
			tes3.player.data.tamrielData.hasBlinked = nil

			if not tes3.mobilePlayer.isSwimming then
				local fatigueTerm = tes3.findGMST(tes3.gmst.fFatigueBase).value - tes3.findGMST(tes3.gmst.fFatigueMult).value * (1 - tes3.mobilePlayer.fatigue.normalized)
				local acrobatics = tes3.mobilePlayer.acrobatics.current
				local jumpMagnitude = 0

				local jumpEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.jump })
				if #jumpEffects > 0 then
					for _,v in pairs(jumpEffects) do
						jumpMagnitude = jumpMagnitude + v.magnitude
					end
				end

				local calculatedDistance = (tes3.player.data.tamrielData.blinkVelocity ^ 2) / (2 * 627.2)

				-- The calculations below and those for the fatigue term above are based on those that OpenMW found for fall damage
				if calculatedDistance <= tes3.findGMST(tes3.gmst.fFallDamageDistanceMin).value then return false end
				calculatedDistance = calculatedDistance - tes3.findGMST(tes3.gmst.fFallDamageDistanceMin).value
				calculatedDistance = calculatedDistance - (1.5 * acrobatics + jumpMagnitude)
				calculatedDistance = math.max(0, calculatedDistance)
				calculatedDistance = calculatedDistance * (tes3.findGMST(tes3.gmst.fFallDistanceBase).value + tes3.findGMST(tes3.gmst.fFallDistanceMult).value)
				calculatedDistance = calculatedDistance * (tes3.findGMST(tes3.gmst.fFallAcroBase).value + tes3.findGMST(tes3.gmst.fFallAcroMult).value * (100 - acrobatics))
				if acrobatics * fatigueTerm < calculatedDistance then tes3.mobilePlayer:hitStun({ knockDown = true }) end
				tes3.mobilePlayer:applyDamage({ damage = calculatedDistance * (1 - .25 * fatigueTerm) })
			end

			tes3.player.data.tamrielData.blinkVelocity = nil
		else
			tes3.player.data.tamrielData.blinkVelocity = tes3.mobilePlayer.velocity.z
		end
	end
end

-- This function cannot correct fall damage in some cases (e.g. jumping and after reaching the peak blinking up much further only to land at the original location), but most problems are resolved by it. The rest are covered by blinkFallDamageSmallJump.
---@param e damageEventData
function this.blinkFallDamage(e)
	if e.source == tes3.damageSource.fall and e.reference == tes3.player and tes3.player.data.tamrielData.hasBlinked then
		tes3.player.data.tamrielData.hasBlinked = nil
		tes3.player.data.tamrielData.blinkVelocity = nil
		local fatigueTerm = tes3.findGMST(tes3.gmst.fFatigueBase).value - tes3.findGMST(tes3.gmst.fFatigueMult).value * (1 - tes3.mobilePlayer.fatigue.normalized)
		local acrobatics = tes3.mobilePlayer.acrobatics.current
		local jumpMagnitude = 0

		local jumpEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.jump })
		if #jumpEffects > 0 then
			for _,v in pairs(jumpEffects) do
				jumpMagnitude = jumpMagnitude + v.magnitude
			end
		end

		local calculatedDistance = (tes3.mobilePlayer.velocity.z ^ 2) / (2 * 627.2)

		-- The calculations below and those for the fatigue term above are based on those that OpenMW found for fall damage
		if calculatedDistance <= tes3.findGMST(tes3.gmst.fFallDamageDistanceMin).value then
			timer.delayOneFrame(function() tes3.mobilePlayer:hitStun({ cancel = true })	end)	-- The hit stun is only applied on the next frame
			return false
		end

		calculatedDistance = calculatedDistance - tes3.findGMST(tes3.gmst.fFallDamageDistanceMin).value
		calculatedDistance = calculatedDistance - (1.5 * acrobatics + jumpMagnitude)
		calculatedDistance = math.max(0, calculatedDistance)
		calculatedDistance = calculatedDistance * (tes3.findGMST(tes3.gmst.fFallDistanceBase).value + tes3.findGMST(tes3.gmst.fFallDistanceMult).value)
		calculatedDistance = calculatedDistance * (tes3.findGMST(tes3.gmst.fFallAcroBase).value + tes3.findGMST(tes3.gmst.fFallAcroMult).value * (100 - acrobatics))
		e.damage = calculatedDistance * (1 - .25 * fatigueTerm)

		if acrobatics * fatigueTerm < calculatedDistance then tes3.mobilePlayer:hitStun({ knockDown = true })
		else
			timer.delayOneFrame(function()
				tes3.mobilePlayer:hitStun({ cancel = true })
			end)
		end

	end
end

---@param e tes3magicEffectTickEventData
local function blinkEffect(e)
	if (not e:trigger()) then
		return
	end

	if tes3.worldController.flagLevitationDisabled then
		tes3ui.showNotifyMenu(common.i18n("magic.blinkLevitationDisabled"))
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	local range = e.effectInstance.magnitude * 22.1

	if range > 0 then
		if config.blinkIndicator then		-- If the indicator is present when Blink's raytests are performed, then it will get in the way
			blinkIndicator.appCulled = true
			tes3.worldController.vfxManager.worldVFXRoot:detachChild(blinkIndicator)
			blinkGround.appCulled = true
			tes3.worldController.vfxManager.worldVFXRoot:detachChild(blinkGround)
		end

		local obstacles = tes3.rayTest{
			position = tes3.getPlayerEyePosition(),
			direction = tes3.getPlayerEyeVector(),
			maxDistance = range,
			findAll = true,
			accurateSkinned = true,		-- I want for people to be able to teleport past actors, which can be difficult and inconsistent without this parameter being true
			observeAppCullFlag = false
		}

		if obstacles then
			for _,obstacle in ipairs(obstacles) do
				local validObstacle = true
				if obstacle.reference then
					if obstacle.reference.baseObject.id:find("T_Aid_PasswallWard_") or obstacle.reference.baseObject.id:find("T_Dae_Ward_") then	-- Needed to prevent a crash that can occur for unclear reasons
					elseif obstacle.reference.disabled then
						validObstacle = false
					elseif obstacle.reference == tes3.player or (obstacle.reference.baseObject.objectType == tes3.objectType.creature or obstacle.reference.baseObject.objectType == tes3.objectType.npc) and obstacle.reference.mobile.isDead then	-- tes3.player cannot be ignored by the rayTest because observeAppCullFlag is false
						validObstacle = false
					else
						local mesh = tes3.loadMesh(obstacle.reference.baseObject.mesh)
						if mesh.extraData then
							repeat
								if mesh.extraData.string and mesh.extraData.string:lower():find("nc") then validObstacle = false end
							until not mesh.extraData.next
						end
					end
				elseif obstacle.object.name and obstacle.object.name:startswith("Water ") then
					validObstacle = false
				elseif obstacle.object.parent and obstacle.object.parent.name and (obstacle.object.parent.name == "Precipitation Rain Root" or obstacle.object.parent.name == "BM_Snow_01") then
					validObstacle = false
				end

				if validObstacle then
					range = obstacle.distance - (tes3.mobilePlayer.boundSize2D.y / 2) - 16		-- The 16 is there to put a bit more space between the player and the target; there is probably a better way to do this by taking the angle of the camera into account though
					break
				end
			end
		end

		if range > 0 then
			local destination = tes3.mobilePlayer.position + tes3.getPlayerEyeVector() * range

			if tes3.player.cell.waterLevel and destination.z >= tes3.player.cell.waterLevel then
				tes3.mobilePlayer.isSwimming = false	-- If the player is swimming, then they need to stop swimming in order to leave the water
			end

			local heightCheck = tes3.rayTest{
				position = destination + tes3vector3.new(0, 0, tes3.mobilePlayer.height),
				direction = tes3vector3.new(0, 0, -1),
				maxDistance = tes3.mobilePlayer.height,
				accurateSkinned = true,
				observeAppCullFlag = false
			}

			if heightCheck and heightCheck.distance then
				destination = destination + tes3vector3.new(0, 0, tes3.mobilePlayer.height - heightCheck.distance)	-- This should prevent the player from clipping through objects below them
			end

			if tes3.mobilePlayer.isFalling or tes3.mobilePlayer.isJumping then tes3.player.data.tamrielData.hasBlinked = true end
			tes3.mobilePlayer.position = destination

			if config.blinkIndicator then
				blinkIndicator.appCulled = false
				tes3.worldController.vfxManager.worldVFXRoot:attachChild(blinkIndicator, true)
			end
		end
	end

	e.effectInstance.state = tes3.spellState.retired
end

---@param e addTempSoundEventData
function this.gazeOfVelothBlockActorSound(e)
	if e.reference and e.reference.data and e.reference.data.tamrielData and e.reference.data.tamrielData.gazeOfVeloth then
		if e.isVoiceover then return false end
	end
end

---@param e bodyPartAssignedEventData
function this.gazeOfVelothBodyPartAssigned(e)
	if e.reference.data.tamrielData and e.reference.data.tamrielData.gazeOfVelothSkeleton then
		if e.index == tes3.partIndex.chest then
			for _,v in pairs(raceSkeletonBodyParts) do
				if e.reference.baseObject.race.id == v[1] then
					if e.bodyPart.partType == tes3.activeBodyPartLayer.base then
						e.bodyPart = tes3.getObject(v[2])
					else
						e.bodyPart = tes3.getObject(v[3])
					end
				end
			end
		else
			e.bodyPart = nil
		end
	end
end

---@param e tes3magicEffectTickEventData
local function gazeOfVelothEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target

	if not target or target.mobile.isDead or (target.data.tamrielData and target.data.tamrielData.wabbajack) then
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	local id = target.baseObject.id:lower()
	local name = target.object.name

	if gazeOfVelothImmuneActors[id] then
		tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothImmune", { name }))
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	if target.mobile.actorType ~= tes3.actorType.npc then
		if id:find("dagoth_ur") then
			tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothDagoth"))
			e.effectInstance.state = tes3.spellState.retired
			return
		elseif target.baseObject.type == tes3.creatureType.humanoid and (id:find("ash_") or id:find("dagoth_") or id:find("corprus_") or id == "ascended_sleeper") then
			tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothAsh", { name }))
			e.effectInstance.state = tes3.spellState.retired
			return
		elseif target.baseObject.type == tes3.creatureType.daedra then
			tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothDaedra", { name }))
			e.effectInstance.state = tes3.spellState.retired
			return
		elseif target.baseObject.type == tes3.creatureType.normal or target.baseObject.type == tes3.creatureType.undead then
			tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothCreature", { name }))
			e.effectInstance.state = tes3.spellState.retired
			return
		else
			tes3ui.showNotifyMenu(common.i18n("magic.gazeOfVelothOther", { name }))
			e.effectInstance.state = tes3.spellState.retired
			return
		end
	end

	target.data.tamrielData = target.data.tamrielData or {}
	target.data.tamrielData.gazeOfVeloth = true
	tes3.removeSound({ sound = nil, reference = target })	-- Stop long-winded voice lines from continuing to play after the target is stripped of their flesh
	tes3.playSound({ sound = tes3.getMagicEffect(tes3.effect.damageHealth).hitSoundEffect, reference = target })	-- The hit sound is stopped by the line above though, so this plays it again
	target.mobile:kill()
	tes3.incrementKillCount({ actor = target.baseObject })

	if target.baseObject.race then
		for _,v in pairs(raceSkeletonBodyParts) do
			if target.baseObject.race.id == v[1] then
				target.data.tamrielData.gazeOfVelothSkeleton = true
				target:updateEquipment()

				e.effectInstance.state = tes3.spellState.retired
				return
			end
		end
	end

	local container = tes3.createReference({ object = "T_Glb_GazeVeloth_Empty", position = target.position , orientation = target.orientation, cell = target.cell })	-- If this runs, then the target does not belong to a compatible race listed in raceSkeletonBodyParts
	tes3.transferInventory({ from = target, to = container, limitCapacity = false })
	tes3.positionCell({ reference = target, position = { 0, 0, -53.187 }, cell = "T_GazeOfVeloth" })	-- All sorts of problems can arise from disabling a target within the effect event

	e.effectInstance.state = tes3.spellState.retired
end

function this.distractedReturnTick()
	for ref in pairs(distractedReferences) do
		---@cast ref tes3reference
		if ref.data.tamrielData and ref.data.tamrielData.distract then
			if (ref.mobile.actorType == tes3.actorType.npc and #ref.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_DistractHumanoid }) == 0) or (ref.mobile.actorType == tes3.actorType.creature and #ref.mobile:getActiveMagicEffects({ effect = tes3.effect.T_illusion_DistractCreature }) == 0) then
				if not ref.mobile.isMovingForward then
					tes3.setAIWander({ reference = ref, range = ref.data.tamrielData.distract.distance, duration = ref.data.tamrielData.distract.duration, time = ref.data.tamrielData.distract.hour, idles = ref.data.tamrielData.distract.idles })

					if ref.data.tamrielData.distract.distance == 0 then
						ref.orientation = ref.data.tamrielData.distract.orientation -- If they are supposed to actually wander around, then not resetting the orientation feels more natural, hence it being under this condition
						ref.data.tamrielData.distractOldPosition = ref.data.tamrielData.distract.position	-- They don't quite return to their original positions, so this is used with onDistractedReferenceActivated to do so
					end

					ref.mobile.hello = ref.data.tamrielData.distract.hello

					ref.data.tamrielData.distract = nil
					distractedReferences[ref] = nil
				end
			end
		end
	end
end

---@param e referenceActivatedEventData
function this.onDistractedReferenceActivated(e)
	if e.reference.data and e.reference.data.tamrielData then
		if e.reference.data.tamrielData.distract then
			distractedReferences[e.reference] = true
		elseif e.reference.data.tamrielData.distractOldPosition then
			e.reference.position = e.reference.data.tamrielData.distractOldPosition
			e.reference.data.tamrielData.distractOldPosition = nil
		end
	end
end

-- Most of this function's code was originally in a function trigged by cellChanged, but that could lead to NPCs visibly teleporting around when moving between exterior cells
---@param e referenceDeactivatedEventData
function this.onDistractedReferenceDeactivated(e)
	local ref = e.reference

	if ref.data and distractedReferences[ref] and ref.data.tamrielData and ref.data.tamrielData.distract then
		tes3.setAIWander({ reference = ref, range = ref.data.tamrielData.distract.distance, duration = ref.data.tamrielData.distract.duration, time = ref.data.tamrielData.distract.hour, idles = ref.data.tamrielData.distract.idles })
		ref.position = ref.data.tamrielData.distract.position

		if ref.data.tamrielData.distract.distance == 0 then ref.orientation = ref.data.tamrielData.distract.orientation end

		ref.mobile.hello = ref.data.tamrielData.distract.hello

		ref.data.tamrielData.distract = nil

		distractedReferences[ref] = nil
	end
end

---@param ref tes3reference
---@param isEnd boolean
local function playDistractedVoiceLine(ref, isEnd)
	if ref.mobile.actorType == tes3.actorType.npc and not ref.mobile.hasVampirism then
		for _,v in pairs(magicData.distractedVoiceLines) do
			local raceID, isFemale, voicesStart, voicesEnd = unpack(v)
			if ref.baseObject.race.id == raceID and ref.baseObject.female == isFemale then
				local voices
				if not isEnd then voices = voicesStart
				else voices = voicesEnd end

				if voices then
					local path = voices[math.random(#voices)]
					if path then tes3.say({ reference = ref, soundPath = path }) end
				end

				return
			end
		end
	elseif ref.mobile.actorType == tes3.actorType.creature then
		local creature = ref.baseObject

		while (creature.soundCreature) do
			creature = creature.soundCreature	-- Get the base sound creature
		end

		local soundGen = tes3.getSoundGenerator(creature.id, tes3.soundGenType.moan)

		if soundGen then tes3.playSound({ reference = ref, sound = soundGen.sound }) end
	end
end

---@param e magicEffectRemovedEventData
function this.distractRemovedEffect(e)
	if e.effect.id == tes3.effect.T_illusion_DistractCreature or e.effect.id == tes3.effect.T_illusion_DistractHumanoid then
		if e.reference and e.reference.data.tamrielData and e.reference.data.tamrielData.distract then
			if math.random() < 0.45 then playDistractedVoiceLine(e.reference, true) end
			tes3.setAITravel({ reference = e.reference, destination = e.reference.data.tamrielData.distract.position })
		end
	end
end

---@param ref tes3reference
---@param package tes3aiPackageWander
local function distractSavePackage(ref, package)
	ref.data.tamrielData = ref.data.tamrielData or {}

	if not package then
		ref.data.tamrielData.distract = {
			position = {
				ref.position.x,
				ref.position.y,
				ref.position.z
			},
			orientation = {
				ref.orientation.x,
				ref.orientation.y,
				ref.orientation.z
			},
			cell = ref.cell.id,
			distance = 0,
			duration = 0,
			hour = 0,
			idles = { 60, 20, 10, 0, 0, 0, 0, 0 },
			hello = ref.mobile.hello
		}
	elseif package.type == 0 then	-- Have condition for preexisting travel package too?
		local packageIdles = {}
		for k,v in pairs(package.idles) do
			packageIdles[k] = v.chance
		end

		ref.data.tamrielData.distract = {
			position = {
				ref.position.x,
				ref.position.y,
				ref.position.z
			},
			orientation = {
				ref.orientation.x,
				ref.orientation.y,
				ref.orientation.z
			},
			cell = ref.cell.id,
			distance = package.distance,
			duration = package.duration,
			hour = package.hourOfDay,
			idles = packageIdles,
			hello = ref.mobile.hello
		}
	end
end

---@param e tes3magicEffectTickEventData
local function distractEffect(e)
	local target = e.effectInstance.target
	local range = e.effectInstance.magnitude * 22.1

	local activePackage = target.mobile.aiPlanner:getActivePackage()
	if not activePackage or activePackage.type < 1 then
		local targetDistance
		local finalPlayerDistance

		local bestDestination

		if target.cell.isInterior or (target.cell.pathGrid and #target.cell.pathGrid.nodes > 9 and target.position:distance(common.getClosestNode(target).position) <= 512) then	-- The path grid approach is used in interiors and in exterior cells where there are many nodes with one nearby, such as in cities. These conditions should prevent actors outside of a city's walls yet still in the cell from moving inside.
			local nodeArr = target.cell.pathGrid.nodes
			local bestScore = 0

			local threeClosestNodes = common.getClosestNodes(target, 512)

			for _,node in pairs(nodeArr) do
				if math.abs(node.position.z - target.position.z) < 384 then		-- This is meant to stop actors from walking up/down several flights of stairs, which I think would feel unrealistic
					targetDistance = target.position:distance(node.position)
					if targetDistance <= range then
						local pathExists = common.pathGridBFS(threeClosestNodes[1], node)	-- pathGridBFS is used here to check whether a path actually exists because it is quicker than pathGridDijkstra
						if pathExists then
							finalPlayerDistance = tes3.player.position:distance(node.position)
							if math.abs(tes3.player.position.z - node.position.z) > 160 then finalPlayerDistance = finalPlayerDistance * 4 end	-- This condition makes actors prefer to travel to a above or below the player. 4 was chosen as a constant arbitrarily and adjusting it may be beneficial.

							local shortestPathDistance = math.huge
							local shortestPath
							if node ~= threeClosestNodes[1] and node ~= threeClosestNodes[2] and node ~= threeClosestNodes[3] then
								for _,v in ipairs(threeClosestNodes) do				-- This loop recreates the logic of how actors move along pathgrid nodes to reach some destination, allowing for values such as how close the actor comes to the player to be determined later
									---@cast v tes3pathGridNode
									local path = common.pathGridDijkstra(v, node)
									local pathDistance = 0
									local previousPathNode

									if path then
										for _,pathNode in ipairs(path) do
											---@cast pathNode tes3pathGridNode
											if previousPathNode then pathDistance = pathDistance + pathNode.position:distance(previousPathNode.position) end
											previousPathNode = pathNode
										end

										if pathDistance < shortestPathDistance then	-- Actors prefer to take the shortest path to their destination starting from the 3 nodes that are closest to them
											shortestPath = path
											shortestPathDistance = pathDistance
										end
									end
								end
							else
								shortestPath = { node }
							end

							local nodePlayerDistance
							local shortestPlayerDistance = math.huge

							if shortestPath then
								for _,pathNode in pairs(shortestPath) do	-- Optimize this loop by stopping once the actor begins moving away from the player?
									nodePlayerDistance = tes3.player.position:distance(pathNode.position)
									if math.abs(tes3.player.position.z - pathNode.position.z) > 160 then nodePlayerDistance = nodePlayerDistance * 4 end
									if nodePlayerDistance < shortestPlayerDistance then shortestPlayerDistance = nodePlayerDistance end
								end

								local score = (targetDistance / 2) + (finalPlayerDistance / 4) + shortestPlayerDistance		-- A destination is more suitable the further away it is from the target, the further away it is from their player, and the further away that the target stays from the player while travelling. These constants were also chosen arbitrarily.

								if score > bestScore then
									bestScore = score
									bestDestination = node.position
								end
							end
						end
					end
				end
			end
		else
			local bestDistance = 0
			local bestPlayerFinalDistance = 0
			local destination

			for rotation = 0, 342, 18 do
				local pathCollision = tes3.rayTest{	-- This is not a very rigorous check, but anything that works better would also be much more complicated, so this is it for now
					position = target.position + tes3vector3.new(0, 0, 0.25 * target.mobile.height),
					direction = target.orientation + tes3vector3.new(0, 0, rotation),
					maxDistance = range + target.mobile.boundSize2D.y / 2,
					ignore = { target },
				}

				if pathCollision and pathCollision.distance then targetDistance = pathCollision.distance - target.mobile.boundSize2D.y / 2
				else targetDistance = range end

				if targetDistance >= bestDistance then
					destination = target.position + tes3vector3.new(math.sin(math.rad(rotation)) * range, math.cos(math.rad(rotation)) * range, 0)
					finalPlayerDistance = tes3.player.position:distance(destination)

					if finalPlayerDistance > bestPlayerFinalDistance then
						bestDistance = targetDistance
						bestPlayerFinalDistance = finalPlayerDistance
						bestDestination = destination
					end
				end
			end
		end

		if bestDestination then
			distractSavePackage(target, activePackage)
			if math.random() < 0.45 then playDistractedVoiceLine(target, false) end
			tes3.setAITravel({ reference = target, destination = bestDestination })
			target.mobile.hello = 0
			distractedReferences[target] = true
		else
			target.data.tamrielData = target.data.tamrielData or {}
			target.data.tamrielData.distract = nil
		end
	end
end

---@param e tes3magicEffectTickEventData
local function distractHumanoidEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target	-- Level restriction? Tied to magnitude?

	if not target or target.mobile.actorType ~= tes3.actorType.npc or target.mobile.isDead or target.mobile.inCombat or target.mobile.isPlayerDetected or (target.data.tamrielData and target.data.tamrielData.distract) then
		e.effectInstance.state = tes3.spellState.retired	-- This condition seems to be hit when the effect expires
		return
	end

	--	if target.mobile.isPlayerDetected then
	--		tes3.triggerCrime({ type = tes3.crimeType.trespass })
	--		e.effectInstance.state = tes3.spellState.retired
	--		return
	--	end

	distractEffect(e)
end

---@param e tes3magicEffectTickEventData
local function distractCreatureEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target	-- Level restriction? Tied to magnitude?

	if not target or target.mobile.actorType ~= tes3.actorType.creature or target.mobile.isDead or target.mobile.inCombat or target.mobile.isPlayerDetected or (target.data.tamrielData and target.data.tamrielData.distract) then	-- Require player to sneak?
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	distractEffect(e)
end

-- Stop the player from talking to the summon and the summon from talking to the player (just in case)
---@param e activateEventData
function this.corruptionBlockActivation(e)
	if e.target.id == tes3.player.data.tamrielData.corruptionReferenceID or (e.target == tes3.player and e.activator.id and e.activator.id == tes3.player.data.tamrielData.corruptionReferenceID) then return false end
end

---@param e mobileActivatedEventData
function this.corruptionSummoned(e)
	if corruptionCasted and e.reference.baseObject.id == corruptionActorID then	-- Apply VFX to summon here as well?
		corruptionCasted = false
		tes3.player.data.tamrielData.corruptionReferenceID = e.reference.id
		e.mobile.alarm = 0
		e.mobile.fight = 100
		e.mobile.flee = 0
		e.mobile.hello = 0

		---@cast corruptionTargetReference tes3reference
		if corruptionTargetReference then	-- Just in case
			-- The loops below ensure that the summoned reference does not have different items from leveled items than the target and that they only have items relevant for actors in combat
			for _,itemStack in pairs(e.mobile.inventory) do
				itemStack.count = 0
			end

			for _,itemStack in pairs(corruptionTargetReference.mobile.inventory) do
				if itemStack.object.objectType == tes3.objectType.ammunition or itemStack.object.objectType == tes3.objectType.armor or itemStack.object.objectType == tes3.objectType.clothing or itemStack.object.objectType == tes3.objectType.weapon then
					local firstItemData
					if itemStack.variables then firstItemData = itemStack.variables[1] end

					tes3.addItem({ reference = e.reference, item = itemStack.object, count = itemStack.count, itemData = firstItemData })	-- Just using the first item's itemData should be fine here
				end
			end
		end

		corruptionTargetReference = nil
	end
end

---@param e tes3magicEffectTickEventData
local function corruptionEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target

	if target.id ~= tes3.player.data.tamrielData.corruptionReferenceID then	-- Memory errors can be reported if the effect is applied to the summon and doing so is weird anyways
		if target.baseObject.script and (not ((target.baseObject.script.id:find("T_ScNpc") and not target.baseObject.script.id:find("_Were")) or safeScripts[target.baseObject.script.id]) or hasScriptedItem(target.mobile.inventory)) then	-- Checks whether the target has a scripted item or a script that is not known to be safely cloneable
			tes3ui.showNotifyMenu(common.i18n("magic.corruptionScript", { target.object.name }))
			e.effectInstance.state = tes3.spellState.retired
			restoreCharge(e.sourceInstance)
			return
		end

		corruptionActorID = target.baseObject.id
		corruptionTargetReference = target
		corruptionCasted = true
		tes3.cast({ reference = e.sourceInstance.caster, spell = "T_Dae_Cnj_UNI_CorruptionSummon", alwaysSucceeds = true, bypassResistances = true, instant = true, target = e.sourceInstance.caster })
	else
		tes3ui.showNotifyMenu(common.i18n("magic.corruptionSummon"))
		restoreCharge(e.sourceInstance)
	end

	e.effectInstance.state = tes3.spellState.retired
end

---@param e tes3magicEffectTickEventData
local function weaponResartusEffect(e)
	if (not e:trigger()) then
		return
	end

	local weapon = tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.weapon})

	if weapon then
		weapon.itemData.condition = weapon.itemData.condition + e.effectInstance.magnitude
		if weapon.itemData.condition > weapon.object.maxCondition then
			weapon.itemData.condition = weapon.object.maxCondition
		end

		weapon.itemData.charge = weapon.itemData.charge + e.effectInstance.magnitude
		if weapon.itemData.charge > weapon.object.enchantment.maxCharge then
			weapon.itemData.charge = weapon.object.enchantment.maxCharge
		end
	end

	e.effectInstance.state = tes3.spellState.retired
end

---@param e tes3magicEffectTickEventData
local function armorResartusEffect(e)
	if (not e:trigger()) then
		return
	end

	local armor = {
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.cuirass }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.greaves }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.helmet }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.boots }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.shield }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.leftPauldron }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.rightPauldron }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.leftGauntlet }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.rightGauntlet }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.leftBracer }),
		tes3.getEquippedItem({ actor = e.sourceInstance.caster, enchanted = true, objectType = tes3.objectType.armor, slot = tes3.armorSlot.rightBracer })
	}

	local conditionMagnitude = e.effectInstance.magnitude
	local chargeMagnitude = e.effectInstance.magnitude
	local hasChanged = false

	while conditionMagnitude > 0 or chargeMagnitude > 0 do
		for _,item in pairs(armor) do
			if item then
				if conditionMagnitude > 0 and item.itemData.condition < item.object.maxCondition then
					item.itemData.condition = item.itemData.condition + 1
					conditionMagnitude = conditionMagnitude - 1
					hasChanged = true
				end

				if chargeMagnitude > 0 and item.itemData.charge < item.object.enchantment.maxCharge then
					item.itemData.charge = item.itemData.charge + 1
					chargeMagnitude = chargeMagnitude - 1
					hasChanged = true
				end
			end
		end

		if not hasChanged then break end

		hasChanged = false
	end

	e.effectInstance.state = tes3.spellState.retired
end

-- Diject's mapMarkerLib was an invaluable reference for the calculations required to make these map markers work
---@param mapPane tes3uiElement
---@param multiPane tes3uiElement
local function calculateMapValues(mapPane, multiPane)
	local mapCell = mapPane:findChild("MenuMap_map_cell")
	local multiCell = multiPane:findChild("MenuMap_map_cell")

	mapWidth = mapCell.width
	mapHeight = mapCell.height
	multiWidth = multiCell.width
	multiHeight = multiCell.height

	if tes3.player.cell.isInterior then
		local mapPlayerMarker = mapPane:findChild("MenuMap_local_player")
		local multiPlayerMarker = multiPane.parent.parent:findChild("MenuMap_local_player")

		local northMarkerAngle = 0
		for ref in tes3.player.cell:iterateReferences(tes3.objectType.static) do
			if ref.baseObject.id == "NorthMarker" then
				northMarkerAngle = ref.orientation.z
				break
			end
		end

		northMarkerCos = math.cos(northMarkerAngle)
		northMarkerSin = math.sin(northMarkerAngle)

		local xShift = -tes3.player.position.x
		local yShift = tes3.player.position.y
		local xNorm = xShift * northMarkerCos + yShift * northMarkerSin
		local yNorm = yShift * northMarkerCos - xShift * northMarkerSin

		local newInteriorMapOriginX = mapPlayerMarker.positionX + xNorm / (8192 / mapWidth)
		local newInteriorMapOriginY = mapPlayerMarker.positionY - yNorm / (8192 / mapHeight)
		local newInteriorMultiOriginX = -multiPane.parent.positionX + multiPlayerMarker.positionX + xNorm / (8192 / multiWidth)
		local newInteriorMultiOriginY = -multiPane.parent.positionY + multiPlayerMarker.positionY - yNorm / (8192 / multiHeight)

		if not (math.isclose(interiorMapOriginX, newInteriorMapOriginX, 2) and (math.isclose(interiorMapOriginY, newInteriorMapOriginY, 2))) then
			interiorMapOriginX = newInteriorMapOriginX
			interiorMapOriginY = newInteriorMapOriginY
		end

		if not (math.isclose(interiorMultiOriginX, newInteriorMapOriginX, 2) and (math.isclose(interiorMultiOriginY, newInteriorMapOriginY, 2))) then
			interiorMultiOriginX = newInteriorMultiOriginX
			interiorMultiOriginY = newInteriorMultiOriginY
		end
	else
		-- It seems as though this is not being updated exactly when it should be; exterior markers will briefly move across cells as the player moves around.
		local mapLayout = mapPane:findChild("MenuMap_map_layout")
		local mapCellProperty = mapCell:getPropertyObject("MenuMap_cell")
		local multiCellProperty = multiCell:getPropertyObject("MenuMap_cell")
		local multiLayout = multiPane:findChild("MenuMap_map_layout")

		if mapCellProperty and multiCellProperty then
			mapOriginGridX = mapCellProperty.gridX - math.floor(mapCell.positionX / mapCell.width)	-- Should each set of lines really have different types of values in the numerators?
			mapOriginGridY = mapCellProperty.gridY - math.floor(mapLayout.positionY / mapCell.height)
			multiOriginGridX = multiCellProperty.gridX - math.floor(multiCell.positionX / multiCell.width)
			multiOriginGridY = multiCellProperty.gridY - math.floor(multiLayout.positionY / multiCell.height)
		end
	end
end

---@param position tes3vector3
---@return number, number, number, number
local function calcInteriorPos(position)
	local xNorm = position.x * northMarkerCos - position.y * northMarkerSin
	local yNorm = -position.y * northMarkerCos - position.x * northMarkerSin

	local mapX = interiorMapOriginX + xNorm / (8192 / mapWidth)
	local mapY = interiorMapOriginY - yNorm / (8192 / mapHeight)
	local multiX = interiorMultiOriginX + xNorm / (8192 / multiWidth)
	local multiY = interiorMultiOriginY - yNorm / (8192 / multiHeight)

	return mapX, mapY, multiX, multiY
end

---@param position tes3vector3
---@return number, number, number, number
local function calcExteriorPos(position)
	local mapX = (position.x / 8192 - mapOriginGridX) * mapWidth
	local mapY = (position.y / 8192 - mapOriginGridY - 1) * mapHeight
	local multiX = (position.x / 8192 - multiOriginGridX) * multiWidth
	local multiY = (position.y / 8192 - multiOriginGridY - 1) * multiHeight

	return mapX, mapY, multiX, multiY
end

---@param pane tes3uiElement
---@param x number
---@param y number
---@param name string
---@param iconPath string
local function createDetections(pane, x, y, name, iconPath)
	local detection = pane:createImage({ id = name, path = iconPath })
	detection.positionX = x
	detection.positionY = y
	detection.absolutePosAlignX = -32668
	detection.absolutePosAlignY = -32668
	detection.width = 3
	detection.height = 3
end

---@param pane tes3uiElement
local function deleteDetections(pane, name)
	for _,child in pairs (pane.children) do
		if child.name == name then child:destroy() end
	end
end

---@param e magicEffectRemovedEventData
function this.detectValuablesTick(e)
	if e.reference and e.reference ~= tes3.player then return end	-- I would just use a filter, but that triggers a warning for some reason
	local mapMenu = tes3ui.findMenu("MenuMap")
	local multiMenu = tes3ui.findMenu("MenuMulti")
	local mapPane, multiPane

	if mapMenu then mapPane = mapMenu:findChild("MenuMap_pane") end
	if multiMenu then multiPane = multiMenu:findChild("MenuMap_pane") end

	if mapPane then deleteDetections(mapPane, "T_detVal") end
	if multiPane then deleteDetections(multiPane, "T_detVal") end

	if mapPane and multiPane then
		local detectValuablesEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetValuables })
		if #detectValuablesEffects > 0 then
			calculateMapValues(mapPane, multiPane)	-- Move this into a separate tick function so that it only runs once, rather than for each detection effect?

			local totalMagnitude = 0
			for _,v in pairs(detectValuablesEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end
			totalMagnitude = totalMagnitude * 22.1

			local minValue = config.detectValuablesThreshold	-- The minimum value that an item must be to be detected

			for _,cell in pairs(tes3.getActiveCells()) do
				for item in cell:iterateReferences({ tes3.objectType.alchemy, tes3.objectType.ammunition, tes3.objectType.apparatus, tes3.objectType.armor, tes3.objectType.book, tes3.objectType.clothing, tes3.objectType.ingredient, tes3.objectType.light, tes3.objectType.lockpick, tes3.objectType.miscItem, tes3.objectType.probe, tes3.objectType.repairItem, tes3.objectType.weapon }, false) do
					if item.baseObject.value and item.baseObject.value >= minValue and tes3.player.position:distance(item.position) <= totalMagnitude then
						local mapX, mapY, multiX, multiY
						if cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(item.position)
						else mapX, mapY, multiX, multiY = calcExteriorPos(item.position) end

						createDetections(mapPane, mapX, mapY, "T_detVal", "textures\\td\\td_detect_valuable_icon.dds")
						createDetections(multiPane, multiX, multiY, "T_detVal", "textures\\td\\td_detect_valuable_icon.dds")
					end
				end

				for ref in cell:iterateReferences({ tes3.objectType.container, tes3.objectType.creature, tes3.objectType.npc }, false) do
					if ref ~= tes3.player and tes3.player.position:distance(ref.position) <= totalMagnitude then
						local hasValuable = false
						for _,stack in pairs(ref.object.inventory.items) do
							---@cast stack tes3itemStack
							if stack.object.objectType == tes3.objectType.leveledItem then
								local valueSum = 0
								local itemCount = 0

								local minLevel = 0	-- The minimum level that an item must be associated with to be chosen; set to the highest level if calculateFromAllLevels is false or left at 0 if it is true
								if not stack.object.calculateFromAllLevels then
									for _,node in pairs(stack.object.list) do
										---@cast node tes3leveledListNode
										if node.levelRequired > minLevel and tes3.player.baseObject.level >= node.levelRequired then minLevel = node.levelRequired end
									end
								end

								for _,node in pairs(stack.object.list) do
								---@cast node tes3leveledListNode
									if node.levelRequired >= minLevel and tes3.player.baseObject.level >= node.levelRequired then
										if node.object.value then
											valueSum = valueSum + node.object.value
											itemCount = itemCount + 1
										end
									end
								end

								if itemCount > 0 and valueSum / itemCount >= minValue then
									hasValuable = true
									break
								end
							else
								if stack.object.value >= minValue then
									hasValuable = true
									break
								end
							end
						end

						if hasValuable then
							local mapX, mapY, multiX, multiY
							if cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(ref.position)
							else mapX, mapY, multiX, multiY = calcExteriorPos(ref.position) end

							createDetections(mapPane, mapX, mapY, "T_detVal", "textures\\td\\td_detect_valuable_icon.dds")
							createDetections(multiPane, multiX, multiY, "T_detVal", "textures\\td\\td_detect_valuable_icon.dds")
						end
					end
				end
			end
		end
	end
end

---@param ref tes3reference
---@return boolean
local function detectInvisibilityValid(ref)
	if ref == tes3.player or not ref.mobile then return false end

	local obj = ref.baseObject

	if obj.mesh:lower():find("ghost") or obj.mesh:lower():find("spirit") or obj.mesh:lower():find("wraith") or obj.mesh:lower():find("spectre") or obj.mesh:lower():find("specter")	-- These conditions should catch most if not all actors that shouldn't be affected by Detect Invisibility
		or obj.id:lower():find("ghost") or obj.id:lower():find("spirit") or obj.id:lower():find("wraith") or obj.id:lower():find("spectre") or obj.id:lower():find("specter") then
		return false
	end

	if not tes3.canCastSpells({ target = ref }) then return false end
	local actorSpells = tes3.getSpells({ target = ref, spellType = tes3.spellType.ability, getActorSpells = true, getRaceSpells = false, getBirthsignSpells = false })

	if actorSpells then
		local ghostAbilities = { tes3.getObject("ghost ability"), tes3.getObject("Ulfgar_Ghost_sp") , tes3.getObject("TR_m4_EmmurbalpituGhost_EN"), tes3.getObject("TR_m3_OE_GhostGlow"), tes3.getObject("TR_m4_RR_StorigGlow") }	-- It would be nice to just have a single TD ghost effect where possible

		for _,spell in pairs(actorSpells) do
			for _,ability in pairs(ghostAbilities) do
				if ability and spell == ability then return false end
			end
		end
	end

	for _,effect in pairs(ref.mobile.activeMagicEffectList)do
		if effect.effectId == tes3.effect.chameleon or effect.effectId == tes3.effect.invisibility then return true end
	end

	return false
end

---@param e mobileActivatedEventData
function this.onInvisibleMobileActivated(e)
	if detectInvisibilityValid(e.reference) then	-- This kind of approach should be reliable until someone makes an addon that allows for the AI to use chameleon and invisibility effects.
		local chameleonEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.chameleon })		-- Might as well get these values here
		local chameleonMagnitude = 0
		if #chameleonEffects > 0 then
			for _,v in pairs(chameleonEffects) do
				chameleonMagnitude = chameleonMagnitude + v.magnitude
			end

			chameleonMagnitude = math.clamp(chameleonMagnitude / 100, 0, 1)
		end

		local invisibilityMagnitude = 0
		if #e.mobile:getActiveMagicEffects({ effect = tes3.effect.invisibility }) > 0 then
			invisibilityMagnitude = 1
		end

		invisibleReferences[e.reference] = { chameleon = chameleonMagnitude, invisibility = invisibilityMagnitude }		-- The magnitudes are saved so that the effects do not have to be iterated through for every invisible reference every frame in the opacity function
	end
end

---@param e spellTickEventData
function this.invisibilityAppliedEffect(e)
	if e.target and e.target ~= tes3.player and (e.effect.id == tes3.effect.chameleon or e.effect.id == tes3.effect.invisibility) and not invisibleReferences[e.target] then	-- Could this miss another effect being applied to an actor that is already "invisible"? Yes, but I don't really care at the moment.
		this.onInvisibleMobileActivated({ claim = false, mobile = e.target.mobile, reference = e.target })
	end
end

---@param e mobileDeactivatedEventData
function this.onInvisibleMobileDeactivated(e)
	invisibleReferences[e.reference] = nil
end

---@param e magicEffectRemovedEventData
function this.invisibilityRemovedEffect(e)
	if e.target and e.target ~= tes3.player and e.effect.id == tes3.effect.chameleon or e.effect.id == tes3.effect.invisibility then
		if detectInvisibilityValid(e.reference) then															-- The actor might (but probably won't) still have other acceptable effects
			local chameleonEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.chameleon })
			local chameleonMagnitude = 0
			if #chameleonEffects > 0 then
				for _,v in pairs(chameleonEffects) do
					chameleonMagnitude = chameleonMagnitude + v.magnitude
				end

				chameleonMagnitude = math.clamp(chameleonMagnitude / 100, 0, 1)
			end

			local invisibilityMagnitude = 0
			if #e.mobile:getActiveMagicEffects({ effect = tes3.effect.invisibility }) > 0 then
				invisibilityMagnitude = 1
			end

			invisibleReferences[e.reference] = { chameleon = chameleonMagnitude, invisibility = invisibilityMagnitude }
		else
			invisibleReferences[e.reference] = nil
		end
	end
end

--- @param e simulateEventData
function this.detectInvisibilityOpacity(e)
	for actor,magnitudes in pairs(invisibleReferences) do		-- Should the other parts of Detect Invisibility rely on invisibleReferences too?
		local detectInvisibilityEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetInvisibility })
		local undetectable = false
		if #detectInvisibilityEffects > 0 then
			local detectMagnitude = 0
			for _,v in pairs(detectInvisibilityEffects) do
				if v.magnitude > detectMagnitude then detectMagnitude = detectMagnitude + v.magnitude end
			end

			if tes3.player.position:distance(actor.position) <= detectMagnitude * 22.1 then
				local opacity = math.clamp((1 - .375 * magnitudes.chameleon) * (1 - magnitudes.invisibility), 0.5, 0.99999)
				actor.mobile.animationController.opacity = opacity
				actor.data.tamrielData = actor.data.tamrielData or {}
				actor.data.tamrielData.invisibilityDetected = true
			else
				undetectable = true
			end
		else
			undetectable = true
		end


		if undetectable and actor.data.tamrielData and actor.data.tamrielData.invisibilityDetected then
			local opacity = math.clamp((1 - .75 * magnitudes.chameleon) * (1 - magnitudes.invisibility), 0, 0.99999)	-- A value of 1 is naturally not supported by the engine, so it is set to 0.99999 until MWSE's developers fix that bug
			actor.mobile.animationController.opacity = opacity
			actor.data.tamrielData.invisibilityDetected = false
		end
	end
end

--- @param e calcHitChanceEventData
function this.detectInvisibilityHitChance(e)
	local fCombatInvisoMult = tes3.findGMST(tes3.gmst.fCombatInvisoMult).value

	local detectInvisibilityEffects = e.attackerMobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetInvisibility })
	if #detectInvisibilityEffects > 0 then
		local detectMagnitude = 0
		for _,v in pairs(detectInvisibilityEffects) do
			if v.magnitude > detectMagnitude then detectMagnitude = detectMagnitude + v.magnitude end
		end

		if e.target and e.targetMobile and e.attacker.position:distance(e.target.position) <= detectMagnitude * 22.1 and not table.contains(tes3.player.mobile.friendlyActors, e.targetMobile) then
			if detectInvisibilityValid(e.target) then
				local chameleonEffects = e.targetMobile:getActiveMagicEffects({ effect = tes3.effect.chameleon })
				local chameleonMagnitude = 0
				local reducedChameleonMagnitude = 0
				if #chameleonEffects > 0 then
					for _,v in pairs(chameleonEffects) do
						chameleonMagnitude = chameleonMagnitude + v.magnitude
					end

					if chameleonMagnitude > 100 then chameleonMagnitude = 100 end

					reducedChameleonMagnitude = chameleonMagnitude - 50
					if reducedChameleonMagnitude < 0 then reducedChameleonMagnitude = 0 end
				end

				local invisibilityEffects = e.targetMobile:getActiveMagicEffects({ effect = tes3.effect.invisibility })
				local invisibilityMagnitude = 0
				if #invisibilityEffects > 0 then
					invisibilityMagnitude = 1		-- It doesn't look as though invisibility has much effect on hitchance as per https://wiki.openmw.org/index.php?title=Research:Combat and my own testing. In the calculation, invisibility's magnitude will be evaluated as 1 and multiplied by fCombatInvisoMult (.2).
				end

				e.hitChance = e.hitChance + fCombatInvisoMult * (chameleonMagnitude - reducedChameleonMagnitude)
				e.hitChance = e.hitChance + fCombatInvisoMult * invisibilityMagnitude / 2
			end
		end
	end
end

--- @param e magicEffectRemovedEventData
function this.detectInvisibilityTick(e)
	if e.reference and e.reference ~= tes3.player then return end	-- I would just use a filter, but that triggers a warning for some reason

	local mapMenu = tes3ui.findMenu("MenuMap")
	local multiMenu = tes3ui.findMenu("MenuMulti")
	local mapPane, multiPane

	if mapMenu then mapPane = mapMenu:findChild("MenuMap_pane") end
	if multiMenu then multiPane = multiMenu:findChild("MenuMap_pane") end

	if mapPane then deleteDetections(mapPane, "T_detInv") end
	if multiPane then deleteDetections(multiPane, "T_detInv") end

	if mapMenu and multiMenu then
		local detectInvisibilityEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetInvisibility })
		if #detectInvisibilityEffects > 0 then
			calculateMapValues(mapPane, multiPane)

			local totalMagnitude = 0
			for _,v in pairs(detectInvisibilityEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end

			for _,actor in pairs(tes3.findActorsInProximity({ reference = tes3.player, range = totalMagnitude * 22.1 })) do	-- This should probably be changed to a refrence manager like the dreugh and lamia get in behavior.lua 
				if detectInvisibilityValid(actor.reference) then
					local mapX, mapY, multiX, multiY
					if tes3.player.cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(actor.position)
					else mapX, mapY, multiX, multiY = calcExteriorPos(actor.position) end

					createDetections(mapPane, mapX, mapY, "T_detInv", "textures\\td\\td_detect_invisibility_icon.dds")
					createDetections(multiPane, multiX, multiY, "T_detInv", "textures\\td\\td_detect_invisibility_icon.dds")
				end
			end
		end
	end
end

--- @param e magicEffectRemovedEventData
function this.detectEnemyTick(e)
	if e.reference and e.reference ~= tes3.player then return end	-- I would just use a filter, but that triggers a warning for some reason

	local mapMenu = tes3ui.findMenu("MenuMap")
	local multiMenu = tes3ui.findMenu("MenuMulti")
	local mapPane, multiPane

	if mapMenu then mapPane = mapMenu:findChild("MenuMap_pane") end
	if multiMenu then multiPane = multiMenu:findChild("MenuMap_pane") end

	if mapPane then deleteDetections(mapPane, "T_detEnm") end
	if multiPane then deleteDetections(multiPane, "T_detEnm") end

	if mapMenu and multiMenu then
		local detectEnemyEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetEnemy })
		if #detectEnemyEffects > 0 then
			calculateMapValues(mapPane, multiPane)

			local totalMagnitude = 0
			for _,v in pairs(detectEnemyEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end

			for _,actor in pairs(tes3.findActorsInProximity({ reference = tes3.player, range = totalMagnitude * 22.1 })) do	-- This should probably be changed to a refrence manager like the dreugh and lamia get in behavior.lua 
				local isHostile = false
				for _,hostileActor in pairs(actor.hostileActors) do
					if hostileActor == tes3.mobilePlayer then
						isHostile = true
					end
				end

				local disposition = 0
				if not isHostile and actor.actorType == tes3.actorType.npc then
					disposition = actor.reference.object.disposition
				end

				if (isHostile or (actor.fight > 70 and disposition < (actor.fight - 70) * 5)) and not table.contains(actor.friendlyActors, tes3.mobilePlayer) then	-- Checking the friendly actors is needed for the player's summons to not be detected (unless the player attacks them)
					local mapX, mapY, multiX, multiY
					if tes3.player.cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(actor.position)
					else mapX, mapY, multiX, multiY = calcExteriorPos(actor.position) end

					createDetections(mapPane, mapX, mapY, "T_detEnm", "textures\\td\\td_detect_enemy_icon.dds")
					createDetections(multiPane, multiX, multiY, "T_detEnm", "textures\\td\\td_detect_enemy_icon.dds")
				end
			end
		end
	end
end

--- @param e magicEffectRemovedEventData
function this.detectHumanoidTick(e)
	if e.reference and e.reference ~= tes3.player then return end	-- I would just use a filter, but that triggers a warning for some reason

	local mapMenu = tes3ui.findMenu("MenuMap")
	local multiMenu = tes3ui.findMenu("MenuMulti")
	local mapPane, multiPane

	if mapMenu then mapPane = mapMenu:findChild("MenuMap_pane") end
	if multiMenu then multiPane = multiMenu:findChild("MenuMap_pane") end

	if mapPane then deleteDetections(mapPane, "T_detHum") end
	if multiPane then deleteDetections(multiPane, "T_detHum") end

	if mapPane and multiPane then
		local detectHumanoidEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetHuman })
		if #detectHumanoidEffects > 0 then
			calculateMapValues(mapPane, multiPane)	-- Move this into a separate tick function so that it only runs once, rather than for each detection effect?

			local totalMagnitude = 0
			for _,v in pairs(detectHumanoidEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end

			for _,actor in pairs(tes3.findActorsInProximity({ reference = tes3.player, range = totalMagnitude * 22.1 })) do	-- This should probably be changed to a refrence manager like the dreugh and lamia get in behavior.lua 
				if actor.actorType == tes3.actorType.npc then
					local mapX, mapY, multiX, multiY
					if tes3.player.cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(actor.position)
					else mapX, mapY, multiX, multiY = calcExteriorPos(actor.position) end

					createDetections(mapPane, mapX, mapY, "T_detHum", "textures\\td\\td_detect_humanoid_icon.dds")
					createDetections(multiPane, multiX, multiY, "T_detHum", "textures\\td\\td_detect_humanoid_icon.dds")
				end
			end
		end
	end
end

---@param e leveledItemPickedEventData
function this.insightEffect(e)
	local insightEffects = tes3.mobilePlayer:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_Insight })
	if #insightEffects > 0 and e.list.count > 0 then
		local totalMagnitude = 0
		for _,v in pairs(insightEffects) do
			totalMagnitude = totalMagnitude + v.magnitude
		end

		local effectiveMagnitude = totalMagnitude / 100
		if effectiveMagnitude > 1 then effectiveMagnitude = 1 end		-- If the total magnitude ends up being higher than 100, this ensures that the probabilities won't get messed up

		if effectiveMagnitude > 0 then
			if e.list.chanceForNothing > 0 then
				local nothingFactor = 1 - (effectiveMagnitude * .9)	-- 0% chance of getting nothing seems OP and too obvious, so the probability of getting nothing is reduced by 90% at most
				local nothingChance = e.list.chanceForNothing * nothingFactor
				if math.random() * 100 < nothingChance then
					e.pick = nil
					return
				elseif e.list.count == 1 then
					e.pick = e.list.list[1].object
					return
				end
			end

			if e.list.count > 1 then
				local maxLevel = 0
				for _,v in pairs(e.list.list) do
					if v.levelRequired > maxLevel and v.levelRequired <= tes3.player.object.level then
						maxLevel = v.levelRequired
					end
				end

				local leveledItemTable = { }
				local maxValue = 0
				local minValue = math.huge
				local valueTemp = 0
				local tableIndex = 1

				for _,v in pairs(e.list.list) do
					if v.levelRequired == maxLevel or (v.levelRequired < tes3.player.object.level and e.list.calculateFromAllLevels) then

						if v.object.value then
							valueTemp = v.object.value
						else
							valueTemp = 0	-- Avoids failures when encountering an item without a value
						end

						leveledItemTable[tableIndex] = { item = v.object, value = valueTemp, probability = nil }
						tableIndex = tableIndex + 1

						if valueTemp > maxValue then
							maxValue = valueTemp
						end

						if valueTemp < minValue then
							minValue = valueTemp
						end
					end
				end

				local itemCount = #leveledItemTable
				if maxValue ~= minValue then				-- If all items in the list have the same value, then math.remap would have problems and the probabilities should have the vanilla distribution anyways
					local effectFactor = 2					-- Increases or decreases the strength of the effect

					local evenChance = 1 / itemCount
					local probabilitySum = 0
					local numerator = effectFactor * evenChance * effectiveMagnitude
					local offset = evenChance * (1 - effectiveMagnitude / 2)
					for _,v in ipairs(leveledItemTable) do
						v.value = math.remap(v.value, minValue, maxValue, 0, 1)
						v.probability = (numerator / (1 + math.pow(2.7182818284, (-8 * v.value) + 4))) + offset	-- Sigmoid function that yields vanilla's unweighted probability distribution when effectiveMagnitude = 0;
						probabilitySum = probabilitySum + v.probability
					end

					local selection = math.random() * probabilitySum	-- Effectively normalizes the sum of the weighted probabilities
					for _,v in ipairs(leveledItemTable) do
						selection = selection - v.probability
						if selection < 0 then
							e.pick = v.item
							return
						end
					end
				else
					e.pick = leveledItemTable[math.random(itemCount)].item	-- Vanilla selection; it still needs to be done in this function if maxValue == minValue to account for the different chanceForNothing
				end
			end
		end
	end
end

---@param e tes3magicEffectTickEventData
local function wabbajackHelperEffect(e)
	if (not e:trigger()) then
		return
	end

	if e.effectInstance.state < tes3.spellState.ending then
		e.sourceInstance.sourceEffects[e.effectIndex + 1].duration = e.effectInstance.target.data.tamrielData.wabbajack.duration
	else
		local target = e.effectInstance.target
		for ref in tes3.getCell({ id = "T_Wabbajack" }):iterateReferences({ tes3.objectType.npc, tes3.objectType.creature }) do		-- This can cause a crash when the effect is removed from multiple actors at once, as references are being removed from the cell while being iterated through. A crash also occurs with tes3.getReference and this effect should not normally end on multiple actors though.
			if target.data.tamrielData.wabbajack.targetID == ref.id then
				local transformedHealth = target.mobile.health.normalized
				local transformedFatigue = target.mobile.fatigue.normalized
				local transformedMagicka = target.mobile.magicka.normalized

				local vfx = tes3.createVisualEffect({ object = "T_VFX_Wabbajack", lifespan = 1.5, reference = ref })
				tes3.playSound{ sound = "alteration hit", reference = ref }

				tes3.positionCell({ reference = ref, position = target.position, orientation = target.orientation, cell = target.cell })

				if target.mobile.isDead or target.mobile.health.current <= 1 then
					tes3.decrementKillCount({ actor = target.baseObject })
					ref.mobile:kill()
					if target.baseObject.faction then tes3.triggerCrime({ type = tes3.crimeType.killing, victim = ref.baseObject.faction }) end	-- Ensures that the player will be expelled for killing a faction member
					tes3.triggerCrime({ type = tes3.crimeType.killing, victim = ref.baseObject })
					tes3.incrementKillCount({ actor = ref.baseObject })
				else
					ref.mobile.health.current = ref.mobile.health.base * transformedHealth
					ref.mobile.fatigue.current = ref.mobile.fatigue.base * transformedFatigue
					ref.mobile.magicka.current = ref.mobile.magicka.base * transformedMagicka
				end

				target:disable()	-- I would move the target to another cell, but that causes Morrowind to lock up. Disabling them after the rest of the function runs seems to work fine though

				return
			end
		end
	end
end

---@param e tes3magicEffectTickEventData
local function wabbajackEffect(e)
	if (not e:trigger()) then
		return
	end

	if e.effectInstance.state < tes3.spellState.ending then
		local target = e.effectInstance.target
		if target.isDead then
			e.effectInstance.state = tes3.spellState.retired
			return
		end

		if target.mobile.actorType == tes3.actorType.creature and not target.baseObject.walks and not target.baseObject.biped then
			e.effectInstance.state = tes3.spellState.retired
			restoreCharge(e.sourceInstance)
			return
		end

		if target.object.level < 30 then
			if not target.data.tamrielData or not target.data.tamrielData.wabbajack then
				target.data.tamrielData = target.data.tamrielData or {}

				local maxDuration = 16
				local minDuration = 4

				local effectiveLevel = 0
				if target.object.level > 5 then
					effectiveLevel = target.object.level - 5	-- The effect lasts for maxDuration for creatures of level 5 and below
				end

				local duration = maxDuration - ((maxDuration - minDuration) * (effectiveLevel / 24))

				local targetHealth = target.mobile.health.normalized
				local targetFatigue = target.mobile.fatigue.normalized
				local targetMagicka = target.mobile.magicka.normalized

				local transformCreature = tes3.getObject(wabbajackCreatures[math.random(#wabbajackCreatures)])

				local transformedTarget = tes3.createReference({ object = transformCreature, position = target.position, orientation = target.orientation, cell = target.cell })	-- Could this setup and the WabbajackTrans effect actually be done through a summon like the Corruption effect does?
				transformedTarget.data.tamrielData = transformedTarget.data.tamrielData or {}
				transformedTarget.data.tamrielData.wabbajack = {}
				transformedTarget.data.tamrielData.wabbajack.duration = duration
				transformedTarget.data.tamrielData.wabbajack.targetID = target.id
				transformedTarget.data.tamrielData.wabbajack.targetName = target.object.name
				transformedTarget.mobile.fight = 0	-- Without this guards will fight transformed NPCs

				local vfx = tes3.createVisualEffect({ object = "T_VFX_Wabbajack", lifespan = 1.5, reference = transformedTarget })
				tes3.playSound{ sound = "alteration hit", reference = transformedTarget }

				tes3.cast({ reference = e.sourceInstance.caster, spell = "T_Dae_Alt_UNI_WabbajackTrans", alwaysSucceeds = true, bypassResistances = true, instant = true, target = transformedTarget })
				tes3.positionCell({ reference = target, position = { 0, 0, -53.187 }, cell = "T_Wabbajack" })	-- All sorts of problems can arise from disabling a target within the effect event

				local transformedHealth = transformedTarget.mobile.health.base * targetHealth
				if transformedHealth <= 1 then transformedHealth = 2 end 	-- Ensures that an actor with low base health won't die if the target had a high base health and was badly wounded
				transformedTarget.mobile.health.current = transformedHealth
				transformedTarget.mobile.fatigue.current = transformedTarget.mobile.fatigue.base * targetFatigue
				transformedTarget.mobile.magicka.current = transformedTarget.mobile.magicka.base * targetMagicka

				transformedTarget.mobile:startCombat(e.sourceInstance.caster.mobile)
				e.sourceInstance.caster.mobile:startCombat(transformedTarget.mobile)	-- Is this actually needed?
			else
				tes3.playSound{ sound = "Spell Failure Alteration", reference = target }
				if target.data.tamrielData and target.data.tamrielData.wabbajack and target.data.tamrielData.wabbajack.targetName then tes3ui.showNotifyMenu(common.i18n("magic.wabbajackAlready", { target.data.tamrielData.wabbajack.targetName })) end
				restoreCharge(e.sourceInstance)
			end
		else
			tes3.playSound{ sound = "Spell Failure Alteration", reference = target }
			tes3ui.showNotifyMenu(common.i18n("magic.wabbajackFailure", { target.object.name }))
			restoreCharge(e.sourceInstance)
		end

		e.effectInstance.state = tes3.spellState.retired
	end
end

---@param e spellResistEventData
function this.radiantShieldSpellResist(e)
	local radiantShieldEffects
	if e.target.mobile then radiantShieldEffects = e.target.mobile:getActiveMagicEffects({ effect = tes3.effect.T_alteration_RadShield }) end	-- Sometimes e.target.mobile just doesn't exist

	-- Only resist hostile effects; 'not e.effect' is checked because the documentation says that e.effect "may not always be available" and I'd rather resist the odd positive effects than not resist harmful ones
	if radiantShieldEffects and #radiantShieldEffects > 0 and (not e.effect or e.effect.object.isHarmful) then
		for _,v in pairs(radiantShieldEffects) do
			e.resistedPercent = e.resistedPercent + v.magnitude
		end

		if e.resistedPercent > 100 then
			e.resistedPercent = 100		-- Prevents anomalous behavior from occuring when above 100%
		end
	end
end

---@param e magicEffectRemovedEventData
function this.radiantShieldBlindnessRemoved(e)
	if e.effect.id == tes3.effect.blind and e.source.name == common.i18n("magic.miscRadiantShieldBlindness") then
		local blindEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.blind })
		if #blindEffects > 0 then
			local blindingRadianceCount = 0
			for _,v in pairs(blindEffects) do
				if v.instance.source.name == common.i18n("magic.miscRadiantShieldBlindness") then blindingRadianceCount = blindingRadianceCount + 1 end	-- If another Blinding Radiance instance is still active, then the fader color should not be changed back
			end

			if blindingRadianceCount > 1 then return end	-- The effect source being removed is still counted above however
		end

		tes3.worldController.blindnessFader:setColor({ color = { 0, 0, 0 } })
	end
end

---@param e damagedEventData
function this.radiantShieldDamaged(e)
	if e.attacker and e.source == tes3.damageSource.attack and not e.projectile then
		local radiantShieldEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_alteration_RadShield })
		if #radiantShieldEffects > 0 then
			local totalMagnitude = 0
			for _,v in pairs(radiantShieldEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end

			tes3.applyMagicSource({ reference = e.attacker, name = common.i18n("magic.miscRadiantShieldBlindness"), effects = {{ id = tes3.effect.blind, duration = 1.5, min = totalMagnitude, max = totalMagnitude }} })
			tes3.worldController.blindnessFader:setColor({ color = { 1, 1, 1 } })
		end
	end
end

---@param e tes3magicEffectTickEventData
local function radiantShieldEffect(e)
	if (not e:trigger()) then
		return
	end

	if e.effectInstance.state < tes3.spellState.ending then
		e.sourceInstance.caster.mobile.shield = e.sourceInstance.caster.mobile.shield + e.effectInstance.magnitude
	else
		e.sourceInstance.caster.mobile.shield = e.sourceInstance.caster.mobile.shield - e.effectInstance.magnitude
	end
end

---@param cellTable table
---@param markerID string
function this.replaceInterventionMarkers(cellTable, markerID)
	for _,v in pairs(cellTable) do
		local xCoord, yCoord = unpack(v)
		local cell = tes3.getCell({ x = xCoord, y = yCoord })

		local vanillaMarker = nil
		for ref in cell:iterateReferences(tes3.objectType.static) do
			if ref.id == markerID then
				break
			elseif ref.id == "DivineMarker" then
				vanillaMarker = ref
			end
		end

		if vanillaMarker then
			tes3.createReference({ object = markerID, position = vanillaMarker.position, orientation = vanillaMarker.orientation })
			vanillaMarker:delete()
		end
	end
end

---@param e tes3magicEffectTickEventData
local function kynesInterventionEffect(e)
	if (not e:trigger()) then
		return
	end

	if not tes3.worldController.flagTeleportingDisabled then
		local caster = e.sourceInstance.caster
		local marker = tes3.findClosestExteriorReferenceOfObject({ object = "T_Aid_KyneInterventionMarker" })
		if marker then
			tes3.positionCell({ reference = caster, position = marker.position, orientation = marker.orientation, teleportCompanions = false })
		end
	else
		tes3ui.showNotifyMenu(tes3.findGMST(tes3.gmst.sTeleportDisabled).value)
	end

	e.effectInstance.state = tes3.spellState.retired
end

---@param e damagedEventData
function this.reflectDamageStun(e)
	if e.source == tes3.damageSource.attack and e.attacker then
		local reflectDamageEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_ReflectDmg })
		if #reflectDamageEffects > 0 then
			local magnitude = 1
			for _,v in pairs(reflectDamageEffects) do
				magnitude = magnitude * (1 - (v.magnitude / 100))
			end
			magnitude = 1 - magnitude
			local defenderStunned = e.mobile.isHitStunned or e.mobile.isKnockedDown

			if math.random() < magnitude then		-- Chance of preventing a hit stun or knockdown increases with the strength of the reflect damage effect(s)
				e.mobile:hitStun{ cancel = true }
				if defenderStunned then
					e.attacker:hitStun()
				end
			end
		end
	end
end

---@param reflectDamageEffects tes3activeMagicEffect[]
---@param damage number
---@return number, number
local function reflectDamageCalculate(reflectDamageEffects, damage)
	local percentMagnitude
	local reflectedDamage = 0
	for _,v in pairs(reflectDamageEffects) do -- This effect is multiplicative like Morrowind's reflect rather than additive like Oblivion's reflect damage
		percentMagnitude = v.magnitude / 100
		reflectedDamage = reflectedDamage + (damage * percentMagnitude)
		damage = damage * (1 - percentMagnitude)
	end

	if damage < 0 then
		damage = 0		-- Make sure that the effect can't heal the defender
	end

	return damage, reflectedDamage
end

---@param e damageEventData
function this.reflectDamageEffect(e)
	if e.attacker and e.source == tes3.damageSource.attack and e.damage > 0 then
		local reflectDamageEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_ReflectDmg })
		if #reflectDamageEffects > 0 then
			local damage, reflectedDamage = reflectDamageCalculate(reflectDamageEffects, e.damage)
			e.attacker:applyDamage({ damage = reflectedDamage, playerAttack = true })
			e.damage = damage
		end
	end
end

---@param e damageHandToHandEventData
function this.reflectDamageHHEffect(e)
	if e.attacker and e.source == tes3.damageSource.attack and e.fatigueDamage > 0 then
		local reflectDamageEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_ReflectDmg })
		if #reflectDamageEffects > 0 then
			local damage, reflectedDamage = reflectDamageCalculate(reflectDamageEffects, e.fatigueDamage)
			e.attacker:applyFatigueDamage(reflectedDamage, 0, false)
			e.fatigueDamage = damage
		end
	end
end

---@param e cellChangedEventData
function this.banishDaedraCleanup(e)
	if e.previousCell then
		local banished = false
		for ref in tes3.getCell({ id = "T_BanishTemp" }):iterateReferences(tes3.objectType.creature) do
			banished = true
			tes3.positionCell({ reference = ref, position = { 0, 0, 0 }, cell = "T_Banish" })	-- Move to another cell so that only recent banishments have to be iterated over every time that the cell is changed
			ref:disable()
		end

		if banished then	-- Only iterate through the statics if a daedra was actually banished
			for ref in e.previousCell:iterateReferences(tes3.objectType.static) do
				if ref.baseObject.id == "T_VFX_Empty" then ref:delete() end	-- Remove every trace of the effect
			end
		end
	end
end

---@param e containerClosedEventData
function this.deleteBanishDaedraContainer(e)
	if e.reference.baseObject.id == "T_Glb_BanishDae_Empty" and #e.reference.object.inventory == 0 then	-- isEmpty does not work here
		for light in e.reference.cell:iterateReferences(tes3.objectType.light, false) do
			if light.position.x == e.reference.position.x and light.position.y == e.reference.position.y and light.position.z == e.reference.position.z and light.baseObject.id == "T_Glb_BanishDae_Light" then
				light:delete()
				break
			end
		end

		e.reference:delete()
	end
end

---@param e tes3magicEffectTickEventData
local function banishDaedraEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target

	if target.object.type ~= tes3.creatureType.daedra or target.isDead or table.contains(target.mobile.friendlyActors, e.sourceInstance.caster.mobile) or (target.data.tamrielData and target.data.tamrielData.wabbajack) then
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	local magnitude = e.effectInstance.effectiveMagnitude
	local targetLevel = target.object.level
	local caster = e.sourceInstance.caster
	local uniqueItems = {}

	if magnitude >= (targetLevel / 2) + ((targetLevel / 2) * target.mobile.health.normalized) then
		for _,v in pairs(target.baseObject.inventory.items) do
			if v.object.objectType ~= tes3.objectType.leveledItem and v.object.objectType ~= tes3.objectType.ingredient then	-- Sometimes ingredients are added without being part of a list
				table.insert(uniqueItems, v.object)
			end
		end

		--target.mobile:startCombat(caster.mobile)
		--target.mobile:kill()
		target:setActionFlag(tes3.actionFlag.onDeath)
		tes3.incrementKillCount({ actor = target.object })
		local soundSource = tes3.createReference({ object = "T_VFX_Empty", position = target.position + tes3vector3.new(0, 0, target.mobile.height/2) , orientation = target.orientation, cell = target.cell })
		tes3.playSound{ sound = "mysticism hit", reference = soundSource }
		local vfx = tes3.createVisualEffect({ object = "T_VFX_Banish", lifespan = 1.5, position = target.position })

		local targetHandle = tes3.makeSafeObjectHandle(target)
		timer.delayOneFrame(function()
			timer.delayOneFrame(function()		-- Give MWScripts using onDeath time to run
				if not targetHandle or not targetHandle:valid() then
					return
				end

				local target = targetHandle:getObject()

				if #uniqueItems > 0 then	-- Don't bother if there is definitely not going to be loot
					local container = tes3.createReference({ object = "T_Glb_BanishDae_Empty", position = target.position + tes3vector3.new(0, 0, target.mobile.height) , orientation = target.orientation, cell = target.cell })
					for _,v in pairs(target.mobile.inventory) do
						if table.contains(uniqueItems, v.object) then
							tes3.transferItem({ from = target, to = container, item = v.object, count = 999, limitCapacity = false })	-- This setup can account for how Dregas Volar's items are given to the player, so that they don't end up with two of both
						end
					end

					if #container.object.inventory == 0 then	-- Just in case
						container:delete()
					else
						tes3.createReference({ object = "T_Glb_BanishDae_Light", position = target.position + tes3vector3.new(0, 0, target.mobile.height) , orientation = target.orientation, cell = target.cell })
					end
				end

				tes3.positionCell({ reference = target, position = { 0, 0, 0 }, cell = "T_BanishTemp" })	-- This has to be put after the item transfers for them to work, rather than before the delays where it really belongs
			end)
		end)
	else
		target.mobile:startCombat(caster.mobile)
		tes3ui.showNotifyMenu(common.i18n("magic.banishFailure", { target.object.name }))
	end

	e.effectInstance.state = tes3.spellState.retired
end

---@param door tes3reference
---@return boolean
local function passWallDoorCrime(door)
	local owner, requirement = tes3.getOwner({ reference = door })

	if owner then
		if owner.objectType == tes3.objectType.npc then
			if requirement and requirement.value ~= 0 then return false end
		elseif owner.objectType == tes3.objectType.faction then
			if owner.playerRank >= requirement then	return false end -- I guess that the game doesn't check whether the player is expelled
		end

		return true
	end

	return false
end

---@param targetPosition tes3vector3
---@param forward tes3vector3
---@param right tes3vector3
---@param up tes3vector3
---@param range number
---@return tes3vector3, number
local function passwallCalculate(targetPosition, forward, right, up, range)
	local nodeArr = tes3.mobilePlayer.cell.pathGrid.nodes
	local playerPosition = tes3.mobilePlayer.position

	local minDistance = 108

	local horizontalBound = (right * 200)
	local verticalBound = (up * 105)

	local startPosition = targetPosition + (forward * 20) - tes3vector3.new(0, 0, tes3.mobilePlayer.cameraHeight)	-- (forward * 20) is used to hopefully prevent teleporting inside the target; the last term brings the everything down to the surface that the player is on, which is where nodes should be
	local endPosition = startPosition + (forward * range)

	local minPoint = startPosition - horizontalBound - verticalBound
	local maxPoint = endPosition + horizontalBound + verticalBound

	local bestDistance = range
	local bestPosition = nil

	local checkedNodes = { }

	for _,node in pairs(nodeArr) do
		for _,connectedNode in pairs(node.connectedNodes) do
			if not (table.contains(checkedNodes, node) or table.contains(checkedNodes, connectedNode)) then			-- Only check each connection once
				if (startPosition:distance(node.position) <= range and startPosition:distance(connectedNode.position) <= range) or (endPosition:distance(node.position) <= range and endPosition:distance(connectedNode.position) <= range) then
					local increment = (connectedNode.position - node.position) / 15

					local prevStartDistance = nil
					local prevEndDistance = nil

					for i = 0, 15, 1 do					-- Check points along the path, with the 0th and 15th points being at the nodes themselves
						local incrementPosition = node.position + (increment * i)
						local startDistance = incrementPosition:distance(startPosition)
						local endDistance = incrementPosition:distance(endPosition)

						if prevStartDistance and prevEndDistance and (startDistance > prevStartDistance and endDistance > prevEndDistance) then
							break		-- If incrementPosition is moving away or too far from the volume that the player can teleport within and was not inside of it then the loop will be broken out of for the sake of performance
						end

						if startDistance <= bestDistance and playerPosition:distance(incrementPosition) >= minDistance then
							if (minPoint.x <= incrementPosition.x and incrementPosition.x <= maxPoint.x) or (minPoint.x >= incrementPosition.x and incrementPosition.x >= maxPoint.x) then
								if (minPoint.y <= incrementPosition.y and incrementPosition.y <= maxPoint.y) or (minPoint.y >= incrementPosition.y and incrementPosition.y >= maxPoint.y) then
									if (minPoint.z <= incrementPosition.z and incrementPosition.z <= maxPoint.z) or (minPoint.z >= incrementPosition.z and incrementPosition.z >= maxPoint.z) then
										bestDistance = startDistance
										bestPosition = incrementPosition
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

		table.insert(checkedNodes, node)
	end

	return bestPosition, bestDistance
end

---@param e magicCastedEventData
function this.passwallEffect(e)
	for _,v in pairs(e.source.effects) do
		if v.id == tes3.effect.T_mysticism_Passwall then
			if tes3.mobilePlayer.cell.isOrBehavesAsExterior then
				tes3ui.showNotifyMenu(common.i18n("magic.passwallExterior"))
				return
			end

			if tes3.mobilePlayer.underwater then
				tes3ui.showNotifyMenu(common.i18n("magic.passwallUnderwater"))
				return
			end

			if tes3.worldController.flagTeleportingDisabled or tes3.worldController.flagLevitationDisabled then
				tes3ui.showNotifyMenu(common.i18n("magic.passwallDisabled"))
				return
			end

			if not tes3.mobilePlayer.cell.pathGrid then
				return
			end

			local castPosition = tes3.mobilePlayer.position + tes3vector3.new(0, 0, tes3.mobilePlayer.cameraHeight)	-- The actual cast position is 0.7 * tes3.mobilePlayer.heightPosition, but cameraHeight is more intuitive and reliable
			local forward = (tes3.worldController.armCamera.cameraData.camera.worldDirection * tes3vector3.new(1, 1, 0)):normalized()	-- While disregarding the player looking up or down can be awkward, taking the z-component of the direction into consideration often causes all sorts of problems
			local right = tes3.worldController.armCamera.cameraData.camera.worldRight:normalized()
			local up = tes3vector3.new(0, 0, 1)

			local range = v.radius * 22.1
			local activationRange = tes3.findGMST(tes3.gmst.iMaxActivateDist).value
			local minimumViableRange = 160	-- If an unsuitable object or space exists within this distance in front of the player, then Passwall will fail to work at all

			local hitSound = "mysticism hit"
			local hitVFX = "VFX_MysticismHit"
			if passwallAlteration then
				hitSound = "alteration hit"
				hitVFX = "VFX_AlterationHit"
			end

			local checkMeshes = tes3.rayTest{
				position = castPosition,
				direction = forward,
				findAll = true,
				maxDistance = activationRange + range,
				ignore = { tes3.player },
				observeAppCullFlag = false,
			}

			local alphaDistance = math.huge
			local wardDistance = math.huge
			if checkMeshes then		-- This block of code looks through all of the objects that the effect can hit and finds the closest one that is a ward or has some transparency
				for _,detection in ipairs(checkMeshes) do
					if detection.reference and detection.reference ~= tes3.player then	-- The findAll parameter annoyingly does not obey the ignore parameter, hence the need for the second condition here
						if detection.reference.baseObject.id:find("T_Aid_PasswallWard_") or detection.reference.baseObject.id:find("T_Dae_Ward_") then	-- I considered changing reducing the distance if such an object is found, but just saving the object's distance allows for determining whether or not it is responsible for the effect failing
							wardDistance = detection.distance
							break
						else
							local type = detection.reference.baseObject.objectType
							if type == tes3.objectType.activator and common.hasAlpha(tes3.loadMesh(detection.reference.baseObject.mesh), false, true) then	-- This mesh is passed rather than the rayTest's object because the latter is taken from the sceneGraph, which can cause problems
								alphaDistance = detection.distance
								break
							end
						end
					end
				end
			else
				return	-- If the rayTest doesn't find anything without culling, then it won't find anything with it either
			end

			if alphaDistance < minimumViableRange then	-- These conditions should handle casting the effect on or near an unacceptable object
				tes3ui.showNotifyMenu(common.i18n("magic.passwallAlpha"))
				return
			elseif wardDistance < minimumViableRange then
				tes3ui.showNotifyMenu(common.i18n("magic.passwallWard"))
				return
			end

			local possibleTargets = tes3.rayTest{
				position = castPosition,
				direction = forward,
				findAll = true,
				maxDistance = activationRange,
				ignore = { tes3.player },
				observeAppCullFlag = true,
			}

			if possibleTargets then
				for _,target in ipairs(checkMeshes) do
					local targetReference = target.reference
					if targetReference and targetReference ~= tes3.player then

						if targetReference.baseObject.objectType == tes3.objectType.static or targetReference.baseObject.objectType == tes3.objectType.activator then
							for _,id in pairs(passWallObjectBlacklist) do
								if targetReference.baseObject.id:find(id) then return end
							end

							local boxPoint1 = target.object.worldTransform.rotation * targetReference.baseObject.boundingBox.min
							local boxPoint2 = target.object.worldTransform.rotation * targetReference.baseObject.boundingBox.max

							if boxPoint2:heightDifference(boxPoint1) * targetReference.scale >= 168 then		-- Check how tall the targeted object is; this is Passwall, not Passtable
								local bestPosition, bestDistance = passwallCalculate(target.intersection, forward, right, up, range)

								if bestPosition then
									if bestDistance >= alphaDistance then	-- These conditions will notify the player if the closest node was through or inside an unacceptable mesh
										tes3ui.showNotifyMenu(common.i18n("magic.passwallAlpha"))
										return
									elseif bestDistance >= wardDistance then
										tes3ui.showNotifyMenu(common.i18n("magic.passwallWard"))
										return
									end

									tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
									local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
									tes3.mobilePlayer.position = bestPosition
								end

								return
							elseif math.abs(boxPoint2.x - boxPoint1.x) * targetReference.scale > 64 or math.abs(boxPoint2.y - boxPoint1.y) * targetReference.scale > 64 or boxPoint2:heightDifference(boxPoint1) * targetReference.scale > 64 then
								return	-- If the static/activator is neither tall enough to be valid nor small enough to be ignored, then it is still the actual target of Passwall and the function stops looking for targets past it
							end
						elseif targetReference.baseObject.objectType == tes3.objectType.door then
							for _,id in pairs(passWallDoorBlacklist) do
								if targetReference.baseObject.id:find(id) then return end
							end

							if not targetReference.destination then
								local bestPosition, bestDistance = passwallCalculate(target.intersection, forward, right, up, range)
								if bestPosition then
									if bestDistance >= alphaDistance then
											tes3ui.showNotifyMenu(common.i18n("magic.passwallAlpha"))
											return
									elseif bestDistance >= wardDistance then
											tes3ui.showNotifyMenu(common.i18n("magic.passwallWard"))
											return
									end

									if passWallDoorCrime(targetReference) then tes3.triggerCrime({ type = tes3.crimeType.trespass }) end
									tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }
									local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
									tes3.mobilePlayer.position = bestPosition
								end
							elseif targetReference.destination and not targetReference.destination.cell.isOrBehavesAsExterior then
								if targetReference.baseObject.script then
									tes3ui.showNotifyMenu(common.i18n("magic.passwallAlpha"))
									return
								end

								if passWallDoorCrime(targetReference) then tes3.triggerCrime({ type = tes3.crimeType.trespass }) end
								tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }
								local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
								tes3.positionCell({ cell = targetReference.destination.cell, position = targetReference.destination.marker.position, orientation = targetReference.destination.marker.orientation, teleportCompanions = false })
							else
								tes3ui.showNotifyMenu(common.i18n("magic.passwallDoorExterior"))
							end

							return	-- Passwall should not keep looking for targets through doors regardless of whether it is a valid door
						elseif targetReference.baseObject.objectType == tes3.objectType.creature or targetReference.baseObject.objectType == tes3.objectType.npc then
							return	-- Passwall should not allow teleportation through actors
						end
					end
				end
			end
		end
	end
end

-- Adds new magic effects based on the tables above
event.register(tes3.event.magicEffectsResolved, function()
	if config.summoningSpells then
		local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

		for _,v in pairs(magicData.td_summon_effects) do
			local effectID, effectName, creatureID, effectCost, iconPath, effectDescription = unpack(v)
			tes3.addMagicEffect{
				id = tes3.effect[effectID],
				name = common.i18n("magic." .. effectName),
				description = common.i18n("magic." .. effectDescription),
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
				lighting = {x = summonHungerEffect.lightingRed / 255, y = summonHungerEffect.lightingGreen / 255, z = summonHungerEffect.lightingBlue / 255},
				size = summonHungerEffect.size,
				sizeCap = summonHungerEffect.sizeCap,
				onTick = function(eventData)
					eventData:triggerSummon(creatureID)
				end,
				onCollision = nil
			}
		end
	end

	if config.boundSpells then
		local boundCuirassEffect = tes3.getMagicEffect(tes3.effect.boundBoots)

		for _,v in pairs(magicData.td_bound_effects) do
			local effectID, effectName, itemID, itemID_02, effectCost, iconPath, effectDescription = unpack(v)
			if itemID_02 == "" then
				itemID_02 = nil
			end
			local onTick
			if effectID == "T_bound_ThrowingKnives" then
				onTick = boundKnivesEffect
			else
				onTick = function(eventData)
					if tes3.getObject(itemID).objectType == tes3.objectType.armor then
						eventData:triggerBoundArmor(itemID, itemID_02)
					elseif tes3.getObject(itemID).objectType == tes3.objectType.weapon then
						eventData:triggerBoundWeapon(itemID)
					end
				end
			end
			tes3.addMagicEffect{
				id = tes3.effect[effectID],
				name = common.i18n("magic." .. effectName),
				description = common.i18n("magic." .. effectDescription),
				school = tes3.magicSchool.conjuration,
				baseCost = effectCost,
				speed = boundCuirassEffect.speed,
				allowEnchanting = true,
				allowSpellmaking = true,
				appliesOnce = boundCuirassEffect.appliesOnce,
				canCastSelf = true,
				canCastTarget = false,
				canCastTouch = false,
				casterLinked = boundCuirassEffect.casterLinked,
				hasContinuousVFX = boundCuirassEffect.hasContinuousVFX,
				hasNoDuration = boundCuirassEffect.hasNoDuration,
				hasNoMagnitude = boundCuirassEffect.hasNoMagnitude,
				illegalDaedra = boundCuirassEffect.illegalDaedra,
				isHarmful = boundCuirassEffect.isHarmful,
				nonRecastable = boundCuirassEffect.nonRecastable,
				targetsAttributes = boundCuirassEffect.targetsAttributes,
				targetsSkills = boundCuirassEffect.targetsSkills,
				unreflectable = boundCuirassEffect.unreflectable,
				usesNegativeLighting = boundCuirassEffect.usesNegativeLighting,
				icon = iconPath,
				particleTexture = boundCuirassEffect.particleTexture,
				castSound = boundCuirassEffect.castSoundEffect.id,
				castVFX = boundCuirassEffect.castVisualEffect.id,
				boltSound = boundCuirassEffect.boltSoundEffect.id,
				boltVFX = boundCuirassEffect.boltVisualEffect.id,
				hitSound = boundCuirassEffect.hitSoundEffect.id,
				hitVFX = boundCuirassEffect.hitVisualEffect.id,
				areaSound = boundCuirassEffect.areaSoundEffect.id,
				areaVFX = boundCuirassEffect.areaVisualEffect.id,
				lighting = {x = boundCuirassEffect.lightingRed / 255, y = boundCuirassEffect.lightingGreen / 255, z = boundCuirassEffect.lightingBlue / 255},
				size = boundCuirassEffect.size,
				sizeCap = boundCuirassEffect.sizeCap,
				onTick = onTick,
				onCollision = nil
			}
		end
	end

	if config.interventionSpells then
		local divineInterventionEffect = tes3.getMagicEffect(tes3.effect.divineIntervention)

		local effectID, effectName, effectCost, iconPath, effectDescription = unpack(magicData.td_intervention_effects[1])	-- Kyne's Intervention
		tes3.addMagicEffect{
			id = tes3.effect[effectID],
			name = common.i18n("magic." .. effectName),
			description = common.i18n("magic." .. effectDescription),
			school = tes3.magicSchool.mysticism,
			baseCost = effectCost,
			speed = divineInterventionEffect.speed,
			allowEnchanting = divineInterventionEffect.allowEnchanting,
			allowSpellmaking = divineInterventionEffect.allowSpellmaking,
			appliesOnce = divineInterventionEffect.appliesOnce,
			canCastSelf = divineInterventionEffect.canCastSelf,
			canCastTarget = divineInterventionEffect.canCastTarget,
			canCastTouch = divineInterventionEffect.canCastTouch,
			casterLinked = divineInterventionEffect.casterLinked,
			hasContinuousVFX = divineInterventionEffect.hasContinuousVFX,
			hasNoDuration = divineInterventionEffect.hasNoDuration,
			hasNoMagnitude = divineInterventionEffect.hasNoMagnitude,
			illegalDaedra = divineInterventionEffect.illegalDaedra,
			isHarmful = divineInterventionEffect.isHarmful,
			nonRecastable = divineInterventionEffect.nonRecastable,
			targetsAttributes = divineInterventionEffect.targetsAttributes,
			targetsSkills = divineInterventionEffect.targetsSkills,
			unreflectable = divineInterventionEffect.unreflectable,
			usesNegativeLighting = divineInterventionEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = divineInterventionEffect.particleTexture,
			castSound = divineInterventionEffect.castSoundEffect.id,
			castVFX = divineInterventionEffect.castVisualEffect.id,
			boltSound = divineInterventionEffect.boltSoundEffect.id,
			boltVFX = divineInterventionEffect.boltVisualEffect.id,
			hitSound = divineInterventionEffect.hitSoundEffect.id,
			hitVFX = divineInterventionEffect.hitVisualEffect.id,
			areaSound = divineInterventionEffect.areaSoundEffect.id,
			areaVFX = divineInterventionEffect.areaVisualEffect.id,
			lighting = {x = divineInterventionEffect.lightingRed / 255, y = divineInterventionEffect.lightingGreen / 255, z = divineInterventionEffect.lightingBlue / 255},
			size = divineInterventionEffect.size,
			sizeCap = divineInterventionEffect.sizeCap,
			onTick = kynesInterventionEffect,
			onCollision = nil
		}
	end

	if config.miscSpells then
		local passwallBaseEffect = tes3.getMagicEffect(tes3.effect.detectAnimal)

		if passwallAlteration then
			passwallBaseEffect = tes3.getMagicEffect(tes3.effect.levitate)
		end

		local shieldEffect = tes3.getMagicEffect(tes3.effect.shield)

		local function addMiscEffect(effectID, params, templateOverride)
			local effectName, effectCost, iconPath, effectDescription, templateId = unpack(magicData.td_misc_effects[effectID])
			params.id = tes3.effect[effectID]
			params.name = common.i18n("magic." .. effectName)
			params.description = common.i18n("magic." .. effectDescription)
			params.baseCost = effectCost
			if not params.icon then
				params.icon = iconPath
			end
			local template = templateOverride or tes3.getMagicEffect(tes3.effect[templateId])
			if template then
				for _, key in pairs({ "school", "speed", "casterLinked", "usesNegativeLighting", "particleTexture",
					"size", "sizeCap", "hasContinuousVFX", "illegalDaedra", "targetsAttributes", "targetsSkills",
					"allowEnchanting", "allowSpellmaking", "appliesOnce", "canCastSelf", "canCastTarget", "canCastTouch",
					"hasNoDuration", "hasNoMagnitude", "isHarmful", "nonRecastable", "unreflectable" }) do
					if params[key] == nil then
						params[key] = template[key]
					end
				end
				if not params.lighting then
					params.lighting = {x = template.lightingRed / 255, y = template.lightingGreen / 255, z = template.lightingBlue / 255}
				end
				for key1, key2 in pairs({ boltSound = "boltSoundEffect", boltVFX = "boltVisualEffect", hitSound = "hitSoundEffect",
					hitVFX = "hitVisualEffect", areaSound = "areaSoundEffect", areaVFX = "areaVisualEffect", castSound = "castSoundEffect",
					castVFX = "castVisualEffect" }) do
					if params[key1] == nil then
						params[key1] = template[key2].id
					end
				end
			end
			tes3.addMagicEffect(params)
		end

		addMiscEffect("T_mysticism_Passwall", {
			--magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,		-- Passwall is currently set up to not have a magnitude and works off of the effect's area instead
			--magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = false,
			canCastTouch = true,
			hasContinuousVFX = false,
			hasNoDuration = true,
			hasNoMagnitude = true,
			illegalDaedra = false,
			isHarmful = false,
			nonRecastable = true,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			icon = passwallIcon,
			boltSound = "T_SndObj_Silence",
			boltVFX = "T_VFX_Empty",
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",							-- Currently has to use VFX because otherwise Morrowind crashes when casting the effect on some actors despite this parameter being "optional"
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",							-- Problems can apparently still arise from missing boltVFX and areaVFX for some people
			onTick = function(eventData) eventData:trigger() end,
			onCollision = nil
		}, passwallBaseEffect)

		addMiscEffect("T_mysticism_BanishDae", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			hasNoDuration = true,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = true,
			unreflectable = true,
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",
			onTick = banishDaedraEffect,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_ReflectDmg", {
			magnitudeType = tes3.findGMST(tes3.gmst.spercent).value,
			magnitudeTypePlural = tes3.findGMST(tes3.gmst.spercent).value,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_DetHuman", {
			magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_alteration_RadShield", {
			hitVFX = "T_VFX_RadiantShieldHit",
			lighting = {x = 128, y = 128, z = 128},
			onTick = radiantShieldEffect,
			onCollision = nil
		})

		addMiscEffect("T_alteration_Wabbajack", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = false,
			hasNoDuration = true,
			hasNoMagnitude = true,
			isHarmful = true,
			nonRecastable = true,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",
			onTick = wabbajackEffect,
			onCollision = nil
		})

		addMiscEffect("T_alteration_WabbajackHelper", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			castSound = "T_SndObj_Silence",
			castVFX = "T_VFX_Empty",
			boltSound = "T_SndObj_Silence",
			boltVFX = "T_VFX_Empty",
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",
			onTick = wabbajackHelperEffect,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_Insight", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_restoration_ArmorResartus", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = true,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = armorResartusEffect,
			onCollision = nil
		})

		addMiscEffect("T_restoration_WeaponResartus", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = true,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = weaponResartusEffect,
			onCollision = nil
		})

		addMiscEffect("T_conjuration_Corruption", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = true,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			onTick = corruptionEffect,
			onCollision = nil
		})

		addMiscEffect("T_conjuration_CorruptionSummon", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			onTick = function(eventData)
				eventData:triggerSummon(corruptionActorID)
			end,
			onCollision = nil
		})

		addMiscEffect("T_illusion_DistractCreature", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,	-- The GUI for making custom magic effects doesn't like just having an effect only work at target range, so the distract spells also work at touch range for now
			canCastTouch = true,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			onTick = distractCreatureEffect,
			onCollision = nil
		})

		addMiscEffect("T_illusion_DistractHumanoid", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			onTick = distractHumanoidEffect,
			onCollision = nil
		})

		addMiscEffect("T_destruction_GazeOfVeloth", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			hasNoDuration = true,
			hasNoMagnitude = true,
			isHarmful = true,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			onTick = gazeOfVelothEffect,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_DetEnemy", {
			magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_DetInvisibility", {
			magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_Blink", {
			magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = true,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			hitSound = "T_SndObj_BlinkHit",
			hitVFX = "T_VFX_Empty",
			onTick = blinkEffect,
			onCollision = nil
		})

		addMiscEffect("T_restoration_FortifyCasting", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_illusion_PrismaticLight", {
			onTick = prismaticLightEffect,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_BloodMagic", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = false,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_conjuration_SanguineRose", {
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			onTick = function(eventData)
				eventData:triggerSummon(magicData.sanguineRoseDaedra[math.random(#magicData.sanguineRoseDaedra)])
			end,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_DetValuables", {
			magnitudeType = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			magnitudeTypePlural = " " .. tes3.findGMST(tes3.gmst.sfeet).value,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = false,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_mysticism_MagickaWard", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = false,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasContinuousVFX = shieldEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			hitVFX = shieldEffect.hitVisualEffect.id,
			lighting = {x = shieldEffect.lightingRed / 255, y = shieldEffect.lightingGreen / 255, z = shieldEffect.lightingBlue / 255},
			onTick = nil,
			onCollision = nil
		})

		addMiscEffect("T_illusion_Ethereal", {
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			hasNoDuration = false,
			hasNoMagnitude = true,
			isHarmful = false,
			nonRecastable = true,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			onTick = etherealEffect,
			onCollision = nil
		})
	end
end)

-- Replaces spell names, effects, etc. using the spell tables above; these operations needs to be done during the load event, rather than loaded like in main.lua
event.register(tes3.event.load, function()
	if config.summoningSpells then
		this.replaceSpells(magicData.td_summon_spells)
	end

	if config.boundSpells then
		this.replaceSpells(magicData.td_bound_spells)
	end

	if config.interventionSpells then
		this.replaceSpells(magicData.td_intervention_spells)
	end

	if config.miscSpells then
		this.replaceSpells(magicData.td_misc_spells)

		event.unregister(tes3.event.uiActivated, this.onMenuMagicActivated, { filter = "MenuMagic" })	-- unregisterOnLoad isn't an option here of course, as the registration needs to be done before loaded
		event.register(tes3.event.uiActivated, this.onMenuMagicActivated, { filter = "MenuMagic" })

		event.unregister(tes3.event.uiActivated, this.onMenuSpellmakingActivated, { filter = "MenuSpellmaking" })
		event.register(tes3.event.uiActivated, this.onMenuSpellmakingActivated, { filter = "MenuSpellmaking" })

		event.unregister(tes3.event.uiActivated, this.onMenuMultiActivated, { filter = "MenuMulti" })
		event.register(tes3.event.uiActivated, this.onMenuMultiActivated, { filter = "MenuMulti" })

		if config.blinkIndicator then
			blinkIndicator = tes3.loadMesh("td\\td_vfx_blink_indicator.nif")
    		blinkIndicator.appCulled = true
			blinkGround = tes3.loadMesh("td\\td_vfx_blink_ground.nif")
    		blinkGround.appCulled = true
		end
	end

	if config.summoningSpells and config.boundSpells and config.interventionSpells and config.miscSpells then
		this.replaceEnchantments(magicData.td_enchantments)
		this.replaceIngredientEffects(magicData.td_ingredients)
		this.replacePotions(magicData.td_potions)
		this.editItems(magicData.td_enchanted_items)

		tes3.getObject("T_Dae_UNI_Wabbajack").enchantment = tes3.getObject("T_Use_WabbajackUni")	-- Crashes game when registered to the loaded event with the wabbajack enchantment equipped, so it is here instead
	end
end)

return this