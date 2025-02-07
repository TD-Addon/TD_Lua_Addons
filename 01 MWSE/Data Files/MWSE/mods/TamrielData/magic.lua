local this = {}

local common = require("tamrielData.common")
local config = require("tamrielData.config")

local wabbajackLock = false

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
local corruptionCasted = false

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
end

if config.boundSpells == true then
	tes3.claimSpellEffectId("T_bound_Greaves", 2111)
	tes3.claimSpellEffectId("T_bound_Waraxe", 2112)
	tes3.claimSpellEffectId("T_bound_Warhammer", 2113)
	tes3.claimSpellEffectId("T_bound_HammerResdayn", 2114)
	tes3.claimSpellEffectId("T_bound_RazorResdayn", 2115)
	tes3.claimSpellEffectId("T_bound_Pauldrons", 2116)
	--tes3.claimSpellEffectId("T_bound_ThrowingKnives", 2118)
end

if config.interventionSpells == true then
	tes3.claimSpellEffectId("T_intervention_Kyne", 2122)
end

if config.miscSpells == true then
	tes3.claimSpellEffectId("T_alteration_Passwall", 2106)
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
end

-- The effect costs for most summons were initially calculated by mort using a formula (dependent on a creature's health and soul) that is now lost and were then adjusted as seemed reasonable.
-- Calculations have provided a new formula: Effect Cost = (.16 * Health) + (.035 * Soul); most of the old values are in close agreement with the new formula and have thus been left unchanged.
-- effect id, effect name, creature id, effect mana cost, icon, effect description
local td_summon_effects = {
	{ tes3.effect.T_summon_Devourer, common.i18n("magic.summonDevourer"), "T_Dae_Cre_Devourer_01", 52, "td\\s\\td_s_summ_dev.dds", common.i18n("magic.summonDevourerDesc")},
	{ tes3.effect.T_summon_DremArch, common.i18n("magic.summonDremoraArcher"), "T_Dae_Cre_Drem_Arch_01", 33, "td\\s\\td_s_sum_drm_arch.dds", common.i18n("magic.summonDremoraArcherDesc")},
	{ tes3.effect.T_summon_DremCast, common.i18n("magic.summonDremoraCaster"), "T_Dae_Cre_Drem_Cast_01", 31, "td\\s\\td_s_sum_drm_mage.dds", common.i18n("magic.summonDremoraCasterDesc")},
	{ tes3.effect.T_summon_Guardian, common.i18n("magic.summonGuardian"), "T_Dae_Cre_Guardian_01", 69, "td\\s\\td_s_sum_guard.dds", common.i18n("magic.summonGuardianDesc")},
	{ tes3.effect.T_summon_LesserClfr, common.i18n("magic.summonLesserClannfear"), "T_Dae_Cre_LesserClfr_01", 19, "td\\s\\td_s_sum_lsr_clan.dds", common.i18n("magic.summonLesserClannfearDesc")},
	{ tes3.effect.T_summon_Ogrim, common.i18n("magic.summonOgrim"), "ogrim", 33, "td\\s\\td_s_summ_ogrim.dds", common.i18n("magic.summonOgrimDesc")},
	{ tes3.effect.T_summon_Seducer, common.i18n("magic.summonSeducer"), "T_Dae_Cre_Seduc_01", 52, "td\\s\\td_s_summ_sed.dds", common.i18n("magic.summonSeducerDesc")},
	{ tes3.effect.T_summon_SeducerDark, common.i18n("magic.summonSeducerDark"), "T_Dae_Cre_SeducDark_02", 75, "td\\s\\td_s_summ_d_sed.dds", common.i18n("magic.summonSeducerDarkDesc")},
	{ tes3.effect.T_summon_Vermai, common.i18n("magic.summonVermai"), "T_Dae_Cre_Verm_01", 29, "td\\s\\td_s_summ_vermai.dds", common.i18n("magic.summonVermaiDesc")},
	{ tes3.effect.T_summon_AtroStormMon, common.i18n("magic.summonStormMonarch"), "T_Dae_Cre_MonarchSt_01", 60, "td\\s\\td_s_sum_stm_monch.dds", common.i18n("magic.summonStormMonarchDesc")},
	{ tes3.effect.T_summon_IceWraith, common.i18n("magic.summonIceWraith"), "T_Sky_Cre_IceWr_01", 35, "td\\s\\td_s_sum_ice_wrth.dds", common.i18n("magic.summonIceWraithDesc")},
	{ tes3.effect.T_summon_DweSpectre, common.i18n("magic.summonDweSpectre"), "dwarven ghost", 17, "td\\s\\td_s_sum_dwe_spctre.dds", common.i18n("magic.summonDweSpectreDesc")},
	{ tes3.effect.T_summon_SteamCent, common.i18n("magic.summonSteamCent"), "centurion_steam", 29, "td\\s\\td_s_sum_dwe_cent.dds", common.i18n("magic.summonSteamCentDesc")},
	{ tes3.effect.T_summon_SpiderCent, common.i18n("magic.summonSpiderCent"), "centurion_spider", 15, "td\\s\\td_s_sum_dwe_spdr.dds", common.i18n("magic.summonSpiderCentDesc")},
	{ tes3.effect.T_summon_WelkyndSpirit, common.i18n("magic.summonWelkyndSpirit"), "T_Ayl_Cre_WelkSpr_01", 29, "td\\s\\td_s_sum_welk_srt.dds", common.i18n("magic.summonWelkyndSpiritDesc")},
	{ tes3.effect.T_summon_Auroran, common.i18n("magic.summonAuroran"), "T_Dae_Cre_Auroran_01", 44, "td\\s\\td_s_sum_auro.dds", common.i18n("magic.summonAuroranDesc")},
	{ tes3.effect.T_summon_Herne, common.i18n("magic.summonHerne"), "T_Dae_Cre_Herne_01", 18, "td\\s\\td_s_sum_herne.dds", common.i18n("magic.summonHerneDesc")},
	{ tes3.effect.T_summon_Morphoid, common.i18n("magic.summonMorphoid"), "T_Dae_Cre_Morphoid_01", 21, "td\\s\\td_s_sum_morph.dds", common.i18n("magic.summonMorphoidDesc")},
	{ tes3.effect.T_summon_Draugr, common.i18n("magic.summonDraugr"), "T_Sky_Und_Drgr_01", 29, "td\\s\\td_s_sum_draugr.dds", common.i18n("magic.summonDraugrDesc")},
	{ tes3.effect.T_summon_Spriggan, common.i18n("magic.summonSpriggan"), "T_Sky_Cre_Spriggan_01", 48, "td\\s\\td_s_sum_sprig.dds", common.i18n("magic.summonSprigganDesc")},
	{ tes3.effect.T_summon_BoneldGr, common.i18n("magic.summonGreaterBonelord"), "T_Mw_Und_BoneldGr_01", 71, "td\\s\\td_s_sum_gtr_bnlrd.dds", common.i18n("magic.summonGreaterBonelordDesc")},
	{ tes3.effect.T_summon_Ghost, common.i18n("magic.summonGhost"), "T_Cyr_Und_Ghst_01", 7, "td\\s\\td_s_summ_ghost.dds", common.i18n("magic.summonGhostDesc")},
	{ tes3.effect.T_summon_Wraith, common.i18n("magic.summonWraith"), "T_Cyr_Und_Wrth_01", 49, "td\\s\\td_s_summ_wraith.dds", common.i18n("magic.summonWraithDesc")},
	{ tes3.effect.T_summon_Barrowguard, common.i18n("magic.summonBarrowguard"), "T_Cyr_Und_Mum_01", 11, "td\\s\\td_s_summ_brwgurd.dds", common.i18n("magic.summonBarrowguardDesc")},
	{ tes3.effect.T_summon_MinoBarrowguard, common.i18n("magic.summonMinoBarrowguard"), "T_Cyr_Und_MinoBarrow_01", 57, "td\\s\\td_s_summ_mintur.dds", common.i18n("magic.summonMinoBarrowguardDesc")},
	{ tes3.effect.T_summon_SkeletonChampion, common.i18n("magic.summonSkeletonChampion"), "T_Glb_Und_SkelCmpGls_01", 32, "td\\s\\td_s_sum_skele_c.dds", common.i18n("magic.summonSkeletonChampionDesc")},
	{ tes3.effect.T_summon_AtroFrostMon, common.i18n("magic.summonFrostMonarch"), "T_Dae_Cre_MonarchFr_01", 47, "td\\s\\td_s_sum_fst_monch.dds", common.i18n("magic.summonFrostMonarchDesc")},
}

-- effect id, effect name, item id, 2nd item ID, effect mana cost, icon, effect description
local td_bound_effects = {
	{ tes3.effect.T_bound_Greaves, common.i18n("magic.boundGreaves"), "T_Com_Bound_Greaves_01", "", 2, "td\\s\\td_s_bnd_grves.dds", common.i18n("magic.boundGreavesDesc")},
	{ tes3.effect.T_bound_Waraxe, common.i18n("magic.boundWarAxe"), "T_Com_Bound_WarAxe_01", "", 2, "td\\s\\td_s_bnd_waxe.dds", common.i18n("magic.boundWarAxeDesc")},
	{ tes3.effect.T_bound_Warhammer, common.i18n("magic.boundWarhammer"), "T_Com_Bound_Warhammer_01", "", 2, "td\\s\\td_s_bnd_wham.dds", common.i18n("magic.boundWarhammerDesc")},
	{ tes3.effect.T_bound_HammerResdayn, "", "T_Com_Bound_Warhammer_01", "", 2, "td\\s\\td_s_bnd_res_ham.dds", ""},
	{ tes3.effect.T_bound_RazorResdayn, "", "bound_dagger", "", 2, "td\\s\\td_s_bnd_red_razor.dds", ""},
	{ tes3.effect.T_bound_Pauldrons, common.i18n("magic.boundPauldrons"), "T_Com_Bound_PauldronL_01", "T_Com_Bound_PauldronR_01", 2, "td\\s\\td_s_bnd_pldrn.dds", common.i18n("magic.boundPauldronsDesc")},
	--{ tes3.effect.T_bound_ThrowingKnives, common.i18n("magic.boundThrowingKnives"), "T_Com_Bound_ThrowingKnife_01", "", 2, "td\\s\\td_s_bnd_knives.dds", common.i18n("magic.boundThrowingKnivesDesc")},
}

-- effect id, effect name, effect mana cost, icon, effect description
local td_intervention_effects = {
	{ tes3.effect.T_intervention_Kyne, common.i18n("magic.interventionKyne"), 150, "td\\s\\td_s_int_kyne.tga", common.i18n("magic.interventionKyneDesc")},
}

-- effect id, effect name, effect mana cost, icon, effect description
local td_misc_effects = {
	{ tes3.effect.T_alteration_Passwall, common.i18n("magic.miscPasswall"), 750, "td\\s\\td_s_passwall.tga", common.i18n("magic.miscPasswallDesc")},
	{ tes3.effect.T_mysticism_BanishDae, common.i18n("magic.miscBanish"), 128, "td\\s\\td_s_ban_daedra.tga", common.i18n("magic.miscBanishDesc")},
	{ tes3.effect.T_mysticism_ReflectDmg, common.i18n("magic.miscReflectDamage"), 20, "td\\s\\td_s_ref_dam.tga", common.i18n("magic.miscReflectDamageDesc")},
	{ tes3.effect.T_mysticism_DetHuman, common.i18n("magic.miscDetectHumanoid"), 1.5, "td\\s\\td_s_det_hum.tga", common.i18n("magic.miscDetectHumanoidDesc")},
	{ tes3.effect.T_alteration_RadShield, common.i18n("magic.miscRadiantShield"), 5, "td\\s\\td_s_radiant_shield.tga", common.i18n("magic.miscRadiantShieldDesc")},
	{ tes3.effect.T_alteration_Wabbajack, common.i18n("magic.miscWabbajack"), 22, "td\\s\\td_s_wabbajack.tga", common.i18n("magic.miscWabbajackDesc")},
	{ tes3.effect.T_mysticism_Insight, common.i18n("magic.miscInsight"), 10, "td\\s\\td_s_insight.tga", common.i18n("magic.miscInsightDesc")},
	{ tes3.effect.T_restoration_ArmorResartus, common.i18n("magic.miscArmorResartus"), 60, "td\\s\\td_s_restore_ar.tga", common.i18n("magic.miscArmorResartusDesc")},
	{ tes3.effect.T_restoration_WeaponResartus, common.i18n("magic.miscWeaponResartus"), 120, "td\\s\\td_s_restore_wpn.tga", common.i18n("magic.miscWeaponResartusDesc")},
	{ tes3.effect.T_conjuration_Corruption, common.i18n("magic.miscCorruption"), 40, "td\\s\\td_s_skull_corr.tga", common.i18n("magic.miscCorruptionDesc")},
	{ tes3.effect.T_conjuration_CorruptionSummon, common.i18n("magic.miscCorruption"), 0, "td\\s\\td_s_skull_corr.tga", common.i18n("magic.miscCorruptionDesc")},
	{ tes3.effect.T_illusion_DistractCreature, common.i18n("magic.miscDistractCreature"), 0.5, "td\\s\\td_s_dist_cre.tga", common.i18n("magic.miscDistractCreatureDesc")},
	{ tes3.effect.T_illusion_DistractHumanoid, common.i18n("magic.miscDistractHumanoid"), 1, "td\\s\\td_s_dist_hum.tga", common.i18n("magic.miscDistractHumanoidDesc")},
}

-- spell id, cast type, spell name, spell mana cost, 1st effect id, 1st range type, 1st area, 1st duration, 1st minimum magnitude, 1st maximum magnitude, ...
local td_summon_spells = {
	{ "T_Com_Cnj_SummonDevourer", tes3.spellType.spell, common.i18n("magic.summonDevourer"), 156, tes3.effect.T_summon_Devourer, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonDremoraArcher", tes3.spellType.spell, common.i18n("magic.summonDremoraArcher"), 98, tes3.effect.T_summon_DremArch, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonDremoraCaster", tes3.spellType.spell, common.i18n("magic.summonDremoraCaster"), 93, tes3.effect.T_summon_DremCast, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonGuardian", tes3.spellType.spell, common.i18n("magic.summonGuardian"), 155, tes3.effect.T_summon_Guardian, tes3.effectRange.self, 0, 45, 1, 1 },
	{ "T_Com_Cnj_SummonLesserClannfear", tes3.spellType.spell, common.i18n("magic.summonLesserClannfear"), 57, tes3.effect.T_summon_LesserClfr, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonOgrim", tes3.spellType.spell, common.i18n("magic.summonOgrim"), 99, tes3.effect.T_summon_Ogrim, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonSeducer", tes3.spellType.spell, common.i18n("magic.summonSeducer"), 156, tes3.effect.T_summon_Seducer, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonSeducerDark", tes3.spellType.spell, common.i18n("magic.summonSeducerDark"), 169, tes3.effect.T_summon_SeducerDark, tes3.effectRange.self, 0, 45, 1, 1 },
	{ "T_Com_Cnj_SummonVermai", tes3.spellType.spell, common.i18n("magic.summonVermai"), 88, tes3.effect.T_summon_Vermai, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonStormMonarch", tes3.spellType.spell, common.i18n("magic.summonStormMonarch"), 180, tes3.effect.T_summon_AtroStormMon, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Nor_Cnj_SummonIceWraith", tes3.spellType.spell, common.i18n("magic.summonIceWraith"), 105, tes3.effect.T_summon_IceWraith, 60, 1, 1 },
	{ "T_Dwe_Cnj_Uni_SummonDweSpectre", tes3.spellType.spell, common.i18n("magic.summonDweSpectre"), 52, tes3.effect.T_summon_DweSpectre, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Dwe_Cnj_Uni_SummonSteamCent", tes3.spellType.spell, common.i18n("magic.summonSteamCent"), 88, tes3.effect.T_summon_SteamCent, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Dwe_Cnj_Uni_SummonSpiderCent", tes3.spellType.spell, common.i18n("magic.summonSpiderCent"), 45, tes3.effect.T_summon_SpiderCent, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Ayl_Cnj_SummonWelkyndSpirit", tes3.spellType.spell, common.i18n("magic.summonWelkyndSpirit"), 78, tes3.effect.T_summon_WelkyndSpirit, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonAuroran", tes3.spellType.spell, common.i18n("magic.summonAuroran"), 132, tes3.effect.T_summon_Auroran, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonHerne", tes3.spellType.spell, common.i18n("magic.summonHerne"), 54, tes3.effect.T_summon_Herne, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonMorphoid", tes3.spellType.spell, common.i18n("magic.summonMorphoid"), 63, tes3.effect.T_summon_Morphoid, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Nor_Cnj_SummonDraugr", tes3.spellType.spell, common.i18n("magic.summonDraugr"), 78, tes3.effect.T_summon_Draugr, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Nor_Cnj_SummonSpriggan", tes3.spellType.spell, common.i18n("magic.summonSpriggan"), 144, tes3.effect.T_summon_Spriggan, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_De_Cnj_SummonGreaterBonelord", tes3.spellType.spell, common.i18n("magic.summonGreaterBonelord"), 160, tes3.effect.T_summon_BoneldGr, tes3.effectRange.self, 0, 45, 1, 1 },
	{ "T_Cr_Cnj_AylSorcKSummon1", tes3.spellType.spell, nil, 40, tes3.effect.T_summon_Auroran, tes3.effectRange.self, 0, 40, 1, 1 },
	{ "T_Cr_Cnj_AylSorcKSummon3", tes3.spellType.spell, nil, 25, tes3.effect.T_summon_WelkyndSpirit, tes3.effectRange.self, 0, 40, 1, 1 },
	{ "T_Cyr_Cnj_SummonGhost", tes3.spellType.spell, common.i18n("magic.summonGhost"), 21, tes3.effect.T_summon_Ghost, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Cyr_Cnj_SummonWraith", tes3.spellType.spell, common.i18n("magic.summonWraith"), 147, tes3.effect.T_summon_Wraith, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Cyr_Cnj_SummonBarrowguard", tes3.spellType.spell, common.i18n("magic.summonBarrowguard"), 33, tes3.effect.T_summon_Barrowguard, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Cyr_Cnj_SummonMinoBarrowguard", tes3.spellType.spell, common.i18n("magic.summonMinoBarrowguard"), 171, tes3.effect.T_summon_MinoBarrowguard, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonSkeletonChamp", tes3.spellType.spell, common.i18n("magic.summonSkeletonChampion"), 96, tes3.effect.T_summon_SkeletonChampion, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_SummonFrostMonarch", tes3.spellType.spell, common.i18n("magic.summonFrostMonarch"), 141, tes3.effect.T_summon_AtroFrostMon, tes3.effectRange.self, 0, 60, 1, 1 },
}

-- spell id, cast type, spell name, spell mana cost, 1st effect id, 1st range type, 1st area, 1st duration, 1st minimum magnitude, 1st maximum magnitude, ...
local td_bound_spells = {
	{ "T_Com_Cnj_BoundGreaves", tes3.spellType.spell, common.i18n("magic.boundGreaves"), 6, tes3.effect.T_bound_Greaves, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_BoundWarAxe", tes3.spellType.spell, common.i18n("magic.boundWarAxe"), 6, tes3.effect.T_bound_Waraxe, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_BoundWarhammer", tes3.spellType.spell, common.i18n("magic.boundWarhammer"), 6, tes3.effect.T_bound_Warhammer, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_De_Cnj_Uni_BoundHammerResdayn", tes3.spellType.spell, nil, 6, tes3.effect.T_bound_HammerResdayn, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_De_Cnj_Uni_BoundRazorOResdayn", tes3.spellType.spell, nil, 6, tes3.effect.T_bound_RazorResdayn, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Com_Cnj_BoundPauldron", tes3.spellType.spell, common.i18n("magic.boundPauldrons"), 6, tes3.effect.T_bound_Pauldrons, tes3.effectRange.self, 0, 60, 1, 1 },
	--{ "T_Com_Cnj_BoundThrowingKnives", tes3.spellType.spell, common.i18n("magic.boundThrowingKnives"), 6, tes3.effect.T_bound_ThrowingKnives, tes3.effectRange.self, 0, 60, 1, 1 },
}

-- spell id, cast type, spell name, spell mana cost, 1st effect id, 1st range type, 1st area, 1st duration, 1st minimum magnitude, 1st maximum magnitude, ...
local td_intervention_spells = {
	{ "T_Nor_Mys_KynesIntervention", tes3.spellType.spell, common.i18n("magic.interventionKyne"), 8, tes3.effect.T_intervention_Kyne, tes3.effectRange.self, 0, 0, 1, 1 },
}

-- spell id, cast type, spell name, spell mana cost, 1st effect id, 1st range type, 1st area, 1st duration, 1st minimum magnitude, 1st maximum magnitude, ...
local td_misc_spells = {
	{ "T_Com_Mys_UNI_Passwall", tes3.spellType.spell, common.i18n("magic.miscPasswall"), 96, tes3.effect.T_alteration_Passwall, tes3.effectRange.touch, 25, 0, 0, 0 },
	{ "T_Com_Mys_BanishDaedra", tes3.spellType.spell, common.i18n("magic.miscBanish"), 64, tes3.effect.T_mysticism_BanishDae, tes3.effectRange.touch, 0, 0, 10, 10 },
	{ "T_Com_Mys_ReflectDamage", tes3.spellType.spell, common.i18n("magic.miscReflectDamage"), 76, tes3.effect.T_mysticism_ReflectDmg, tes3.effectRange.self, 0, 5, 10, 20 },
	{ "T_Com_Mys_DetectHumanoid", tes3.spellType.spell, common.i18n("magic.miscDetectHumanoid"), 38, tes3.effect.T_mysticism_DetHuman, tes3.effectRange.self, 0, 5, 50, 150 },
	{ "T_Ayl_Alt_RadiantShield", tes3.spellType.spell, common.i18n("magic.miscRadiantShield"), 75, tes3.effect.T_alteration_RadShield, tes3.effectRange.self, 0, 30, 10, 10 },
	{ "T_Cr_Alt_AuroranShield", tes3.spellType.ability, nil, nil, tes3.effect.T_alteration_RadShield, tes3.effectRange.self, 0, 30, 20, 20 },
	{ "T_Cr_Alt_AylSorcKLightShield", tes3.spellType.spell, common.i18n("magic.miscRadiantShield"), 10, tes3.effect.T_alteration_RadShield, tes3.effectRange.self, 0, 12, 10, 10, tes3.effect.light, tes3.effectRange.self, 0, 12, 20, 20 },
	{ "T_Com_Mys_Insight", tes3.spellType.spell, common.i18n("magic.miscInsight"), 76, tes3.effect.T_mysticism_Insight, tes3.effectRange.self, 0, 10, 15, 15 },
	{ "T_Com_Res_ArmorResartus", tes3.spellType.spell, common.i18n("magic.miscArmorResartus"), 90, tes3.effect.T_restoration_ArmorResartus, tes3.effectRange.self, 0, 0, 20, 40 },
	{ "T_Com_Res_WeaponResartus", tes3.spellType.spell, common.i18n("magic.miscWeaponResartus"), 90, tes3.effect.T_restoration_WeaponResartus, tes3.effectRange.self, 0, 0, 10, 20 },
	{ "T_Dae_Cnj_UNI_CorruptionSummon", tes3.spellType.spell, common.i18n("magic.miscCorruption"), 0, tes3.effect.T_conjuration_CorruptionSummon, tes3.effectRange.self, 0, 30, 1, 1 },
	{ "T_Com_Ilu_DistractCreature", tes3.spellType.spell, common.i18n("magic.miscDistractCreature"), 11, tes3.effect.T_illusion_DistractCreature, tes3.effectRange.target, 0, 15, 20, 20 },
	{ "T_Com_Ilu_DistractHumanoid", tes3.spellType.spell, common.i18n("magic.miscDistractHumanoid"), 22, tes3.effect.T_illusion_DistractHumanoid, tes3.effectRange.target, 0, 15, 20, 20 },
}

-- enchantment id, 1st effect id, 1st range type, 1st area, 1st duration, 1st minimum magnitude, 1st maximum magnitude, ...
local td_enchantments = {
	{ "T_Once_SummonDremoraArcher60", tes3.effect.T_summon_DremArch, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonDremoraCaster60", tes3.effect.T_summon_DremCast, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonGuardian60", tes3.effect.T_summon_Guardian, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonLesserClannfear60", tes3.effect.T_summon_LesserClfr, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonOgrim60", tes3.effect.T_summon_Ogrim, tes3.effectRange.self, 0, 60, 1, 1, nil },
	{ "T_Once_SummonOgrim120", tes3.effect.T_summon_Ogrim, tes3.effectRange.self, 0, 120, 1, 1, nil },
	{ "T_Once_SummonSeducer60", tes3.effect.T_summon_Seducer, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonSeducerDark60", tes3.effect.T_summon_SeducerDark, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonVermai60", tes3.effect.T_summon_Vermai, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonVermai120", tes3.effect.T_summon_Vermai, tes3.effectRange.self, 0, 120, 1, 1 },
	{ "T_Once_SummonSkeletonChamp120", tes3.effect.T_summon_SkeletonChampion, tes3.effectRange.self, 0, 120, 1, 1 },
	{ "T_Once_SummonFrostMonarch120", tes3.effect.T_summon_AtroFrostMon, tes3.effectRange.self, 0, 120, 1, 1 },
	{ "T_Once_SummonStormMonarch60", tes3.effect.T_summon_AtroStormMon, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonWelkyndSpirit60", tes3.effect.T_summon_WelkyndSpirit, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonAuroran60", tes3.effect.T_summon_Auroran, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonHerne60", tes3.effect.T_summon_Herne, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonMorphoid60", tes3.effect.T_summon_Morphoid, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_SummonBonelordGr60", tes3.effect.T_summon_BoneldGr, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Once_AylDaedricHerald1", tes3.effect.T_summon_WelkyndSpirit, tes3.effectRange.self, 0, 30, 1, 1 },
	{ "T_Once_AylDaedricHerald2", tes3.effect.T_summon_Auroran, tes3.effectRange.self, 0, 30, 1, 1 },
	{ "T_Once_AylLoreArmor1", tes3.effect.T_alteration_RadShield, tes3.effectRange.self, 0, 30, 20, 20 },
	{ "T_Once_KynesIntervention", tes3.effect.T_intervention_Kyne, tes3.effectRange.self, 0, 1, 1, 1 },
	{ "T_Once_QuelledGeas", tes3.effect.T_mysticism_BanishDae, tes3.effectRange.touch, 0, 1, 10, 15 },
	{ "T_Once_LordMhasFortress", tes3.effect.boundBoots, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.T_bound_Greaves, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.boundCuirass, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.T_bound_Pauldrons, tes3.effectRange.self, 0, 90, 1, 1,
								tes3.effect.boundGloves, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.boundHelm, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.boundShield, tes3.effectRange.self, 0, 90, 1, 1, tes3.effect.T_bound_Warhammer, tes3.effectRange.self, 0, 90, 1, 1 },
	{ "T_Once_SummonDremoraAll60", tes3.effect.summonDremora, tes3.effectRange.self, 0, 60, 1, 1, tes3.effect.T_summon_DremArch, tes3.effectRange.self, 0, 60, 1, 1, tes3.effect.T_summon_DremCast, tes3.effectRange.self, 0, 60, 1, 1 },
	{ "T_Const_Ring_Namira", tes3.effect.T_mysticism_ReflectDmg, tes3.effectRange.self, 0, 1, 30, 30, tes3.effect.reflect, tes3.effectRange.self, 0, 1, 30, 30 },
	{ "T_Const_FindersCharm", tes3.effect.T_mysticism_Insight, tes3.effectRange.self, 0, 1, 10, 10, tes3.effect.detectEnchantment, tes3.effectRange.self, 0, 1, 120, 120, tes3.effect.detectKey, tes3.effectRange.self, 0, 1, 120, 120 },
	{ "T_Const_Robe_Reprisal", tes3.effect.frostShield, tes3.effectRange.self, 0, 1, 50, 50, tes3.effect.T_mysticism_ReflectDmg, tes3.effectRange.self, 0, 1, 10, 10 },
	{ "T_Const_Onimaru_en", tes3.effect.fortifyAttack, tes3.effectRange.self, 0, 1, 10, 10, tes3.effect.resistMagicka, tes3.effectRange.self, 0, 1, 20, 20, tes3.effect.resistNormalWeapons, tes3.effectRange.self, 0, 1, 20, 20, tes3.effect.T_mysticism_ReflectDmg, tes3.effectRange.self, 0, 1, 20, 20, tes3.effect.summonDremora, tes3.effectRange.self, 0, 1, 1, 1 },
	{ "T_Const_NadiaInsight", tes3.effect.T_mysticism_Insight, tes3.effectRange.self, 0, 1, 30, 30 },
	--{ "T_Use_WabbajackUni", tes3.effect.T_alteration_Wabbajack, tes3.effectRange.target, 0, 1, 1, 1 },
	{ "T_Use_SkullOfCorruption", tes3.effect.T_conjuration_Corruption, tes3.effectRange.target, 0, 30, 1, 1 },	-- Why oh why is this ID not Uni?
}

-- ingredient id, 1st effect id, 1st effect attribute id, 1st effect skill id, 2nd effect id, ...
local td_ingredients = {
	{ "T_IngFlor_PBloomBulb_01", tes3.effect.poison, -1, -1,
								 tes3.effect.T_mysticism_ReflectDmg, -1, -1,
								 tes3.effect.damageFatigue, -1, -1,
								 tes3.effect.light, -1, -1, },
	{ "T_IngCrea_Eyestar_01", tes3.effect.nightEye, -1, -1,
							  tes3.effect.T_mysticism_Insight, -1, -1,
							  tes3.effect.weaknesstoMagicka, -1, -1,
							  tes3.effect.waterBreathing, -1, -1 },
	{ "T_IngCrea_EyestarDae_01", tes3.effect.nightEye, -1, -1,
								 tes3.effect.T_mysticism_Insight, -1, -1,
								 tes3.effect.weaknesstoMagicka, -1, -1,
								 tes3.effect.waterBreathing, -1, -1 },
	{ "T_IngCrea_BeetleShell_01", tes3.effect.fortifyAttribute, tes3.attribute.endurance, 0,
								  tes3.effect.T_mysticism_Insight, -1, -1 },
	{ "T_IngCrea_BeetleShell_04", tes3.effect.fortifyAttribute, tes3.attribute.endurance, 0,
								  tes3.effect.T_mysticism_ReflectDmg, -1, -1 },
	{ "T_IngMine_PearlBlue_01", tes3.effect.damageAttribute, tes3.attribute.intelligence, 0,
								tes3.effect.restoreMagicka, -1, -1,
								tes3.effect.T_mysticism_Insight, -1, -1,
								tes3.effect.fortifyMaximumMagicka, -1, -1 },
	{ "T_IngMine_PearlBlueDae_01", tes3.effect.damageAttribute, tes3.attribute.intelligence, 0,
								   tes3.effect.restoreMagicka, -1, -1,
								   tes3.effect.T_mysticism_Insight, -1, -1,
								   tes3.effect.fortifyMaximumMagicka, -1, -1 },
	{ "T_IngMine_DiamondRed_01", tes3.effect.drainAttribute, tes3.attribute.endurance, 0,
								 tes3.effect.invisibility, -1, -1,
								 tes3.effect.T_mysticism_ReflectDmg, -1, -1,
								 tes3.effect.resistFire, -1, -1 },
	{ "T_IngCrea_PrismaticDust_01", tes3.effect.light, -1, -1,
									tes3.effect.T_alteration_RadShield, -1, -1,
									tes3.effect.blind, -1, -1,
									tes3.effect.restoreMagicka, -1, -1 },
	{ "T_IngCrea_MothWingMw_02", tes3.effect.resistFire, -1, -1,
								 tes3.effect.drainAttribute, tes3.attribute.speed, 0,
								 tes3.effect.resistMagicka, -1, -1,
								 tes3.effect.T_mysticism_Insight, -1, -1 },
	--{ "T_IngMine_Agate_01", tes3.effect.reflect, -1, -1,
	--						tes3.effect.T_alteration_RadShield, -1, -1,			-- I keep going back and forth on this
	--						tes3.effect.silence, -1, -1 }
}

-- item id, item name, effect id
local td_potions = {
	{ "T_Com_Potion_ReflectDamage_B", common.i18n("magic.itemPotionReflectDamageB"), tes3.effect.T_mysticism_ReflectDmg },
	{ "T_Com_Potion_ReflectDamage_C", common.i18n("magic.itemPotionReflectDamageC"), tes3.effect.T_mysticism_ReflectDmg },
	{ "T_Com_Potion_ReflectDamage_S", common.i18n("magic.itemPotionReflectDamageS"), tes3.effect.T_mysticism_ReflectDmg },
	{ "T_Com_Potion_ReflectDamage_Q", common.i18n("magic.itemPotionReflectDamageQ"), tes3.effect.T_mysticism_ReflectDmg },
	{ "T_Com_Potion_ReflectDamage_E", common.i18n("magic.itemPotionReflectDamageE"), tes3.effect.T_mysticism_ReflectDmg },
	{ "T_Com_Potion_Insight_B", common.i18n("magic.itemPotionInsightB"), tes3.effect.T_mysticism_Insight },
	{ "T_Com_Potion_Insight_C", common.i18n("magic.itemPotionInsightC"), tes3.effect.T_mysticism_Insight },
	{ "T_Com_Potion_Insight_S", common.i18n("magic.itemPotionInsightS"), tes3.effect.T_mysticism_Insight },
	{ "T_Com_Potion_Insight_Q", common.i18n("magic.itemPotionInsightQ"), tes3.effect.T_mysticism_Insight },
	{ "T_Com_Potion_Insight_E", common.i18n("magic.itemPotionInsightE"), tes3.effect.T_mysticism_Insight }
}

-- item id, item name, value
local td_enchanted_items = {
	{ "T_EnSc_Com_SummonDremoraArcher", common.i18n("magic.itemScSummonDremoraArcher"), 295 },
	{ "T_EnSc_Com_SummonDremoraCaster", common.i18n("magic.itemScSummonDremoraCaster"), 314 },
	{ "T_EnSc_Nor_KynesIntervention", common.i18n("magic.itemScKynesIntervention"), nil }
}

-- race name, female, distraction voice files, distraction end voice lines
local distractedVoiceLines = {
	{ "Argonian", false, { "vo\\a\\m\\Idl_AM001.mp3", "vo\\a\\m\\Hlo_AM056.mp3" }, { "vo\\a\\m\\Idl_AM008.mp3" } },
	{ "Argonian", true, { "vo\\a\\f\\Idl_AF007.mp3", "vo\\a\\f\\Idl_AF004.mp3" }, { "vo\\a\\f\\Idl_AF002.mp3" } },
	{ "Breton", false, { }, { } },
	{ "Breton", true, { "vo\\b\\f\\Idl_BF001.mp3", "vo\\b\\f\\Idl_BF005.mp3" }, { "vo\\b\\f\\Idl_BF003.mp3" } },
	{ "Dark Elf", false, { "vo\\d\\m\\Idl_DM006.mp3", "vo\\d\\m\\Idl_DM007.mp3" }, { "vo\\d\\m\\Idl_DM008.mp3" } },
	{ "Dark Elf", true, { "vo\\d\\f\\Idl_DF006.mp3" }, { "vo\\d\\f\\Idl_DF003.mp3" } },
	{ "High Elf", false, { "vo\\h\\m\\Hlo_HM056.mp3" }, { "vo\\i\\m\\Idl_HF007.mp3" } },
	{ "High Elf", true, { "vo\\h\\f\\Hlo_HF056.mp3" }, { "vo\\i\\f\\Idl_HF007.mp3" } },
	{ "Imperial", false, { "vo\\i\\m\\Idl_IM008.mp3", "vo\\i\\m\\Idl_IM003.mp3" }, { "vo\\i\\m\\Idl_IM005.mp3" } },
	{ "Imperial", true, { "vo\\i\\f\\Idl_IF001.mp3" }, { "vo\\i\\f\\Idl_IF009.mp3" } },
	{ "Khajiit", false, { "vo\\k\\m\\Idl_KM005.mp3", "vo\\k\\m\\Idl_KM006.mp3", "vo\\k\\m\\Idl_KM007.mp3" }, { "vo\\k\\m\\Idl_KM002.mp3", "vo\\k\\m\\Idl_KM003.mp3" } },	-- The main reason for using race names instead of IDs is to make the Khajiit easier, but that should change when/if certain forms get their own voicelines
	{ "Khajiit", true, { "vo\\k\\f\\Idl_KF005.mp3", "vo\\k\\f\\Idl_KF006.mp3", "vo\\k\\f\\Idl_KF007.mp3" }, { "vo\\k\\f\\Idl_KF002.mp3", "vo\\k\\f\\Idl_KF003.mp3" } },
	{ "Nord", false, { "vo\\n\\m\\Idl_NM001.mp3" }, { "vo\\n\\m\\Idl_NM009.mp3" } },
	{ "Nord", true, { "vo\\n\\f\\Idl_NF002.mp3", "vo\\n\\f\\Idl_NF004.mp3" }, { "vo\\n\\f\\Idl_NM008.mp3" } },
	{ "Orc", false, { "vo\\o\\m\\Idl_OM001.mp3", "vo\\o\\m\\Idl_OM002.mp3" }, { "vo\\o\\m\\Idl_OM004.mp3", "vo\\o\\m\\Idl_OM009.mp3" } },
	{ "Orc", true, { "vo\\o\\f\\Idl_OF009.mp3" }, { } },
	{ "Redguard", false, { }, { } },
	{ "Redguard", true, { "vo\\r\\f\\Idl_RF002.mp3", "vo\\r\\f\\Idl_RF008.mp3" }, { "vo\\r\\f\\Idl_RF003.mp3", "vo\\r\\f\\Idl_RF007.mp3" } },
	{ "Wood Elf", false, { "vo\\w\\m\\Idl_WM009.mp3" }, { "vo\\w\\m\\Idl_WM006.mp3", "vo\\w\\m\\Idl_WM007.mp3" } },
	{ "Wood Elf", true, { "vo\\w\\f\\Idl_WF006.mp3", "vo\\w\\f\\Idl_WF009.mp3" }, { "vo\\w\\f\\Idl_WF003.mp3", "vo\\w\\f\\Idl_WF007.mp3" } },
}

local distractedReferences = {}	-- Should probably decide on a consistent naming scheme for tables

---@param table table
function this.replaceSpells(table)
	for _,v in pairs(table) do
		local overridden_spell = tes3.getObject(v[1])
		if overridden_spell then
			overridden_spell.castType = v[2]
			if v[3] then overridden_spell.name = v[3] end
			if v[4] then overridden_spell.magickaCost = v[4] end
			for i = 1, 8, 1 do
				if not v[5 + (i - 1) * 6] then
					break	-- This condition exists so that the tables don't have to have dozens of fields if they have less than 8 effects
				end
				local effect = overridden_spell.effects[i]
				effect.id = v[5 + (i - 1) * 6]
				effect.rangeType = v[6 + (i - 1) * 6]
				effect.radius = v[7 + (i - 1) * 6]
				effect.duration = v[8 + (i - 1) * 6]
				effect.min = v[9 + (i - 1) * 6]
				effect.max = v[10 + (i - 1) * 6]
			end
		end
	end
end

---@param table table
function this.replaceEnchantments(table)
	for _,v in pairs(table) do
		local overridden_enchantment = tes3.getObject(v[1])
		if overridden_enchantment then
			for i = 1, 8, 1 do
				if not v[2 + (i - 1) * 6] then
					break
				end
				local effect = overridden_enchantment.effects[i]
				effect.id = v[2 + (i - 1) * 6]
				effect.rangeType = v[3 + (i - 1) * 6]
				effect.radius = v[4 + (i - 1) * 6]
				effect.duration = v[5 + (i - 1) * 6]
				effect.min = v[6 + (i - 1) * 6]
				effect.max = v[7 + (i - 1) * 6]
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
				if not v[2 + (i - 1) * 3] then
					break
				end
				ingredient.effects[i] = v[2 + (i - 1) * 3]
				ingredient.effectAttributeIds[i] = v[3 + (i - 1) * 3]
				ingredient.effectSkillIds[i] = v[4 + (i - 1) * 3]
			end
		end
	end
end

---@param table table
function this.replacePotions(table)
	for _,v in pairs(table) do
		local potion = tes3.getObject(v[1])
		if potion then
			potion.name = v[2]
			potion.effects[1].id = v[3]
		end
	end
end

---@param table table
function this.editItems(table)
	for _,v in pairs(table) do
		local overridden_item = tes3.getObject(v[1])
		if overridden_item then
			if v[2] then overridden_item.name = v[2] end
			if v[3] then overridden_item.value = v[3] end
		end
	end
end

---@param actor tes3mobileNPC
---@param table table
---@return table
local function checkActorSpells(actor, table)
	local customSpells = { }
	local customSpellIndex = 1
	for _,v in pairs(table) do
		if actor.object.spells:contains(v[1]) and actor.magicka.current > v[4] then
			customSpells[customSpellIndex] = { v[1], v[5] }
			customSpellIndex = customSpellIndex + 1
		end
	end

	return customSpells
end

---@param session tes3combatSession
---@param spells table
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
			customSpells = checkActorSpells(e.session.mobile, td_summon_spells)
	
			if customSpells then
				equipActorSpell(e.session, customSpells)
			end
		end

		--[[
		if not customSpells and config.boundSpells then
			customSpells = checkActorSpells(e.session.mobile, td_bound_spells)
	
			if customSpells then
				equipActorSpell(e.session, customSpells)
			end
		end
		]]
	--end
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

---@param e referenceDeactivatedEventData
function this.onDistractedReferenceDeactivated(e)
	distractedReferences[e.reference] = nil
end

---@param e cellChangedEventData
function this.distractCellChangedEffect(e)
	if e.previousCell then							-- Don't run when loading a game; all of this could be done in onDistractedReferenceActivated, but there would be no way to distinguish between loading a game and just changing the cell
		for ref in pairs(distractedReferences) do
			---@cast ref tes3reference
			if ref.cell == e.cell and ref.data.tamrielData and ref.data.tamrielData.distract then	-- As long as the game is not being loaded, the distract effects should not be present
				tes3.setAIWander({ reference = ref, range = ref.data.tamrielData.distract.distance, duration = ref.data.tamrielData.distract.duration, time = ref.data.tamrielData.distract.hour, idles = ref.data.tamrielData.distract.idles })
				ref.position = ref.data.tamrielData.distract.position
				if ref.data.tamrielData.distract.distance == 0 then ref.orientation = ref.data.tamrielData.distract.orientation end	-- Maybe get rid of this condition for cell changes?
				ref.data.tamrielData.distract = nil
				distractedReferences[ref] = nil
			end
		end
	end
end

---@param ref tes3reference
---@param isEnd boolean
local function playDistractedVoiceLine(ref, isEnd)
	for _,v in pairs(distractedVoiceLines) do
		local raceName, isFemale, voicesStart, voicesEnd = unpack(v)
		if ref.object.female == isFemale and ref.object.race.name == raceName then
			local voices
			if not isEnd then voices = voicesStart
			else voices = voicesEnd end

			if voices then
				local path = voices[math.random(#voices)]
				tes3.say({ reference = ref, soundPath = path })
			end

			return
		end
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
	ref.data.tamrielData = {}

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
			idles = { 60, 20, 10, 0, 0, 0, 0, 0 }
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
			idles = packageIdles
		}
	end
end

---@param e tes3magicEffectTickEventData
local function distractEffect(e)
	local target = e.effectInstance.target
	local range = e.effectInstance.magnitude * 22.1
	
	local activePackage = target.mobile.aiPlanner:getActivePackage()
	if not activePackage or activePackage.type < 1 then
		local distance
		local playerDistance
		local destination

		local bestDistance = 0
		local bestPlayerDistance = 0
		local bestDestination
		
		distractSavePackage(target, activePackage)
		if target.cell.isInterior then
			local nodeArr = target.cell.pathGrid.nodes
		
			for _,node in pairs(nodeArr) do
				if math.abs(node.position.z - target.position.z) < 384 then
					distance = target.position:distance(node.position)
					playerDistance = tes3.player.position:distance(node.position)
					
					if distance <= range and distance >= bestDistance and playerDistance > bestPlayerDistance then
						bestDistance = distance
						bestPlayerDistance = playerDistance
						bestDestination = node.position
					end
				end
			end
		else
			for rotation = 0, 342, 18 do
				local pathCollision = tes3.rayTest{	-- This is not a very rigorous check, but anything that works better would also be much more complicated, so this is it for now
					position = target.position + tes3vector3.new(0, 0, 0.25 * target.mobile.height),
					direction = target.orientation + tes3vector3.new(0, 0, rotation),
					maxDistance = range + target.mobile.boundSize2D.y / 2,
					root = {tes3.game.worldObjectRoot},
					ignore = {target},
				}

				if pathCollision and pathCollision.distance then distance = pathCollision.distance - target.mobile.boundSize2D.y / 2
				else distance = range end

				if distance >= bestDistance then
					destination = target.position + tes3vector3.new(math.sin(math.rad(rotation)) * range, math.cos(math.rad(rotation)) * range, 0)
					playerDistance = tes3.player.position:distance(destination)

					if playerDistance > bestPlayerDistance then
						bestDistance = distance
						bestPlayerDistance = playerDistance
						bestDestination = destination
					end
				end
			end
		end

		if bestDestination then
			if math.random() < 0.45 then playDistractedVoiceLine(target, false) end
			tes3.setAITravel({ reference = target, destination = bestDestination })
			distractedReferences[target] = true
		else  
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

	if not target or target.mobile.actorType ~= tes3.actorType.npc or target.mobile.isDead or target.mobile.inCombat or (target.data.tamrielData and target.data.tamrielData.distract) then
		e.effectInstance.state = tes3.spellState.retired	-- This condition seems to be hit when the effect expires
		return
	end
	
	if target.mobile.isPlayerDetected then
		tes3.triggerCrime({ type = tes3.crimeType.trespass })	-- trigger crime doesn't seem to be working for some reason
		e.effectInstance.state = tes3.spellState.retired
		return
	end
	
	distractEffect(e)
end

---@param e tes3magicEffectTickEventData
local function distractCreatureEffect(e)
	if (not e:trigger()) then
		return
	end

	local target = e.effectInstance.target	-- Level restriction? Tied to magnitude?

	if not target or target.mobile.actorType ~= tes3.actorType.creature or target.mobile.isDead or target.mobile.inCombat or (target.data.tamrielData and target.data.tamrielData.distract) then	-- Require player to sneak?
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	distractEffect(e)
end

-- Stop the player from talking to the summon and the summon from talking to the player (just in case)
---@param e activateEventData
function this.corruptionBlockActivation(e)
	if e.target.id == tes3.player.data.tamrielData.corruptionReferenceID or (e.activator.id == tes3.player.data.tamrielData.corruptionReferenceID and e.target == tes3.player) then return false end
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
	end
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

	if tes3.player.cell.isInterior then
		local mapPlayerMarker = mapPane:findChild("MenuMap_local_player")
		local multiPlayerMarker = multiPane.parent.parent:findChild("MenuMap_local_player")

		local northMarkerAngle = 0
		for ref in tes3.player.cell:iterateReferences({tes3.objectType.static}) do
			if ref.baseObject.id == "NorthMarker" then
				northMarkerAngle = ref.orientation.z
				break
			end
		end

		northMarkerCos = math.cos(northMarkerAngle)
		northMarkerSin = math.sin(northMarkerAngle)
		
		mapWidth = mapCell.width
		mapHeight = mapCell.height
		multiWidth = multiCell.width
		multiHeight = multiCell.height

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
		-- It seems as though this is not being updated exactly when it should be; exterior markers will move across cells as the player moves around.
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

---@param pane tes3uiElement
local function deleteHumanoidDetections(pane)
	for _,child in pairs (pane.children) do
		if child.name == "detHum" then child:destroy() end
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
local function createHumanoidDetections(pane, x, y)
	local detection = pane:createImage({ id = "detHum", path = "textures\\td\\td_detect_humanoid_icon.dds" })
	detection.positionX = x
	detection.positionY = y
	detection.absolutePosAlignX = -32668
	detection.absolutePosAlignY = -32668
	detection.width = 3
	detection.height = 3
end

--- @param e magicEffectRemovedEventData
function this.detectHumanoidTick(e)
	if e.reference and e.reference ~= tes3.player then return end	-- I would just use a filter, but that triggers a warning for some reason

	local mapMenu = tes3ui.findMenu("MenuMap")
	local multiMenu = tes3ui.findMenu("MenuMulti")
	local mapPane, multiPane

	if mapMenu then mapPane = mapMenu:findChild("MenuMap_pane") end
	if multiMenu then multiPane = multiMenu:findChild("MenuMap_pane") end

	if mapMenu and multiMenu then
		calculateMapValues(mapPane, multiPane)
	
		deleteHumanoidDetections(mapPane)
		deleteHumanoidDetections(multiPane)
	
		local detectHumanoidEffects = tes3.player.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_DetHuman })
		if #detectHumanoidEffects > 0 then
			local maxMagnitude = 0
			for _,v in pairs(detectHumanoidEffects) do
				if v.magnitude > maxMagnitude then maxMagnitude = v.magnitude end
			end
	
			for _,actor in pairs(tes3.findActorsInProximity({ reference = tes3.player, range = maxMagnitude * 22.1 })) do	-- This should probably be changed to a refrence manager like the dreugh and lamia get in behavior.lua 
				if actor.actorType == tes3.actorType.npc then
					local mapX, mapY, multiX, multiY
					if tes3.player.cell.isInterior then mapX, mapY, multiX, multiY = calcInteriorPos(actor.position)
					else mapX, mapY, multiX, multiY = calcExteriorPos(actor.position) end
	
					createHumanoidDetections(mapPane, mapX, mapY)
					createHumanoidDetections(multiPane, multiX, multiY)
				end
			end
		end
	end
end

---@param e leveledItemPickedEventData
function this.insightEffect(e)
	local insightEffects = tes3.player.mobile:getActiveMagicEffects({ effect = tes3.effect.T_mysticism_Insight })
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
					if v.levelRequired > maxLevel and v.levelRequired <= tes3.player.object.level  then
						maxLevel = v.levelRequired
					end
				end

				local leveledItemTable = { }
				local maxValue = 0
				local minValue = 2147483647
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

local function wabbajackChangeStats(target, transform)
	local normalizationFactor = target.mobile.health.normalized
	tes3.modStatistic({ reference = target, name = "health", base = transform.health, current = normalizationFactor * transform.health })
	--target.mobile.health.base = transform.health
	--target.mobile.health.current = normalizationFactor * transform.health

	normalizationFactor = target.mobile.magicka.normalized
	tes3.modStatistic({ reference = target, name = "magicka", base = transform.magicka, current = normalizationFactor * transform.magicka })

	normalizationFactor = target.mobile.fatigue.normalized
	tes3.modStatistic({ reference = target, name = "fatigue", base = transform.fatigue, current = normalizationFactor * transform.fatigue })
end

---@param e magicEffectRemovedEventData
function this.wabbajackRemovedEffect(e)
	if e.effect.id == tes3.effect.T_alteration_Wabbajack then
		mwse.log("Removed")
	end
end

---@param e spellTickEventData
function this.wabbajackAppliedEffect(e)
	if e.effectId == tes3.effect.T_alteration_Wabbajack then
		mwse.log(e.effectInstance.cumulativeMagnitude)
		if e.effectInstance.cumulativeMagnitude ~= -1 then
			if not wabbajackLock then	-- The need to disable/enable the target delays changing the effectInstance's cumulative magnitude field, which would allow for the effect to be applied twice were it not for this condition
				wabbajackLock = true
				e.effectInstance.cumulativeMagnitude = -1
				
				if e.target.mobile.object.mesh == e.target.baseObject.mesh then	-- e.target.mesh will normally just be ""; even worse is the fact that changing e.target.mesh also changes the mesh of e.target.object, which is a big problem
					mwse.log("Target")
					if e.target.baseObject.objectType == tes3.objectType.creature and not e.target.isDead then
						if e.target.object.level < 30 then
							local maxDuration = 15
							local effectiveLevel = 0
							if e.target.object.level > 5 then
								effectiveLevel = e.target.object.level - 5	-- The effect lasts for maxDuration for creatures of level 5 and below
							end
							
							e.effect.duration = maxDuration - ((maxDuration - 3) * (effectiveLevel / 24))	-- Effect will last between 3 and maxDuration seconds depending on the target's level
							mwse.log(e.effect.duration)
							local transformCreatures = { "BM_ice_troll", "scamp", "T_Glb_Cre_LandDreu_01", "T_Glb_Cre_TrollCave_03", "mudcrab", "T_Ham_Fau_Goat_01", "Rat" } -- "golden saint"
							local transformCreature = tes3.getObject(transformCreatures[math.random(#transformCreatures)])
							mwse.log(transformCreature.id)
				
							--e.target.mobile.object.walks = transformCreature.walks		-- These very important fields are only available on the reference's object, which will screw up other creatures of the same object; changes to MWSE itself are likely required
							--e.target.mobile.object.biped = transformCreature.biped
							--e.target.mobile.object.usesEquipment = transformCreature.usesEquipment
							--e.target.mesh = transformCreature.mesh				-- Right now MWSE keeps the mesh change applied to the reference even when loading another save before the effect was even applied; changing the creatureinstance mesh does nothing, perhaps it would prevent these problems if it worked?
							tes3.loadAnimation({ reference = e.target, file = transformCreature.mesh })
							wabbajackChangeStats(e.target, transformCreature)
							mwse.log("Transform")
						else
							tes3ui.showNotifyMenu(common.i18n("magic.wabbajackFailure", { e.target.object.name }))
						end
					end
				end
				
				wabbajackLock = false
			end
		end
	end
end

---@param e spellResistEventData
function this.radiantShieldSpellResistEffect(e)
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

---@param e damagedEventData
function this.radiantShieldDamagedEffect(e)
	if e.attacker and e.source == tes3.damageSource.attack and not e.projectile then
		local radiantShieldEffects = e.mobile:getActiveMagicEffects({ effect = tes3.effect.T_alteration_RadShield })
		if #radiantShieldEffects > 0 then
			local totalMagnitude = 0
			for _,v in pairs(radiantShieldEffects) do
				totalMagnitude = totalMagnitude + v.magnitude
			end
			
			tes3.applyMagicSource({ reference = e.attacker, name = "Radiant Shield", effects = {{ id = tes3.effect.blind, duration = 1.5, min = totalMagnitude, max = totalMagnitude }} })
		end
	end
end

---@param e magicEffectRemovedEventData
function this.radiantShieldRemovedEffect(e)
	if e.effect.id == tes3.effect.T_alteration_RadShield then
		e.mobile.shield = e.mobile.shield - e.effectInstance.magnitude
		e.effectInstance.cumulativeMagnitude = 0	-- The event *might* trigger when it shouldn't, so this ensures that the effect can be reapplied if that actually happens
	end
end

---@param e spellTickEventData
function this.radiantShieldAppliedEffect(e)
	if e.effectId == tes3.effect.T_alteration_RadShield then
		if e.effectInstance.cumulativeMagnitude ~= -1 and e.effectInstance.magnitude > 0 then	-- Just checking whether no time has passed since the effect began doesn't work, since the magnitude isn't actually calculated until after the first tick
			e.target.mobile.shield = e.target.mobile.shield + e.effectInstance.magnitude
			e.effectInstance.cumulativeMagnitude = -1	-- cumulativeMagnitude doesn't (shouldn't) do anything for custom effects, so here it is used to track whether the effect has been applied to the target's shield value
		end
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
		for light in e.reference.cell:iterateReferences(tes3.objectType.light) do
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

	if target.object.type ~= tes3.creatureType.daedra or target.isDead or table.contains(target.mobile.friendlyActors, e.sourceInstance.caster.mobile) then
		e.effectInstance.state = tes3.spellState.retired
		return
	end

	local magnitude = e.effectInstance.effectiveMagnitude
	local targetLevel = target.object.level
	local caster = e.sourceInstance.caster
	local uniqueItems = {}
	
	if magnitude >= (targetLevel / 2) + ((targetLevel / 2) * target.mobile.health.normalized) then
		for _,v in pairs(target.baseObject.inventory.items) do
			if v.object.objectType ~= tes3.objectType.leveledItem then	-- Also manually check some of the leveled lists to remove non-unique items that were put on the creature without being a leveled item?
				table.insert(uniqueItems, v.object)
			end
		end

		--target.mobile:startCombat(caster.mobile)
		--target.mobile:kill()
		target:setActionFlag(tes3.actionFlag.onDeath)
		tes3.setKillCount({ actor = target.object, count = tes3.getKillCount({ actor = target.object }) + 1 })
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

---@param node niNode
---@return boolean
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

---@param wallPosition tes3vector3
---@param forward tes3vector3
---@param right tes3vector3
---@param up tes3vector3
---@param unitRange number
---@return tes3vector3
local function passwallCalculate(wallPosition, forward, right, up, unitRange)
	local nodeArr = tes3.mobilePlayer.cell.pathGrid.nodes
	local playerPosition = tes3.mobilePlayer.position

	local minDistance = 108
	local forwardOffset = 0
	local rayTestOffset = 19

	local rightCoord = (right * 160)
	local upCoord = (up * 130)			-- Should this account for player height, which affects castPosition and wallPosition?
	local upOffset = (up * 25)			-- Not having an offset can allow the player to teleport to the floor above for some sets

	local startPosition = wallPosition + (forward * forwardOffset)
	local endPosition = wallPosition + (forward * (unitRange + forwardOffset))

	local point1 = startPosition - rightCoord - upCoord + upOffset
	local point2 = endPosition + rightCoord + upCoord - upOffset

	local bestDistance = unitRange
	local bestPosition = nil

	for _,node in pairs(nodeArr) do
		if (point1.x <= node.position.x and node.position.x <= point2.x) or (point1.x >= node.position.x and node.position.x >= point2.x) then
			if (point1.y <= node.position.y and node.position.y <= point2.y) or (point1.y >= node.position.y and node.position.y >= point2.y) then
				if (point1.z <= node.position.z and node.position.z <= point2.z) or (point1.z >= node.position.z and node.position.z >= point2.z) then
					local distance = startPosition:distance(node.position)
					if distance <= bestDistance and playerPosition:distance(node.position) >= minDistance then
						local targetY = tes3.rayTest{
							position = node.position - (forward * rayTestOffset) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
							direction = forward,
							maxDistance = rayTestOffset * 2,
							--root = {tes3.game.sceneGraphCollideString},
							useBackTriangles = true,
						}
						local targetX = tes3.rayTest{
							position = node.position - (right * rayTestOffset) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
							direction = right,
							maxDistance = rayTestOffset * 2,
							--root = {tes3.game.sceneGraphCollideString},
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
											position = incrementPosition - (forward * rayTestOffset) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
											direction = forward,
											maxDistance = rayTestOffset * 2,
											--root = {tes3.game.sceneGraphCollideString},	-- Does not actually have collision meshes
											useBackTriangles = true,
										}
										local targetX = tes3.rayTest{
											position = node.position - (right * rayTestOffset) + tes3vector3.new(0, 0, 0.5 * tes3.mobilePlayer.height),
											direction = right,
											maxDistance = rayTestOffset * 2,
											--root = {tes3.game.sceneGraphCollideString},
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

---@param e magicCastedEventData
function this.passwallEffect(e)
	for _,v in pairs(e.source.effects) do
		if v.id == tes3.effect.T_alteration_Passwall then
			if tes3.mobilePlayer.cell.isInterior and tes3.mobilePlayer.cell.pathGrid then
				if not tes3.mobilePlayer.underwater then
					if not tes3.worldController.flagTeleportingDisabled then
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
								if detection.reference and detection.reference.baseObject.id:find("T_Aid_PasswallWard_") then	-- Prevents teleporting through T_Aid_PasswallWard statics
									tes3ui.showNotifyMenu(common.i18n("magic.passwallWard"))
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
									else
										tes3ui.showNotifyMenu(common.i18n("magic.passwallAlpha"))
									end
								end
							elseif hitReference.baseObject.objectType == tes3.objectType.door and (hitReference.baseObject.name:lower():find("door") or hitReference.baseObject.name:lower():find("wooden gate") or hitReference.baseObject.name:lower():find("palace gates") or
									hitReference.baseObject.name:lower():find("stone gate") or hitReference.baseObject.name:lower():find("old iron gate")) and
									not (hitReference.baseObject.name:lower():find("trap") or hitReference.baseObject.name:lower():find("cell") or hitReference.baseObject.name:lower():find("tent")) then
								if not hitReference.destination then
									local bestPosition = passwallCalculate(wallPosition, forward, right, up, unitRange)
									if bestPosition then
										if hitReference.lockNode then tes3.triggerCrime({ type = tes3.crimeType.trespass }) end
										tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
										local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
										tes3.mobilePlayer.position = bestPosition
									end
								elseif hitReference.destination and hitReference.destination.cell.isInterior then
									if hitReference.lockNode then tes3.triggerCrime({ type = tes3.crimeType.trespass }) end
									tes3.playSound{ sound = hitSound, reference = tes3.mobilePlayer }		-- Since there isn't a target in the normal sense, the sound won't play without this
									local vfx = tes3.createVisualEffect({ object = hitVFX, lifespan = 2, avObject = tes3.player.sceneNode })
									tes3.positionCell({ cell = hitReference.destination.cell, position = hitReference.destination.marker.position, orientation = hitReference.destination.marker.orientation, teleportCompanions = false })
								else
									tes3ui.showNotifyMenu(common.i18n("magic.passwallDoorExterior"))
								end
							end
						end
					else
						tes3ui.showNotifyMenu(tes3.findGMST(tes3.gmst.sTeleportDisabled).value)
					end
				else
					tes3ui.showNotifyMenu(common.i18n("magic.passwallUnderwater"))
				end
			else
				tes3ui.showNotifyMenu(common.i18n("magic.passwallExterior"))
			end

			return
		end
	end
end

-- Adds new magic effects based on the tables above
event.register(tes3.event.magicEffectsResolved, function()
	if config.summoningSpells == true then
		local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

		for _,v in pairs(td_summon_effects) do
			local effectID, effectName, creatureID, effectCost, iconPath, effectDescription = unpack(v)
			tes3.addMagicEffect{
				id = effectID,
				name = effectName,
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
	
	if config.boundSpells == true then
		local boundCuirassEffect = tes3.getMagicEffect(tes3.effect.boundCuirass)

		for _,v in pairs(td_bound_effects) do
			local effectID, effectName, itemID, itemID_02, effectCost, iconPath, effectDescription = unpack(v)
			tes3.addMagicEffect{
				id = effectID,
				name = effectName,
				description = effectDescription,
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
				lighting = {x = boundCuirassEffect.lightingRed, y = boundCuirassEffect.lightingGreen, z = boundCuirassEffect.lightingBlue},
				size = boundCuirassEffect.size,
				sizeCap = boundCuirassEffect.sizeCap,
				onTick = function(eventData)
					if tes3.getObject(itemID).objectType == tes3.objectType.armor then
						if itemID_02 == "" then
							eventData:triggerBoundArmor(itemID)
						else
							eventData:triggerBoundArmor(itemID, itemID_02)
						end
					elseif tes3.getObject(itemID).objectType == tes3.objectType.weapon then
						eventData:triggerBoundWeapon(itemID)
					end
				end,
				onCollision = nil
			}
		end
	end
	
	if config.interventionSpells == true then
		local divineInterventionEffect = tes3.getMagicEffect(tes3.effect.divineIntervention)

		local effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_intervention_effects[1])	-- Kyne's Intervention
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
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
			lighting = {x = divineInterventionEffect.lightingRed, y = divineInterventionEffect.lightingGreen, z = divineInterventionEffect.lightingBlue},
			size = divineInterventionEffect.size,
			sizeCap = divineInterventionEffect.sizeCap,
			onTick = kynesInterventionEffect,
			onCollision = nil
		}
	end
	
	if config.miscSpells == true then
		local levitateEffect = tes3.getMagicEffect(tes3.effect.levitate)
		local soultrapEffect = tes3.getMagicEffect(tes3.effect.soultrap)
		local reflectEffect = tes3.getMagicEffect(tes3.effect.reflect)
		local detectEffect = tes3.getMagicEffect(tes3.effect.detectAnimal)
		local shieldEffect = tes3.getMagicEffect(tes3.effect.shield)
		local burdenEffect = tes3.getMagicEffect(tes3.effect.burden)
		local restoreEffect = tes3.getMagicEffect(tes3.effect.fortifyHealth)	-- The fortify VFX feels more appropriate for the resartus effects, but perhaps it should still be restoration?
		local summonDremoraEffect = tes3.getMagicEffect(tes3.effect.summonDremora)
		local blindEffect = tes3.getMagicEffect(tes3.effect.blind)

		local effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[1])	-- Passwall
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
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
			boltVFX = "T_VFX_Empty",
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",							-- Currently has to use VFX because otherwise Morrowind crashes when casting the effect on some actors despite this parameter being "optional"
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",							-- Problems can apparently still arise from missing boltVFX and areaVFX for some people
			lighting = {x = levitateEffect.lightingRed, y = levitateEffect.lightingGreen, z = levitateEffect.lightingBlue},
			size = levitateEffect.size,
			sizeCap = levitateEffect.sizeCap,
			onTick = function(eventData) eventData:trigger() end,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[2])		-- Banish Daedra
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.mysticism,
			baseCost = effectCost,
			speed = soultrapEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			casterLinked = soultrapEffect.casterLinked,
			hasContinuousVFX = soultrapEffect.hasContinuousVFX,
			hasNoDuration = true,
			hasNoMagnitude = false,
			illegalDaedra = soultrapEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = true,
			targetsAttributes = soultrapEffect.targetsAttributes,
			targetsSkills = soultrapEffect.targetsSkills,
			unreflectable = true,
			usesNegativeLighting = soultrapEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = soultrapEffect.particleTexture,
			castSound = soultrapEffect.castSoundEffect.id,
			castVFX = soultrapEffect.castVisualEffect.id,
			boltSound = soultrapEffect.boltSoundEffect.id,
			boltVFX = soultrapEffect.boltVisualEffect.id,
			hitSound = "T_SndObj_Silence",
			hitVFX = "T_VFX_Empty",
			areaSound = "T_SndObj_Silence",
			areaVFX = "T_VFX_Empty",
			lighting = {x = soultrapEffect.lightingRed, y = soultrapEffect.lightingGreen, z = soultrapEffect.lightingBlue},
			size = soultrapEffect.size,
			sizeCap = soultrapEffect.sizeCap,
			onTick = banishDaedraEffect,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[3])		-- Reflect Damage
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.mysticism,
			baseCost = effectCost,
			speed = reflectEffect.speed,
			allowEnchanting = reflectEffect.allowEnchanting,
			allowSpellmaking = reflectEffect.allowSpellmaking,
			appliesOnce = reflectEffect.appliesOnce,
			canCastSelf = reflectEffect.canCastSelf,
			canCastTarget = reflectEffect.canCastTarget,
			canCastTouch = reflectEffect.canCastTouch,
			casterLinked = reflectEffect.casterLinked,
			hasContinuousVFX = reflectEffect.hasContinuousVFX,
			hasNoDuration = reflectEffect.hasNoDuration,
			hasNoMagnitude = reflectEffect.hasNoMagnitude,
			illegalDaedra = reflectEffect.illegalDaedra,
			isHarmful = reflectEffect.isHarmful,
			nonRecastable = reflectEffect.nonRecastable,
			targetsAttributes = reflectEffect.targetsAttributes,
			targetsSkills = reflectEffect.targetsSkills,
			unreflectable = reflectEffect.unreflectable,
			usesNegativeLighting = reflectEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = reflectEffect.particleTexture,
			castSound = reflectEffect.castSoundEffect.id,
			castVFX = reflectEffect.castVisualEffect.id,
			boltSound = reflectEffect.boltSoundEffect.id,
			boltVFX = reflectEffect.boltVisualEffect.id,
			hitSound = reflectEffect.hitSoundEffect.id,
			hitVFX = reflectEffect.hitVisualEffect.id,
			areaSound = reflectEffect.areaSoundEffect.id,
			areaVFX = reflectEffect.areaVisualEffect.id,
			lighting = {x = reflectEffect.lightingRed, y = reflectEffect.lightingGreen, z = reflectEffect.lightingBlue},
			size = reflectEffect.size,
			sizeCap = reflectEffect.sizeCap,
			onTick = nil,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[4])		-- Detect Humanoid
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.mysticism,
			baseCost = effectCost,
			speed = detectEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = detectEffect.casterLinked,
			hasContinuousVFX = detectEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = false,
			illegalDaedra = detectEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			usesNegativeLighting = detectEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = detectEffect.particleTexture,
			castSound = detectEffect.castSoundEffect.id,
			castVFX = detectEffect.castVisualEffect.id,
			boltSound = detectEffect.boltSoundEffect.id,
			boltVFX = detectEffect.boltVisualEffect.id,
			hitSound = detectEffect.hitSoundEffect.id,
			hitVFX = detectEffect.hitVisualEffect.id,
			areaSound = detectEffect.areaSoundEffect.id,
			areaVFX = detectEffect.areaVisualEffect.id,
			lighting = {x = detectEffect.lightingRed, y = detectEffect.lightingGreen, z = detectEffect.lightingBlue},
			size = detectEffect.size,
			sizeCap = detectEffect.sizeCap,
			onTick = nil,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[5])		-- Radiant Shield
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.alteration,
			baseCost = effectCost,
			speed = shieldEffect.speed,
			allowEnchanting = shieldEffect.allowEnchanting,
			allowSpellmaking = shieldEffect.allowSpellmaking,
			appliesOnce = shieldEffect.appliesOnce,
			canCastSelf = shieldEffect.canCastSelf,
			canCastTarget = shieldEffect.canCastTarget,
			canCastTouch = shieldEffect.canCastTouch,
			casterLinked = shieldEffect.casterLinked,
			hasContinuousVFX = shieldEffect.hasContinuousVFX,
			hasNoDuration = shieldEffect.hasNoDuration,
			hasNoMagnitude = shieldEffect.hasNoMagnitude,
			illegalDaedra = shieldEffect.illegalDaedra,
			isHarmful = shieldEffect.isHarmful,
			nonRecastable = shieldEffect.nonRecastable,
			targetsAttributes = shieldEffect.targetsAttributes,
			targetsSkills = shieldEffect.targetsSkills,
			unreflectable = shieldEffect.unreflectable,
			usesNegativeLighting = shieldEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = shieldEffect.particleTexture,
			castSound = shieldEffect.castSoundEffect.id,
			castVFX = shieldEffect.castVisualEffect.id,
			boltSound = shieldEffect.boltSoundEffect.id,
			boltVFX = shieldEffect.boltVisualEffect.id,
			hitSound = shieldEffect.hitSoundEffect.id,
			hitVFX = "T_VFX_RadiantShieldHit",
			areaSound = shieldEffect.areaSoundEffect.id,
			areaVFX = shieldEffect.areaVisualEffect.id,
			lighting = {x = 128, y = 128, z = 128},
			size = shieldEffect.size,
			sizeCap = shieldEffect.sizeCap,
			onTick = nil,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[6])		-- Wabbajack
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.alteration,
			baseCost = effectCost,
			speed = burdenEffect.speed,
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = false,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = false,
			casterLinked = burdenEffect.casterLinked,
			hasContinuousVFX = burdenEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = true,
			illegalDaedra = burdenEffect.illegalDaedra,
			isHarmful = false,	-- Change to true after testing
			nonRecastable = true,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			usesNegativeLighting = burdenEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = burdenEffect.particleTexture,
			castSound = burdenEffect.castSoundEffect.id,
			castVFX = burdenEffect.castVisualEffect.id,
			boltSound = burdenEffect.boltSoundEffect.id,
			boltVFX = burdenEffect.boltVisualEffect.id,
			hitSound = burdenEffect.hitSoundEffect.id,
			hitVFX = burdenEffect.hitVisualEffect.id,
			areaSound = burdenEffect.areaSoundEffect.id,
			areaVFX = burdenEffect.areaVisualEffect.id,
			lighting = {x = burdenEffect.lightingRed, y = burdenEffect.lightingGreen, z = burdenEffect.lightingBlue},
			size = burdenEffect.size,
			sizeCap = burdenEffect.sizeCap,
			onTick = nil,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[7])		-- Insight
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.mysticism,
			baseCost = effectCost,
			speed = reflectEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = reflectEffect.casterLinked,
			hasContinuousVFX = reflectEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = false,
			illegalDaedra = reflectEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			usesNegativeLighting = reflectEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = reflectEffect.particleTexture,
			castSound = reflectEffect.castSoundEffect.id,
			castVFX = reflectEffect.castVisualEffect.id,
			boltSound = reflectEffect.boltSoundEffect.id,
			boltVFX = reflectEffect.boltVisualEffect.id,
			hitSound = reflectEffect.hitSoundEffect.id,
			hitVFX = reflectEffect.hitVisualEffect.id,
			areaSound = reflectEffect.areaSoundEffect.id,
			areaVFX = reflectEffect.areaVisualEffect.id,
			lighting = {x = reflectEffect.lightingRed, y = reflectEffect.lightingGreen, z = reflectEffect.lightingBlue},
			size = reflectEffect.size,
			sizeCap = reflectEffect.sizeCap,
			onTick = nil,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[8])		-- Armor Resartus
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.restoration,
			baseCost = effectCost,
			speed = restoreEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = restoreEffect.casterLinked,
			hasContinuousVFX = restoreEffect.hasContinuousVFX,
			hasNoDuration = true,
			hasNoMagnitude = false,
			illegalDaedra = restoreEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			usesNegativeLighting = restoreEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = restoreEffect.particleTexture,
			castSound = restoreEffect.castSoundEffect.id,
			castVFX = restoreEffect.castVisualEffect.id,
			boltSound = restoreEffect.boltSoundEffect.id,
			boltVFX = restoreEffect.boltVisualEffect.id,
			hitSound = restoreEffect.hitSoundEffect.id,
			hitVFX = restoreEffect.hitVisualEffect.id,
			areaSound = restoreEffect.areaSoundEffect.id,
			areaVFX = restoreEffect.areaVisualEffect.id,
			lighting = {x = restoreEffect.lightingRed, y = restoreEffect.lightingGreen, z = restoreEffect.lightingBlue},
			size = restoreEffect.size,
			sizeCap = restoreEffect.sizeCap,
			onTick = armorResartusEffect,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[9])		-- Weapon Resartus
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.restoration,
			baseCost = effectCost,
			speed = restoreEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = restoreEffect.casterLinked,
			hasContinuousVFX = restoreEffect.hasContinuousVFX,
			hasNoDuration = true,
			hasNoMagnitude = false,
			illegalDaedra = restoreEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = false,
			usesNegativeLighting = restoreEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = restoreEffect.particleTexture,
			castSound = restoreEffect.castSoundEffect.id,
			castVFX = restoreEffect.castVisualEffect.id,
			boltSound = restoreEffect.boltSoundEffect.id,
			boltVFX = restoreEffect.boltVisualEffect.id,
			hitSound = restoreEffect.hitSoundEffect.id,
			hitVFX = restoreEffect.hitVisualEffect.id,
			areaSound = restoreEffect.areaSoundEffect.id,
			areaVFX = restoreEffect.areaVisualEffect.id,
			lighting = {x = restoreEffect.lightingRed, y = restoreEffect.lightingGreen, z = restoreEffect.lightingBlue},
			size = restoreEffect.size,
			sizeCap = restoreEffect.sizeCap,
			onTick = weaponResartusEffect,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[10])		-- Corruption
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.conjuration,
			baseCost = effectCost,
			speed = summonDremoraEffect.speed,
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = false,
			casterLinked = summonDremoraEffect.casterLinked,
			hasContinuousVFX = summonDremoraEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = true,
			illegalDaedra = summonDremoraEffect.illegalDaedra,
			isHarmful = true,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			usesNegativeLighting = summonDremoraEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = summonDremoraEffect.particleTexture,
			castSound = summonDremoraEffect.castSoundEffect.id,
			castVFX = summonDremoraEffect.castVisualEffect.id,
			boltSound = summonDremoraEffect.boltSoundEffect.id,
			boltVFX = summonDremoraEffect.boltVisualEffect.id,
			hitSound = summonDremoraEffect.hitSoundEffect.id,
			hitVFX = summonDremoraEffect.hitVisualEffect.id,
			areaSound = summonDremoraEffect.areaSoundEffect.id,
			areaVFX = summonDremoraEffect.areaVisualEffect.id,
			lighting = {x = summonDremoraEffect.lightingRed, y = summonDremoraEffect.lightingGreen, z = summonDremoraEffect.lightingBlue},
			size = summonDremoraEffect.size,
			sizeCap = summonDremoraEffect.sizeCap,
			onTick = function(eventData)
				if (not eventData:trigger()) then
					return
				end
				
				if eventData.effectInstance.target.id ~= tes3.player.data.tamrielData.corruptionReferenceID then	-- Memory errors can be reported if the effect is applied to the summon and doing so is weird anyways
					corruptionActorID = eventData.effectInstance.target.baseObject.id
					corruptionCasted = true
					tes3.cast({ reference = eventData.sourceInstance.caster, spell = "T_Dae_Cnj_UNI_CorruptionSummon", alwaysSucceeds = true, bypassResistances = true, instant = true, target = eventData.sourceInstance.caster })
				end

				eventData.effectInstance.state = tes3.spellState.retired
			end,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[11])		-- Corruption Summon
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.conjuration,
			baseCost = effectCost,
			speed = summonDremoraEffect.speed,
			allowEnchanting = false,
			allowSpellmaking = false,
			appliesOnce = true,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = summonDremoraEffect.casterLinked,
			hasContinuousVFX = summonDremoraEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = true,
			illegalDaedra = summonDremoraEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = summonDremoraEffect.unreflectable,
			usesNegativeLighting = summonDremoraEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = summonDremoraEffect.particleTexture,
			castSound = summonDremoraEffect.castSoundEffect.id,
			castVFX = summonDremoraEffect.castVisualEffect.id,
			boltSound = summonDremoraEffect.boltSoundEffect.id,
			boltVFX = summonDremoraEffect.boltVisualEffect.id,
			hitSound = summonDremoraEffect.hitSoundEffect.id,
			hitVFX = summonDremoraEffect.hitVisualEffect.id,
			areaSound = summonDremoraEffect.areaSoundEffect.id,
			areaVFX = summonDremoraEffect.areaVisualEffect.id,
			lighting = {x = summonDremoraEffect.lightingRed, y = summonDremoraEffect.lightingGreen, z = summonDremoraEffect.lightingBlue},
			size = summonDremoraEffect.size,
			sizeCap = summonDremoraEffect.sizeCap,
			onTick = function(eventData)
				eventData:triggerSummon(corruptionActorID)
			end,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[12])		-- Distract Creature
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.illusion,
			baseCost = effectCost,
			speed = blindEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,	-- The GUI for making custom magic effects doesn't like just having an effect only work at target range, so the distract spells also work at touch range for now
			canCastTouch = true,
			casterLinked = blindEffect.casterLinked,
			hasContinuousVFX = blindEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = false,
			illegalDaedra = blindEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			usesNegativeLighting = blindEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = blindEffect.particleTexture,
			castSound = blindEffect.castSoundEffect.id,
			castVFX = blindEffect.castVisualEffect.id,
			boltSound = blindEffect.boltSoundEffect.id,
			boltVFX = blindEffect.boltVisualEffect.id,
			hitSound = blindEffect.hitSoundEffect.id,
			hitVFX = blindEffect.hitVisualEffect.id,
			areaSound = blindEffect.areaSoundEffect.id,
			areaVFX = blindEffect.areaVisualEffect.id,
			lighting = {x = blindEffect.lightingRed, y = blindEffect.lightingGreen, z = blindEffect.lightingBlue},
			size = blindEffect.size,
			sizeCap = blindEffect.sizeCap,
			onTick = distractCreatureEffect,
			onCollision = nil
		}

		effectID, effectName, effectCost, iconPath, effectDescription = unpack(td_misc_effects[13])		-- Distract Humanoid
		tes3.addMagicEffect{
			id = effectID,
			name = effectName,
			description = effectDescription,
			school = tes3.magicSchool.illusion,
			baseCost = effectCost,
			speed = blindEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = true,
			canCastSelf = false,
			canCastTarget = true,
			canCastTouch = true,
			casterLinked = blindEffect.casterLinked,
			hasContinuousVFX = blindEffect.hasContinuousVFX,
			hasNoDuration = false,
			hasNoMagnitude = false,
			illegalDaedra = blindEffect.illegalDaedra,
			isHarmful = false,
			nonRecastable = false,
			targetsAttributes = false,
			targetsSkills = false,
			unreflectable = true,
			usesNegativeLighting = blindEffect.usesNegativeLighting,
			icon = iconPath,
			particleTexture = blindEffect.particleTexture,
			castSound = blindEffect.castSoundEffect.id,
			castVFX = blindEffect.castVisualEffect.id,
			boltSound = blindEffect.boltSoundEffect.id,
			boltVFX = blindEffect.boltVisualEffect.id,
			hitSound = blindEffect.hitSoundEffect.id,
			hitVFX = blindEffect.hitVisualEffect.id,
			areaSound = blindEffect.areaSoundEffect.id,
			areaVFX = blindEffect.areaVisualEffect.id,
			lighting = {x = blindEffect.lightingRed, y = blindEffect.lightingGreen, z = blindEffect.lightingBlue},
			size = blindEffect.size,
			sizeCap = blindEffect.sizeCap,
			onTick = distractHumanoidEffect,
			onCollision = nil
		}
	end
end)

-- Replaces spell names, effects, etc. using the spell tables above
event.register(tes3.event.load, function()
	if config.summoningSpells == true then
		this.replaceSpells(td_summon_spells)
	end

	if config.boundSpells == true then
		this.replaceSpells(td_bound_spells)
	end
	
	if config.interventionSpells == true then
		this.replaceSpells(td_intervention_spells)
	end

	if config.miscSpells == true then
		this.replaceSpells(td_misc_spells)
	end

	if config.summoningSpells == true and config.boundSpells == true and config.interventionSpells == true and config.miscSpells == true then
		this.replaceEnchantments(td_enchantments)
		this.replaceIngredientEffects(td_ingredients)
		this.replacePotions(td_potions)
		this.editItems(td_enchanted_items)

		--tes3.getObject("T_Dae_UNI_Wabbajack").enchantment = tes3.getObject("T_Use_WabbajackUni")	-- Crashes game when registered to the loaded event with the wabbajack enchantment equipped
	end
	
	--tes3.updateMagicGUI( { reference = tes3.player } ) -- Not needed unless this function is registered to the loaded event
end)

return this