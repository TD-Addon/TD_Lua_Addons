local defaultConfig = {
	summoningSpells = true,
	boundSpells = true,
	interventionSpells = true,
	miscSpells = true,
	overwriteMagickaExpanded = true,
	provincialReputation = true,
	weatherChanges = true,
	hats = true,
	creatureBehaviors = true,
	fixPlayerRaceAnimations = true,
	restrictEquipment = true,
	fixVampireHeads = true,
	improveItemSounds = true,
	adjustTravelPrices = true,
	changeMorrowindFactionNames = tes3.getLanguage() == "eng",
	limitIntervention = false
}

return mwse.loadConfig("tamrielData", defaultConfig)