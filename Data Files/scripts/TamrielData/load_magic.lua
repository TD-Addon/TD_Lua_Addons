local content = require('openmw.content')
local core = require('openmw.core')

local summonTemplates = {
    automaton = 'summoncenturionsphere',
    creature = 'summonbear',
    daedra = 'summonhunger',
    undead = 'summonancestralghost'
}

local summonEffects = {
    T_summon_Devourer = { 52, 'td\\s\\td_s_summ_dev.dds', 'daedra' },
    T_summon_DremArch = { 33, 'td\\s\\td_s_sum_drm_arch.dds', 'daedra' },
    T_summon_DremCast = { 31, 'td\\s\\td_s_sum_drm_mage.dds', 'daedra' },
    T_summon_Guardian = { 69, 'td\\s\\td_s_sum_guard.dds', 'daedra' },
    T_summon_LesserClfr = { 19, 'td\\s\\td_s_sum_lsr_clan.dds', 'daedra' },
    T_summon_Ogrim = { 33, 'td\\s\\td_s_summ_ogrim.dds', 'daedra' },
    T_summon_Seducer = { 52, 'td\\s\\td_s_summ_sed.dds', 'daedra' },
    T_summon_SeducerDark = { 75, 'td\\s\\td_s_summ_d_sed.dds', 'daedra' },
    T_summon_Vermai = { 29, 'td\\s\\td_s_summ_vermai.dds', 'daedra' },
    T_summon_AtroStormMon = { 60, 'td\\s\\td_s_sum_stm_monch.dds', 'daedra' },
    T_summon_IceWraith = { 35, 'td\\s\\td_s_sum_ice_wrth.dds', 'undead' },
    T_summon_DweSpectre = { 17, 'td\\s\\td_s_sum_dwe_spctre.dds', 'undead' },
    T_summon_SteamCent = { 29, 'td\\s\\td_s_sum_dwe_cent.dds', 'automaton' },
    T_summon_SpiderCent = { 15, 'td\\s\\td_s_sum_dwe_spdr.dds', 'automaton' },
    T_summon_WelkyndSpirit = { 29, 'td\\s\\td_s_sum_welk_srt.dds', 'undead' },
    T_summon_Auroran = { 46, 'td\\s\\td_s_sum_auro.dds', 'daedra' },
    T_summon_Herne = { 18, 'td\\s\\td_s_sum_herne.dds', 'daedra' },
    T_summon_Morphoid = { 21, 'td\\s\\td_s_sum_morph.dds', 'daedra' },
    T_summon_Draugr = { 29, 'td\\s\\td_s_sum_draugr.dds', 'undead' },
    T_summon_Spriggan = { 48, 'td\\s\\td_s_sum_sprig.dds', 'creature' },
    T_summon_BoneldGr = { 71, 'td\\s\\td_s_sum_gtr_bnlrd.dds', 'undead' },
    T_summon_Ghost = { 7, 'td\\s\\td_s_summ_ghost.dds', 'undead' },
    T_summon_Wraith = { 49, 'td\\s\\td_s_summ_wraith.dds', 'undead' },
    T_summon_Barrowguard = { 11, 'td\\s\\td_s_summ_brwgurd.dds', 'undead' },
    T_summon_MinoBarrowguard = { 57, 'td\\s\\td_s_summ_mintur.dds', 'undead' },
    T_summon_SkeletonChampion = { 32, 'td\\s\\td_s_sum_skele_c.dds', 'undead' },
    T_summon_AtroFrostMon = { 47, 'td\\s\\td_s_sum_fst_monch.dds', 'daedra' },
    T_summon_SpiderDaedra = { 42, 'td\\s\\td_s_sum_spidr_dae.dds', 'daedra' },
}

local summonSpells = {
    T_Com_Cnj_SummonDevourer = { 156, 'T_summon_Devourer', 60 },
    T_Com_Cnj_SummonDremoraArcher = { 98, 'T_summon_DremArch', 60 },
    T_Com_Cnj_SummonDremoraCaster = { 93, 'T_summon_DremCast', 60 },
    T_Com_Cnj_SummonGuardian = { 155, 'T_summon_Guardian', 45 },
    T_Com_Cnj_SummonLesserClannfear = { 57, 'T_summon_LesserClfr', 60 },
    T_Com_Cnj_SummonOgrim = { 99, 'T_summon_Ogrim', 60 },
    T_Com_Cnj_SummonSeducer = { 156, 'T_summon_Seducer', 60 },
    T_Com_Cnj_SummonSeducerDark = { 169, 'T_summon_SeducerDark', 45 },
    T_Com_Cnj_SummonVermai = { 88, 'T_summon_Vermai', 60 },
    T_Com_Cnj_SummonStormMonarch = { 180, 'T_summon_AtroStormMon', 60 },
    T_Nor_Cnj_SummonIceWraith = { 105, 'T_summon_IceWraith', 60 },
    T_Dwe_Cnj_Uni_SummonDweSpectre = { 52, 'T_summon_DweSpectre', 60 },
    T_Dwe_Cnj_Uni_SummonSteamCent = { 88, 'T_summon_SteamCent', 60 },
    T_Dwe_Cnj_Uni_SummonSpiderCent = { 45, 'T_summon_SpiderCent', 60 },
    T_Ayl_Cnj_SummonWelkyndSpirit = { 78, 'T_summon_WelkyndSpirit', 60 },
    T_Com_Cnj_SummonAuroran = { 138, 'T_summon_Auroran', 60 },
    T_Com_Cnj_SummonHerne = { 54, 'T_summon_Herne', 60 },
    T_Com_Cnj_SummonMorphoid = { 63, 'T_summon_Morphoid', 60 },
    T_Nor_Cnj_SummonDraugr = { 78, 'T_summon_Draugr', 60 },
    T_Nor_Cnj_SummonSpriggan = { 144, 'T_summon_Spriggan', 60 },
    T_De_Cnj_SummonGreaterBonelord = { 160, 'T_summon_BoneldGr', 45 },
    T_Cr_Cnj_AylSorcKSummon1 = { 40, 'T_summon_Auroran', 40 },
    T_Cr_Cnj_AylSorcKSummon3 = { 25, 'T_summon_WelkyndSpirit', 40 },
    T_Cyr_Cnj_SummonWraith = { 147, 'T_summon_Wraith', 60 },
    T_Cyr_Cnj_SummonBarrowguard = { 33, 'T_summon_Barrowguard', 60 },
    T_Cyr_Cnj_SummonMinoBarrowguard = { 171, 'T_summon_MinoBarrowguard', 60 },
    T_Com_Cnj_SummonSkeletonChamp = { 96, 'T_summon_SkeletonChampion', 60 },
    T_Com_Cnj_SummonFrostMonarch = { 141, 'T_summon_AtroFrostMon', 60 },
    T_Com_Cnj_SummonSpiderDaedra = { 126, 'T_summon_SpiderDaedra', 60 },
}

local l10n = core.l10n('TamrielData')

local function addSummons()
    local effects = content.magicEffects.records
    for id, values in pairs(summonEffects) do
        local cost = values[1]
        local icon = values[2]
        local template = values[3]
        effects[id] = { template = effects[summonTemplates[template]], cost = cost, icon = icon, name = l10n('Magic_' .. id), description = l10n('Magic_' .. id .. 'Desc'), allowsSpellmaking = true, allowsEnchanting = true }
    end
    local spells = content.spells.records
    local type = content.spells.TYPE.Spell
    local range = content.RANGE.Self
    for id, values in pairs(summonSpells) do
        local cost = values[1]
        local effect = values[2]
        local duration = values[3]
        spells[id] = { cost = cost, type = type, isAutocalc = false, starterSpellFlag = false, name = l10n('Magic_' .. effect), effects = { { duration = duration, id = effect, range = range } } }
    end
end

return {
    engineHandlers = {
        onContentFilesLoaded = function()
            addSummons()
        end
    }
}
