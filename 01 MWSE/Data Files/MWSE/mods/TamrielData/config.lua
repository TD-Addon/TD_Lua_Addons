local defaultConfig = {
	summoningSpells = true,
	boundSpells = true,
	miscSpells = true,
	fixPlayerRaceAnimations = true,
	restrictEquipment = true,
	fixVampireHeads = true,
	improveItemSounds = true,
	adjustTravelPrices = true,
	limitIntervention = false
}

local config = mwse.loadConfig("tamrielData", defaultConfig)

-- Set config values to the default if they do not exist in the config file (because of a recent TD update)
for k, v in pairs(defaultConfig) do
	if config[k] == nil then
		config[k] = v
	end
end

return config