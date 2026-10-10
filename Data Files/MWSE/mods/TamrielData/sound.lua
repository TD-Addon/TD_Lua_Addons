local this = {}

local common = require("TamrielData.common")
local soundData = require("TamrielData.soundData")

local minimumTimeBetweenSounds = 1	-- Default values in the .cfg file
local maximumTimeBetweenSounds = 5
local timeToNextSound = minimumTimeBetweenSounds + (maximumTimeBetweenSounds - minimumTimeBetweenSounds) * math.random()	-- Wait a bit to begin playing a region's sounds when starting the game; this is something that vanilla doesn't do for some reason
local currentRegionSound

---@param e playItemSoundEventData
function this.improveItemSounds(e)
	local replacementSounds = soundData.item_sounds[e.item.id]
	if replacementSounds then
		if e.state == tes3.itemSoundState.up and replacementSounds.up then
			tes3.playSound{ sound = replacementSounds.up, mixChannel = tes3.soundMix.effects }
		elseif e.state == tes3.itemSoundState.down and replacementSounds.down then
			tes3.playSound{ sound = replacementSounds.down, mixChannel = tes3.soundMix.effects }
		elseif e.state == tes3.itemSoundState.consume and replacementSounds.use then
			tes3.playSound{ sound = replacementSounds.use, mixChannel = tes3.soundMix.effects }
		end

		if e.state ~= tes3.itemSoundState.direct then return false end	-- Block the vanilla behavior
	end
end

-- More ideas: Is near ocean? More weather conditions?

local conditions = {
	["inCity"] =
		function()
			if tes3.player.cell.displayName ~= tes3.player.cell.region.name then	-- If the cell has a name of its own, since cell.name is only for interiors (for some reason)
				local npcCount = 0
				local doorCount = 0

				for door in tes3.player.cell:iterateReferences(tes3.objectType.door, false) do
					doorCount = doorCount + 1
					if doorCount == 20 then return true end
				end
			end
		end,
	["inCell"] =
		function(cellName)
			if tes3.player.cell.displayName == cellName then
				return true
			end
		end,
	["aboveHeight"] =
		function(targetHeight)
			return tes3.player.position.z >= targetHeight
		end,
	["nearGround"] =
		function(targetDistance)
			return tes3.rayTest({ position = tes3.player.position, direction = { 0, 0, -1 }, root = tes3.game.worldLandscapeRoot, maxDistance = targetDistance }) or false
		end,
	["isSunrise"] =
		function()
			return tes3.worldController.hour.value >= tes3.worldController.weatherController.sunriseHour or tes3.worldController.hour.value < tes3.worldController.weatherController.sunriseHour + tes3.worldController.weatherController.sunriseDuration
		end,
	["isDay"] =
		function()
			return tes3.worldController.hour.value >= tes3.worldController.weatherController.sunriseHour + tes3.worldController.weatherController.sunriseDuration or tes3.worldController.hour.value < tes3.worldController.weatherController.sunsetHour
		end,
	["isSunset"] =
		function()
			return tes3.worldController.hour.value >= tes3.worldController.weatherController.sunsetHour or tes3.worldController.hour.value < tes3.worldController.weatherController.sunsetHour + tes3.worldController.weatherController.sunsetDuration
		end,
	["isNight"] =
		function()
			return tes3.worldController.hour.value >= tes3.worldController.weatherController.sunsetHour + tes3.worldController.weatherController.sunsetDuration or tes3.worldController.hour.value < tes3.worldController.weatherController.sunriseHour
		end,
	["weatherIsRain"] =
		function()
			return tes3.worldController.weatherController.currentWeather.index == tes3.weather.rain
		end,
	["weatherIsThunder"] =
		function()
			return tes3.worldController.weatherController.currentWeather.index == tes3.weather.thunder
		end,
	["weatherIsSnow"] =
		function()
			return tes3.worldController.weatherController.currentWeather.index == tes3.weather.snow
		end,
	["weatherIsStorm"] =
		function()
			return tes3.worldController.weatherController.currentWeather.index == tes3.weather.ash
		end,
}

---@param e simulateEventData
function this.playRegionSound(e)
	if tes3.player.cell.isOrBehavesAsExterior and tes3.player.cell.region then
		if currentRegionSound and tes3.getSoundPlaying({ sound = currentRegionSound, reference = tes3.player }) then	-- Let the current sound finish playing before playing (or waiting to play) another
			return
		else
			currentRegionSound = nil	-- Don't keep trying to get the sound if it is no longer playing
		end

		local soundTable = soundData.regionSounds[tes3.player.cell.region.id]
		if soundTable then
			if timeToNextSound > 0 then
				timeToNextSound = timeToNextSound - e.delta		-- timeToNextSound is reduced only when in an applicable region so the player is not consistently greeted with a sound immediately upon entering such a region
				return
			end

			local checkedConditions = {}
			local possibleSounds = {}
			local soundProbabilities = {}
			local probabilityRange = 0
			timeToNextSound = minimumTimeBetweenSounds + (maximumTimeBetweenSounds - minimumTimeBetweenSounds) * math.random()		-- This calculation matches the one for vanilla's region sounds, although maximumTimeBetweenSounds and minimumTimeBetweenSounds cannot be accessed via MWSE and thus are set to the default values

			if math.random() < soundTable.chanceNone then return end

			for _, soundGroup in pairs(soundTable.soundLists) do
				local validSounds = true
				if soundGroup.conditions then
					for _, condition in pairs(soundGroup.conditions) do
						local failValue = condition.isNot or false
						local result

						if checkedConditions[condition.type] and checkedConditions[condition.type][condition.parameter or ""] then	-- The results of the condition checks for a certain parameter (if present) are saved so that they don't have to be repeated for every soundGroup
							result = checkedConditions[condition.type][condition.parameter or ""]
						else
							result = conditions[condition.type](condition.parameter)
							checkedConditions[condition.type] = checkedConditions[condition.type] or {}
							checkedConditions[condition.type][condition.parameter or ""] = result
						end

						if result == failValue then
							validSounds = false
							break
						end
					end
				end

				if validSounds then
					local multiplier = soundGroup.multiplier or 1
					for soundID, baseProbability in pairs(soundGroup.sounds) do
						possibleSounds[soundID] = (possibleSounds[soundID] or 0) + multiplier * baseProbability
					end
				end
			end

			if table.size(possibleSounds) > 0 then
				for soundID, probability in pairs(possibleSounds) do
					soundProbabilities[soundID] = { lower = probabilityRange, upper = probabilityRange + probability }
					probabilityRange = probabilityRange + probability
				end

				local value = math.random() * probabilityRange
				for soundID, range in pairs(soundProbabilities) do
					if value >= range.lower and value < range.upper then
						currentRegionSound = soundID
						break
					end
				end

				tes3.playSound({ sound = currentRegionSound, reference = tes3.player, mixChannel = tes3.soundMix.effects })	-- tes3.player is used as a reference (even though vanilla's region sounds are not tied to a reference) so that checking and removing it is easier
			end
		end
	end
end

---@param e cellChangedEventData
function this.stopRegionSoundOnCellChange(e)
	if e.cell.isInterior and currentRegionSound then
		tes3.removeSound({ reference = tes3.player, currentRegionSound })
		currentRegionSound = nil
		timeToNextSound = minimumTimeBetweenSounds + (maximumTimeBetweenSounds - minimumTimeBetweenSounds) * math.random()
	end
end

function this.disableRegionSounds()
	for regionID in pairs(soundData.regionSounds) do
		local region = tes3.findRegion(regionID)
		if region then
			for _, regionSound in pairs(region.sounds) do
				regionSound.chance = 0
			end
		end
	end
end

return this