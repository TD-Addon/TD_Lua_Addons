if not tes3.isModActive("Tamriel_Data.esm") then return end

event.register(tes3.event.initialized, function()
	local midnightOil = include("mer.midnightOil.interop")
	if midnightOil then
		midnightOil.addToBlacklist("T_Dreu_Var_Lamp_01_256")
		midnightOil.addToBlacklist("T_Dreu_Var_Lamp_01_512")
		midnightOil.addToBlacklist("T_Dreu_Var_Lamp_02_256")
		midnightOil.addToBlacklist("T_Dreu_Var_Lamp_02_512")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_01_128")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_01_256")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_02_128")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_02_256")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_03_128")
		midnightOil.addToBlacklist("T_Dreu_Var_Lantern_03_256")
	end
end)