local common = require("tamrielData.common")

local defaultConfig = {
	summoningSpells = true,
	boundSpells = true,
	interventionSpells = true,
	miscSpells = true,
	overwriteMagickaExpanded = true,
	provincialReputation = true,
	provincialFactionUI = true,
	weatherChanges = true,
	hats = true,
	creatureBehaviors = true,
	fixPlayerRaceAnimations = true,
	restrictEquipment = true,
	fixVampireHeads = true,
	improveItemSounds = true,
	adjustTravelPrices = true,
	butterflyMothTooltip = common.gh_config and common.gh_config.showTooltips,
	limitIntervention = false
}

return mwse.loadConfig("tamrielData", defaultConfig)