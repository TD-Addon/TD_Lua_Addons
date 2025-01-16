-- Script for allowing Graphic Herbalism to affect containers that it otherwise wouldn't
event.register(tes3.event.initialized, function()
    local gh_config = include("graphicHerbalism.config")
    if gh_config then
		--gh_config.blacklist["t_glb_fauna_seabiscuit1"] = false
		--gh_config.blacklist["t_glb_fauna_seabiscuit2"] = false
		--gh_config.blacklist["t_glb_fauna_seabiscuit3"] = false
		--gh_config.blacklist["t_glb_fauna_shellauger1"] = false
		--gh_config.blacklist["t_glb_fauna_shellauger2"] = false
		--gh_config.blacklist["t_glb_fauna_shellauger3"] = false
		--gh_config.blacklist["t_glb_fauna_shellauger4"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg1"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg2"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg3"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg4"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg5"] = false
		--gh_config.blacklist["t_glb_fauna_shellckfrg6"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl1"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl2"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl3"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl4"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl5"] = false
		--gh_config.blacklist["t_glb_fauna_shellcockl6"] = false
		--gh_config.blacklist["t_glb_fauna_shellconch"] = false
		--gh_config.blacklist["t_glb_fauna_shellsnail1"] = false
		--gh_config.blacklist["t_glb_fauna_shellsnail2"] = false
		--gh_config.blacklist["t_mw_fauna_ventworm_01"] = false
		--gh_config.blacklist["t_mw_fauna_ventworm_02"] = false
		--gh_config.blacklist["t_mw_fauna_ventworm_03"] = false
		--gh_config.blacklist["t_mw_fauna_ventworm_04"] = false
		--gh_config.blacklist["t_pi_fauna_fishslvspd1"] = false
		--gh_config.blacklist["t_pi_fauna_fishslvspd2"] = false
		--gh_config.blacklist["t_pi_fauna_fishslvspd3"] = false

		gh_config.whitelist["t_glb_fauna_seabiscuit1"] = true
		gh_config.whitelist["t_glb_fauna_seabiscuit2"] = true
		gh_config.whitelist["t_glb_fauna_seabiscuit3"] = true
		gh_config.whitelist["t_glb_fauna_shellauger1"] = true
		gh_config.whitelist["t_glb_fauna_shellauger2"] = true
		gh_config.whitelist["t_glb_fauna_shellauger3"] = true
		gh_config.whitelist["t_glb_fauna_shellauger4"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg1"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg2"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg3"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg4"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg5"] = true
		gh_config.whitelist["t_glb_fauna_shellckfrg6"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl1"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl2"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl3"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl4"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl5"] = true
		gh_config.whitelist["t_glb_fauna_shellcockl6"] = true
		gh_config.whitelist["t_glb_fauna_shellconch"] = true
		gh_config.whitelist["t_glb_fauna_shellsnail1"] = true
		gh_config.whitelist["t_glb_fauna_shellsnail2"] = true
		gh_config.whitelist["t_mw_fauna_ventworm_01"] = true
		gh_config.whitelist["t_mw_fauna_ventworm_02"] = true
		gh_config.whitelist["t_mw_fauna_ventworm_03"] = true
		gh_config.whitelist["t_mw_fauna_ventworm_04"] = true
		gh_config.whitelist["t_pi_fauna_fishslvspd1"] = true
		gh_config.whitelist["t_pi_fauna_fishslvspd2"] = true
		gh_config.whitelist["t_pi_fauna_fishslvspd3"] = true

		gh_config.blacklist["t_cyr_fauna_nesttant_01"] = true
		gh_config.blacklist["t_cyr_fauna_nesttant_02"] = true
		gh_config.blacklist["t_cyr_fauna_nesttant_03"] = true
		gh_config.blacklist["t_cyr_fauna_nesttant_04"] = true
    end
end)