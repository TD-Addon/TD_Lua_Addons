local common = require("TamrielData.common")

local defaultConfig = {
	summoningSpells = true,
	boundSpells = true,
	interventionSpells = true,
	miscSpells = true,
	passwallAlteration = false,
	blinkIndicator = true,
	overwriteMagickaExpanded = true,
	provincialReputation = true,
	provincialFactionUI = true,
	weatherChanges = true,
	hats = true,
	embedments = true,
	creatureBehaviors = true,
	fixPlayerRaceAnimations = true,
	hideWerewolfMesh = true,
	restrictEquipment = true,
	fixVampireHeads = true,
	improveItemSounds = true,
	adjustTravelPrices = true,
	handleReactCellItems = true,
	khajiitFormCharCreation = true,
	butterflyMothTooltip = common.gh_config and common.gh_config.showTooltips,
	limitIntervention = false
}

return mwse.loadConfig("tamrielData", defaultConfig)