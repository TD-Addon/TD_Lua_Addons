-- NB: This file will be shared between the MWSE and OpenMW implementations

local this = {}

-- item id, pickup sound id, putdown sound id, equip sound id
this.item_sounds = {
	["T_Imp_Subst_Blackdrake_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "T_SndObj_DrugSniff"},
	["T_De_Subst_Greydust_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "T_SndObj_DrugSniff"},
	["T_Nor_Subst_WasabiPaste_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "Swallow"},
	["T_Imp_Subst_Aegrotat_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "Swallow"},
	["T_De_Drink_PunavitResin_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "Swallow"},
	["T_Com_Subst_Perfume_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Com_Subst_Perfume_02"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Com_Subst_Perfume_03"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Com_Subst_Perfume_04"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Com_Subst_Perfume_05"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Com_Subst_Perfume_06"] = { up = "Item Potion Up", down = "Item Potion Down", use = "T_SndObj_SprayBottle"},
	["T_Imp_Subst_IndulcetPreserve_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Swallow"},
	["T_Imp_Subst_QuaestoVil_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Item Potion Down"},
	["T_Imp_Subst_QuaestoVil_02"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Item Potion Down"},
	["T_Imp_Subst_SiyatCigar_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "T_SndObj_CigarDrag"},
	["T_Imp_Subst_SloadOil_01"] = { up = "Item Misc Up", down = "Item Misc Down", use = "T_SndObj_Salve"},

	["T_IngSpice_OliveOil_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Drink"},
	["T_IngFood_Vinegar_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Drink"},
	["T_IngCrea_OrcBlood_01"] = { up = "Item Potion Up", down = "Item Potion Down", use = "Drink"},
	["T_IngFlor_Siyat_01"] = { use = "greneat"},
	["T_IngFood_Siyat_02"] = { use = "greneat"},

	["misc_dwrv_coin00"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["misc_dwrv_cursed_coin00"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Ayl_CoinBig_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Ayl_CoinGold_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Ayl_CoinSquare_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_He_DirenniCoin_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Imp_CoinAlessian_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Imp_CoinReman_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Nor_CoinBarrowCopper_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Nor_CoinBarrowIron_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_Nor_CoinBarrowSilver_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_De_HlaaluCompanyScrip_01"] = { up = "Item Gold Up", down = "Item Gold Down" },
	["T_De_HlaaluCompanyScrip_02"] = { up = "Item Gold Up", down = "Item Gold Down" },

	["T_EnSc_Ayl_Blessed"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_CavernsOfTruth"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_DaedricHerald1"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_DaedricHerald2"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_Destroyed"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_Enter"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_FoamingWave1"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_FoamingWave2"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_FromLight"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_GodlyPower1"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_GodlyPower2"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_LoreArmor1"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_LoreArmor2"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_Wisdom1"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
	["T_EnSc_Ayl_Wisdom2"] = { up = "Item Misc Up", down = "Item Misc Down", use = "scroll" },
}

-- sound id, relative frequency
local windCalm = {
	["wind calm1"] = 1,
	["wind calm2"] = 1,
	["wind calm3"] = 1,
	["wind calm4"] = 1,
	["wind calm5"] = 1,
}

local windDes = {
	["wind des1"] = 1,
	["wind des2"] = 1,
	["wind des3"] = 1,
	["wind des4"] = 1,
}

local windTrees = {
	["wind trees1"] = 1,
	["wind trees2"] = 1,
	["wind trees3"] = 1,
	["wind trees4"] = 1,
	["wind trees5"] = 1,
	["wind trees6"] = 1,
	["wind trees7"] = 1,
}

local windMountain = {
	["T_SndEnv_WindMountain_01"] = 1,
	["T_SndEnv_WindMountain_02"] = 1,
	["T_SndEnv_WindMountain_03"] = 1,
	["T_SndEnv_WindMountain_04"] = 1,
	["T_SndEnv_WindMountain_05"] = 1,
	["T_SndEnv_WindMountain_06"] = 1,
}

local reachBirdSounds = {
	["T_SndEnv_BirdsTemperate_01"] = 1,
	["T_SndEnv_BirdsTemperate_02"] = 1,
	["T_SndEnv_BirdsTemperate_03"] = 1,
	["T_SndEnv_BirdsTemperate_04"] = 1,
	["T_SndEnv_BirdsTemperate_05"] = 1,
	["T_SndEnv_BirdsTemperate_06"] = 1,
	["T_SndEnv_Birds_01_01"] = 1,
	["T_SndEnv_Birds_01_02"] = 1,
	["T_SndEnv_Birds_01_03"] = 1,
	["T_SndEnv_Birds_01_04"] = 1,
	["T_SndEnv_Birds_01_05"] = 1,
	["T_SndEnv_Birds_01_06"] = 1,
	["T_SndEnv_Birds_01_07"] = 1,
	["T_SndEnv_Birds_01_08"] = 1,
	["T_SndEnv_Birds_01_09"] = 1,
	["T_SndEnv_Birds_01_10"] = 1,
	["T_SndEnv_Birds_01_11"] = 1,
}

local stridBirdSounds = {
	["T_SndEnv_BirdsTropical_01"] = 1,
	["T_SndEnv_BirdsTropical_02"] = 1,
	["T_SndEnv_BirdsTropical_03"] = 1,
	["T_SndEnv_BirdsTropical_04"] = 1,
}

this.regionSounds = {
	["Lorchwuir Heath Region"] = { chanceNone = 0.71, soundLists =
		{
			{ sounds = windCalm, multiplier = 5 },
			{ sounds = windTrees, multiplier = 3,
				conditions = {
					{ type = "nearGround", parameter = 2048 },
				}
			},
			{ sounds = reachBirdSounds, multiplier = 4,
				conditions = {
					{ type = "isNight", isNot = true },
					{ type = "weatherIsThunder", isNot = true },
					{ type = "weatherIsSnow", isNot = true },
					{ type = "inCity", isNot = true },
					{ type = "nearGround", parameter = 2048 },
				}
			},
			{ sounds = { ["T_SndEnv_TemperateInsect_01"] = 30 },
				conditions = {
					{ type = "weatherIsRain", isNot = true },
					{ type = "weatherIsThunder", isNot = true },
					{ type = "weatherIsSnow", isNot = true },
					{ type = "nearGround", parameter = 2048 },
					{ type = "aboveHeight", isNot = true, parameter = 4096 },
				}
			},
			{ sounds = windMountain, multiplier = 5,
				conditions = {
					{ type = "aboveHeight", parameter = 20480 },
				}
			},
			{ sounds = { ["T_SndEnv_WindMountain_02"] = 3, ["T_SndEnv_WindMountain_03"] = 3 },
				conditions = {
					{ type = "aboveHeight", parameter = 4096 },
					{ type = "aboveHeight", isNot = true, parameter = 20480 },
				}
			},
		}
	},
	["Gold Coast Region"] = { chanceNone = 0.57, soundLists =
		{
			{ sounds = windCalm, multiplier = 4 },
			{ sounds = windTrees, multiplier = 5,
				conditions = {
					{ type = "nearGround", parameter = 2048 },
				}
			},
			{ sounds = stridBirdSounds, multiplier = 3,
				conditions = {
					{ type = "isNight", isNot = true },
					{ type = "weatherIsThunder", isNot = true },
					{ type = "weatherIsStorm", isNot = true },
					{ type = "inCity", isNot = true },
					{ type = "nearGround", parameter = 2048 },
				}
			},
			{ sounds = windMountain, multiplier = 5,
				conditions = {
					{ type = "aboveHeight", parameter = 20480 },
				}
			},
		}
	},
}

return this