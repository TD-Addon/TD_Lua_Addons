--[[
Format for Mods:
- ID can be for any soundID, mesh filepath, or texture filepath. Must be lowercase (CSO accounts for this using ':lower()', but better to be safe).
- Land uses texture path, items use .nif path.
- Category hooks into the tables above, so the first value will be the name of the desired table, and the second the desired value within it.
    Anything getting added to ignoreList must have an empty category of: ""
    Anything getting added to corpseMapping must have a category of: "Body"
- Define your soundType so it's properly sorted, for instance 'soundType = land' to specify texture material type.
- Typically the only objects you need to add to the ignoreList are those with large bounding boxes that might be picked up instead of the terrain, such as the Vivec bridge banners.

ADDITIONALLY:
- As of 2.0, CSO covers magic sounds, including a framework for custom sounds per spell effect, including failure sounds (hardcoded in the CS).
- If you'd like custom spell effect sounds, simply follow the file structure in 'sound\CSO\effects\' for each spell ID you're working with.
- Spell IDs can be referenced here: https://mwse.github.io/MWSE/references/magic-effects/
--]]

if not tes3.isModActive("Tamriel_Data.esm") then return end

local cso = include("Character Sound Overhaul.interop")
event.register(tes3.event.initialized, function()
    if cso then
        local soundData = {
            -- Land, Carpet:
            --{ id = "oaab\\ab_rug_small_06", category = cso.landTypes.carpet, soundType = "land" },
	    	--{ id = "oaab\\canvaswrapseamless", category = cso.landTypes.carpet, soundType = "land" },
	    	--{ id = "oaab\\canvaswrap_dk", category = cso.landTypes.carpet, soundType = "land" },
            --{ id = "oaab\\fabric_burgundy_01", category = cso.landTypes.carpet, soundType = "land" },
            --{ id = "oaab\\fabricDeskGreen", category = cso.landTypes.carpet, soundType = "land" },

			{ id = "hf\\lnd\\ph_tx_gm_dirt01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_dirt02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_dirtRoad01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_FarmLn_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_floor01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_floor02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_grass01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_grass02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_Gravel_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_Pebble_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_road01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_rockCliff_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_gm_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_rl_Dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_rl_Gravel_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_rl_Gravel_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_rl_Sand_01", category = cso.landTypes.sand, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_rl_Sand_02", category = cso.landTypes.sand, soundType = "land" },
			{ id = "hf\\lnd\\ph_tx_Rou_RuinFloor", category = cso.landTypes.dirt, soundType = "land" },

			{ id = "hr\\lnd\\hr_df_dirtroad_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_dirtsleet_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_dirtsnow_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_farmland_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_grasssnow_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_grasssnow_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_df_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_dirt_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_dirt_snow_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_farmland_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_grass_dirt_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_grass_snow_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_moss_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_oh_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_ostern_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_wr_gravel_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "hr\\lnd\\hr_wr_rock_01", category = cso.landTypes.stone, soundType = "land" },

			{ id = "pi\\lnd\\cq_tm_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\pi_cq_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\pi_cq_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\pi_cq_sand1", category = cso.landTypes.sand, soundType = "land" },
			{ id = "pi\\lnd\\pi_cq_sandblack1", category = cso.landTypes.sand, soundType = "land" },
			{ id = "pi\\lnd\\pi_po_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\pi_po_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\pi_po_seafloor_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_dirt", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_dirtGrass1", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_dirtGrass2", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_grass", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_gravel", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\pi_tm_gravelD", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\ynes_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\yns_clover_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_dirt_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\yns_dirt_03", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\yns_dirt_04", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "pi\\lnd\\yns_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_grass_03", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_grass_04", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_grass_sand_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "pi\\lnd\\yns_mud_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "pi\\lnd\\yns_mud_02", category = cso.landTypes.mud, soundType = "land" },
			{ id = "pi\\lnd\\yns_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\yns_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\yns_rock_03", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\yns_sandstone_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "pi\\lnd\\yns_sandwave_01", category = cso.landTypes.sand, soundType = "land" },
			{ id = "pi\\lnd\\yns_sandwave_02", category = cso.landTypes.sand, soundType = "land" },
			{ id = "pi\\lnd\\yns_sand_01", category = cso.landTypes.sand, soundType = "land" },

			{ id = "tr\\lnd\\tr_aj_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_aj_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_clover", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_cobblestn_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_daedricstone", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_grass", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_grass_b", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_at_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_grass_03", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_moss", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_cm_tilleddirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_daedricstone_snw", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_darkst_snow01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_darkst_snow02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_darkst_snow03", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_darkst_snow04", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_darkst_snow05", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ds_saltflats_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ds_saltpool_acid01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ds_saltpool_acid02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ds_saltpool_ground01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_dirt_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_grass_mud_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_moss_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_mud_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_gm_rock_scum_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_imp_paving_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_js_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_js_road_snow_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_kd_rockscrub_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_kd_scrub_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_kd_scrub_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_kha_deadgrass_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_nc_road01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_nc_sand01", category = cso.landTypes.sand, soundType = "land" },
			{ id = "tr\\lnd\\tr_nc_sand02", category = cso.landTypes.sand, soundType = "land" },
			{ id = "tr\\lnd\\tr_nec_floor", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_nec_ground", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_dirtroad_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_dirt_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_grass_dirt_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_oh_tilled_dirt", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_dirtscrub_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_dirttilled_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_01b", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_01c", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_01d", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_Scrub_03", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_04", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_ow_scrub_04b", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_rm_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_dirtroad_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_dirt_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_rockgrass_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_rock_03", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_rock_04", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_scrub_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_rr_scrub_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_cobblestones", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_daedricstone", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_dirttilled_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_dirt_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_dirt_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_mud_01", category = cso.landTypes.mud, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_01b", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_01c", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_02b", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_02c", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_03", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_03b", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_rock_03c", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_sh_scrubplain_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_dirt_grass_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_dirt_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_grass_moss_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_moss_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_road_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_tv_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_dirt_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_dirt_02", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_dirt_snow_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_grass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_grass_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_grass_snow_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_gravel_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_gravel_snow_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_gravel_snw_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_rock_snow_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "tr\\lnd\\tr_vm_rock_snow_02", category = cso.landTypes.snow, soundType = "land" },
			{ id = "tr\\lnd\\tr_wg_scrubsnow", category = cso.landTypes.snow, soundType = "land" },
			{ id = "tr\\lnd\\tr_whitestone01", category = cso.landTypes.stone, soundType = "land" },

			{ id = "va\\lnd\\va_xm_moldgrass_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldleaf_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldleaf_02", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldleaf_03", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldmoss_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldstone_01", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moldstone_02", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "va\\lnd\\va_xm_mold_01", category = cso.landTypes.grass, soundType = "land" },
			{ id = "va\\lnd\\va_xm_moss_01", category = cso.landTypes.dirt, soundType = "land" },
			{ id = "va\\lnd\\va_xm_rock_01", category = cso.landTypes.stone, soundType = "land" },
			{ id = "va\\lnd\\va_xm_rock_02", category = cso.landTypes.stone, soundType = "land" },
			{ id = "va\\lnd\\va_xm_slope_01a", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "va\\lnd\\va_xm_slope_01b", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "va\\lnd\\va_xm_slope_02a", category = cso.landTypes.gravel, soundType = "land" },
			{ id = "va\\lnd\\va_xm_slope_02b", category = cso.landTypes.gravel, soundType = "land" },

            -- Land, Dirt:
            --{ id = "oaab\\corpseburnedatlas", category = cso.landTypes.dirt, soundType = "land" },

            -- Land, Grass:
            --{ id = "oaab\\ab_straw_01", category = cso.landTypes.grass, soundType = "land" },

            -- Land, Gravel:
            --{ id = "oaab\\rem\\mv\\tx_mv_ground_04", category = cso.landTypes.gravel, soundType = "land" },

            -- Land, Ice:
            --{ id = "oaab\\skelpiletexture", category = cso.landTypes.ice, soundType = "land" },

            -- Land, Metal:
            --{ id = "oaab\\dr_tbl_staff_01", category = cso.landTypes.metal, soundType = "land" },

            -- Land, Mud:
            --{ id = "oaab\\corpsefreshatlas", category = cso.landTypes.mud, soundType = "land" },

	    	-- Land, Sand:
        
	    	-- Land, Snow:

            -- Land, Stone:
            --{ id = "oaab\\rem\\mv\\tx_mv_ground_01", category = cso.landTypes.stone, soundType = "land" },

            -- Land, Water:
            --{ id = "oaab\\dr_tx_blood_512x", category = cso.landTypes.water, soundType = "land" },

            -- Land, Wood:
            --{ id = "oaab\\rem\\mv\\tx_mv_bark_01", category = cso.landTypes.wood, soundType = "land" },

            -- Items, Book:
            --{ id = "oaab\\m\\bk_ruined_folio.nif", category = cso.itemTypes.book, soundType = "item" },

            -- Items, Clothing:
           --{ id = "oaab\\m\\misc_cloth_01a.nif", category = cso.itemTypes.clothing, soundType = "item" },,

            -- Items, Gold:
            --{ id = "oaab\\m\\dram_001.nif", category = cso.itemTypes.gold, soundType = "item" },

            -- Items, Gems:
            --{ id = "oaab\\n\\soulgem_black.nif", category = cso.itemTypes.gems, soundType = "item" },
        
	    	-- Items, Generic:
        
	    	-- Items, Ingredient:

            -- Items, Lockpicks/Keys
            --{ id = "oaab\\m\\misc_keyring.nif", category = cso.itemTypes.lockpick, soundType = "item" },
        
	    	-- Items, Jewelry:

            -- Items, Repair:
            --{ id = "oaab\\m\\dwrvtoolclamp.nif", category = cso.itemTypes.repair, soundType = "item" },

            -- Items, Scrolls:
            --{ id = "oaab\\m\\crumpledpaper.nif", category = cso.itemTypes.scrolls, soundType = "item" },

            -- Corpse Containers:
            --{ id = "oaab\\o\\corpse_arg_01.nif", category = cso.specialTypes.body, soundType = "corpse" },

            -- Creatures (For corpse containers and impact sounds - Only 'ghost' or 'metal', skeletons are detected based on creature type)
            --{ id = "oaab\\r\\dwspecter_f.nif", category = cso.specialTypes.ghost, soundType = "creature" },

        }

        for _,data in ipairs(soundData) do
            cso.addSoundData(data.id, data.category, data.soundType)
        end
    end
end)    