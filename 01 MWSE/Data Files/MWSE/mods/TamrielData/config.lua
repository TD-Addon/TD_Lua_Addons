local defaultConfig = {
	summoningSpells = true,
	boundSpells = true,
	interventionSpells = true,
	miscSpells = true,
	changeVanillaEnchantments = true,
	overwriteMagickaExpanded = true,
	provincialReputation = true,
	weatherChanges = true,
	fixPlayerRaceAnimations = true,
	restrictEquipment = true,
	fixVampireHeads = true,
	improveItemSounds = true,
	adjustTravelPrices = true,
	limitIntervention = false
}

return mwse.loadConfig("tamrielData", defaultConfig)