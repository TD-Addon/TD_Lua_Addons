local this = {}

local common = require("tamrielData.common")
local config = require("tamrielData.config")

-- Default weather settings; set using findGMST?
local defaultSnowFog = { landFogDayDepth = 1, landFogNightDepth = 1.2 }
local defaultSnowFogMGE
local defaultSnowWind = 0
local defaultSnowWindMGE
local defaultSnowColors = {
	ambientSunriseColor = tes3vector3.new(0.36078432202339,0.32941177487373,0.32941177487373),
	ambientDayColor = tes3vector3.new(0.3647058904171,0.37647062540054,0.41176474094391),
	ambientSunsetColor = tes3vector3.new(0.27450981736183,0.3098039329052,0.34117648005486),
	ambientNightColor = tes3vector3.new(0.19215688109398,0.22745099663734,0.26666668057442),

	skySunriseColor = tes3vector3.new(0.41568630933762,0.35686275362968,0.35686275362968),
	skyDayColor = tes3vector3.new(0.60000002384186,0.61960786581039,0.65098041296005),
	skySunsetColor = tes3vector3.new(0.37647062540054,0.45098042488098,0.52549022436142),
	skyNightColor = tes3vector3.new(0.070588238537312,0.090196080505848,0.10980392992496),

	fogSunriseColor = tes3vector3.new(0.41568630933762,0.35686275362968,0.35686275362968),
	fogDayColor = tes3vector3.new(0.60000002384186,0.61960786581039,0.65098041296005),
	fogSunsetColor = tes3vector3.new(0.37647062540054,0.45098042488098,0.52549022436142),
	fogNightColor = tes3vector3.new(0.12156863510609,0.13725490868092,0.15294118225574),

	sunSunriseColor = tes3vector3.new(0.55294120311737,0.42745101451874,0.42745101451874),
	sunDayColor = tes3vector3.new(0.63921570777893,0.66274511814117,0.71764707565308),
	sunSunsetColor = tes3vector3.new(0.39607846736908,0.47450983524323,0.55294120311737),
	sunNightColor = tes3vector3.new(0.21568629145622,0.258823543787,0.30196079611778),

	sundiscSunsetColor = tes3vector3.new(0.50196081399918,0.50196081399918,0.50196081399918)
}
local defaultSnowClouds = { cloudsMaxPercent = 1, cloudsSpeed = 1.5, cloudTexture = "Textures\\tx_bm_sky_snow.dds" }
local defaultSnowParticles = { maxParticles = 1500, particleEntranceSpeed = 6, particleHeightMax = 700, particleHeightMin = 400, particleRadius = 800,
									newParticle = "bm_snow_01.nif", precipitationFallSpeed = -575, isSnow = true, snowFallSpeedScale = 0.1 }	-- Of the numerical values, only maxParticles seems to be relevant for the snow controller
local defaultSnowSound = ""
if mge.enabled() then
	defaultSnowFogMGE = mgeWeatherConfig.getDistantFog(tes3.weather.snow)
	defaultSnowWindMGE = mgeWeatherConfig.getWind(tes3.weather.snow).speed
end

local defaultStormOrigin = tes3vector2.new(25000, 70000)

-- Custom Weather Settings
local othrelethSporefallFog = { landFogDayDepth = 1.1, landFogNightDepth = 1.6 }
local othrelethSporefallFogMGE = { distance = .16, offset = 10 }
local othrelethSporefallWind = .4			-- Higher than MGE's wind so that it can blow the spores around without making grass look like a thunderstorm is present
local othrelethSporefallWindMGE = .1
local othrelethSporefallColors = {
	ambientSunriseColor = tes3vector3.new(0.27294388413429,0.20933870971203,0.11750064045191),
	ambientDayColor = tes3vector3.new(0.33694046735764,0.30483055114746,0.21058352291584),
	ambientSunsetColor = tes3vector3.new(0.24061198532581,0.19484589993954,0.10204297304153),
	ambientNightColor = tes3vector3.new(0.14370784163475,0.1271006911993,0.067252717912197),

	skySunriseColor = tes3vector3.new(0.81255954504013,0.62385624647141,0.36805811524391),
	skyDayColor = tes3vector3.new(0.65067648887634,0.64906567335129,0.35700508952141),
	skySunsetColor = tes3vector3.new(0.72385734319687,0.56822526454926,0.3271227478981),
	skyNightColor = tes3vector3.new(0.10392910987139,0.086770243942738,0.03624227270484),

	fogSunriseColor = tes3vector3.new(0.75838434696198,0.63241970539093,0.31937465071678),
	fogDayColor = tes3vector3.new(0.74217289686203,0.64066410064697,0.32276219129562),
	fogSunsetColor = tes3vector3.new(0.64377784729004,0.4962210059166,0.22626619040966),
	fogNightColor = tes3vector3.new(0.11429940909147,0.088800229132175,0.032750491052866),

	sunSunriseColor = tes3vector3.new(0.69411766529083,0.63529413938522,0.53725492954254),
	sunDayColor = tes3vector3.new(0.4966846704483,0.51434928178787,0.42396208643913),
	sunSunsetColor = tes3vector3.new(0.56242853403091,0.50337612628937,0.42783063650131),
	sunNightColor = tes3vector3.new(0.14676041901112,0.17843659222126,0.21117457747459),

	sundiscSunsetColor = tes3vector3.new(0.87450987100601,0.87450987100601,0.87450987100601)
}
local othrelethSporefallClouds = { cloudsMaxPercent = 1, cloudsSpeed = 1, cloudTexture = "Textures\\tx_sky_foggy.dds" }
local othrelethSporefallParticles = { maxParticles = 1000, particleEntranceSpeed = 6, particleHeightMax = 700, particleHeightMin = 400, particleRadius = 3600,
											newParticle = "tr\\tr_weather_ow_spore.nif", precipitationFallSpeed = -575, isSnow = true, snowFallSpeedScale = 0.075 }
local othrelethSporefallSound = ""

local rainParticles = { "Raindrop" }
local snowParticles = { "Snowflake", "BM_Snow_01", "tr_weather_ow_spore" }

-- Custom Region Weather Chances
-- region id, ash chance, blight chance, blizzard chance, clear chance, cloudy chance, foggy chance, overcast chance, rain chance, snow chance, thunder chance
local region_weather_chances = {
	{ "Othreleth Woods Region", 0, 0, 0, 25, 25, 6, 10, 15, 14, 5 }	-- Ash chance is set to 0 to prevent ashstorms in OW interfering with sandstorms in SH
}

-- region id, origin x-coordinate, origin y-coordinate
local region_storm_origins = {
	-- Armun ashstorms
	{ "Armun Ashlands Region", -132386.328, -200454.234 },	-- Should eventually be set to the large volcano west of Armun once it is made
	{ "Othreleth Woods Region", -132386.328, -200454.234 },	-- These extra regions are necessary for the same reason as the weather transition condition; leaving AA during an ashstorm without them would immediately set the origin to be Red Mountain
	{ "Velothi Mountains Region", -132386.328, -200454.234 },
	{ "Aanthirin Region", -132386.328, -200454.234 },
	{ "Roth Roryn Region", -132386.328, -200454.234 },

	-- Abecean tropical storms
	{ "Abecean Sea Region", -2863000.000, -405600.000 },
	{ "Colovian Highlands Region", -2863000.000, -405600.000 },
	{ "Dasek Marsh Region", -2863000.000, -405600.000 },
	{ "Gilded Hills Region", -2863000.000, -405600.000 },
	{ "Gold Coast Region", -2863000.000, -405600.000 },
	{ "Kvetchi Pass Region", -2863000.000, -405600.000 },
	{ "Southern Gold Coast Region", -2863000.000, -405600.000 },
	{ "Stirk Isle Region", -2863000.000, -405600.000 },
}

---@param weather tes3weather
local function changeWeatherFog(weather, vanillaFog, mgeFog)
	weather.landFogDayDepth = vanillaFog.landFogDayDepth
	weather.landFogNightDepth = vanillaFog.landFogNightDepth

	if mge.enabled() then
		mge.weather.setDistantFog({ weather = weather.index, distance = mgeFog.distance, offset = mgeFog.offset })
	end
end

---@param weather tes3weather
local function changeWeatherWind(weather, windVanilla, windMGE)
	weather.windSpeed = windVanilla

	if mge.enabled() then
		mge.weather.setWind({ weather = weather.index, speed = windMGE })
	end
end

---@param weather tes3weather
local function changeWeatherColors(weather, colorTable)
	weather.ambientSunriseColor.r = colorTable.ambientSunriseColor.r
	weather.ambientSunriseColor.g = colorTable.ambientSunriseColor.g
	weather.ambientSunriseColor.b = colorTable.ambientSunriseColor.b
	weather.ambientDayColor.r = colorTable.ambientDayColor.r
	weather.ambientDayColor.g = colorTable.ambientDayColor.g
	weather.ambientDayColor.b = colorTable.ambientDayColor.b
	weather.ambientSunsetColor.r = colorTable.ambientSunsetColor.r
	weather.ambientSunsetColor.g = colorTable.ambientSunsetColor.g
	weather.ambientSunsetColor.b = colorTable.ambientSunsetColor.b
	weather.ambientNightColor.r = colorTable.ambientNightColor.r
	weather.ambientNightColor.g = colorTable.ambientNightColor.g
	weather.ambientNightColor.b = colorTable.ambientNightColor.b

	weather.skySunriseColor.r = colorTable.skySunriseColor.r
	weather.skySunriseColor.g = colorTable.skySunriseColor.g
	weather.skySunriseColor.b = colorTable.skySunriseColor.b
	weather.skyDayColor.r = colorTable.skyDayColor.r
	weather.skyDayColor.g = colorTable.skyDayColor.g
	weather.skyDayColor.b = colorTable.skyDayColor.b
	weather.skySunsetColor.r = colorTable.skySunsetColor.r
	weather.skySunsetColor.g = colorTable.skySunsetColor.g
	weather.skySunsetColor.b = colorTable.skySunsetColor.b
	weather.skyNightColor.r = colorTable.skyNightColor.r
	weather.skyNightColor.g = colorTable.skyNightColor.g
	weather.skyNightColor.b = colorTable.skyNightColor.b

	weather.fogSunriseColor.r = colorTable.fogSunriseColor.r
	weather.fogSunriseColor.g = colorTable.fogSunriseColor.g
	weather.fogSunriseColor.b = colorTable.fogSunriseColor.b
	weather.fogDayColor.r = colorTable.fogDayColor.r
	weather.fogDayColor.g = colorTable.fogDayColor.g
	weather.fogDayColor.b = colorTable.fogDayColor.b
	weather.fogSunsetColor.r = colorTable.fogSunsetColor.r
	weather.fogSunsetColor.g = colorTable.fogSunsetColor.g
	weather.fogSunsetColor.b = colorTable.fogSunsetColor.b
	weather.fogNightColor.r = colorTable.fogNightColor.r
	weather.fogNightColor.g = colorTable.fogNightColor.g
	weather.fogNightColor.b = colorTable.fogNightColor.b

	weather.sunSunriseColor.r = colorTable.sunSunriseColor.r
	weather.sunSunriseColor.g = colorTable.sunSunriseColor.g
	weather.sunSunriseColor.b = colorTable.sunSunriseColor.b
	weather.sunDayColor.r = colorTable.sunDayColor.r
	weather.sunDayColor.g = colorTable.sunDayColor.g
	weather.sunDayColor.b = colorTable.sunDayColor.b
	weather.sunSunsetColor.r = colorTable.sunSunsetColor.r
	weather.sunSunsetColor.g = colorTable.sunSunsetColor.g
	weather.sunSunsetColor.b = colorTable.sunSunsetColor.b
	weather.sunNightColor.r = colorTable.sunNightColor.r
	weather.sunNightColor.g = colorTable.sunNightColor.g
	weather.sunNightColor.b = colorTable.sunNightColor.b

	weather.sundiscSunsetColor.r = colorTable.sundiscSunsetColor.r
	weather.sundiscSunsetColor.g = colorTable.sundiscSunsetColor.g
	weather.sundiscSunsetColor.b = colorTable.sundiscSunsetColor.b
end

---@param weather tes3weather
local function changeWeatherClouds(weather, cloudSettings)
	weather.cloudsMaxPercent = cloudSettings.cloudsMaxPercent
	weather.cloudsSpeed = cloudSettings.cloudsSpeed
	weather.cloudTexture = cloudSettings.cloudTexture
end

---@param weather tes3weather
---@param newSoundID string
local function changeWeatherSound(weather, newSoundID)
	if weather.ambientLoopSoundId ~= newSoundID then
		if weather.ambientLoopSound then
			weather.ambientLoopSound:stop()
		end

		weather.ambientLoopSoundId = newSoundID
	end
end

--- @param particle tes3weatherControllerParticle
--- @param newParticleMesh niAVObject
--- @param isSnow boolean
local function swapNode(particle, newParticleMesh, isSnow)
	if isSnow then								-- Prevent changing rain particles to snow particles
		for _,v in pairs(rainParticles) do
			if v == particle.object.name then
				return
			end
		end
	else
		for _,v in pairs(snowParticles) do
			if v == particle.object.name then
				return
			end
		end
	end

    local old = particle.object
    particle.rainRoot:detachChild(old)

    local new = newParticleMesh:clone()
    particle.rainRoot:attachChild(new)
    new.appCulled = old.appCulled
	
    particle.object = new
end

--- @param meshPath string
local function loadParticle(meshPath)
	local particle = tes3.loadMesh(meshPath)

	-- Strip all properties except for texturing for uniform lighting
	for _,child in pairs(particle.children) do
		child:detachProperty(ni.propertyType.alpha)
		child:detachProperty(ni.propertyType.dither)
		child:detachProperty(ni.propertyType.fog)
		child:detachProperty(ni.propertyType.material)
		child:detachProperty(ni.propertyType.shade)
		child:detachProperty(ni.propertyType.specular)
		child:detachProperty(ni.propertyType.stencil)
		child:detachProperty(ni.propertyType.vertexColor)
		child:detachProperty(ni.propertyType.wireframe)
		child:detachProperty(ni.propertyType.zBuffer)
	end

	return particle
end

---@param weather tes3weatherRain
local function changeWeatherParticles(weather, particleSettings)
	weather.maxParticles = particleSettings.maxParticles
	weather.particleEntranceSpeed = particleSettings.particleEntranceSpeed
	weather.particleHeightMax = particleSettings.particleHeightMax
	weather.particleHeightMin = particleSettings.particleHeightMin
	weather.particleRadius = particleSettings.particleRadius

	local weatherController = weather.controller
	weatherController.precipitationFallSpeed = particleSettings.precipitationFallSpeed
	if particleSettings.isSnow then
		weatherController.snowFallSpeedScale = particleSettings.snowFallSpeedScale
	end

	local newParticle = loadParticle(particleSettings.newParticle)

	if (not weatherController.particlesActive[1] or weatherController.particlesActive[1].object.name ~= newParticle.name) and
		(not weatherController.particlesInactive[1] or weatherController.particlesInactive[1].object.name ~= newParticle.name) then	-- Done for optimization, prevents iterating through all particles on every cell change that this function is called
		for _,particle in pairs(weatherController.particlesActive) do
			swapNode(particle, newParticle, particleSettings.isSnow)
		end
	
		for _,particle in pairs(weatherController.particlesInactive) do
			swapNode(particle, newParticle, particleSettings.isSnow)
		end
	end
end

-- Checks whether the player is loading into a cell with the spore storm weather active so that particle settings are actually applied; this change is visible to the player, but is necessary and unavoidable until MWSE has proper support for custom weathers
---@param customWeather tes3weather
local function fixParticlesOnLoad(customWeather, isNext)
	local controller = customWeather.controller

	if not isNext then
		controller:switchImmediate(tes3.weather.clear)
		controller:updateVisuals()
		controller:switchImmediate(customWeather.index)
		controller:updateVisuals()
	else
        local ts = controller.transitionScalar
		controller:switchImmediate(controller.currentWeather.index)
		controller:updateVisuals()
        controller:switchTransition(customWeather.index)
        controller.transitionScalar = ts
	end
end

---@param weather tes3weatherRain
local function changeWeather(weather, fogVanilla, fogMGE, wind, windMGE, colors, clouds, sound, particles)
	changeWeatherFog(weather, fogVanilla, fogMGE)
	changeWeatherWind(weather, wind, windMGE)
	changeWeatherColors(weather, colors)
	changeWeatherClouds(weather, clouds)
	changeWeatherSound(weather, sound)
	changeWeatherParticles(weather, particles)
end

---@param e weatherChangedImmediateEventData
function this.manageWeathers(e)
	local weather
	local nextWeather
	
	if not e.to then
		weather = tes3.getCurrentWeather()
		if weather.controller.nextWeather then
			nextWeather = weather.controller.nextWeather
		end
	else
		weather = e.to
	end

	local currentRegion = tes3.getRegion({ useDoors = true })
	if currentRegion then
		if currentRegion.id == "Othreleth Woods Region" or currentRegion.id == "Thirr Valley Region" or currentRegion.id == "Aanthirin Region" or currentRegion.id == "Shipal-Shin Region" then	   -- Regions that either are OW or border it without (currently) bordering a region with normal snow (like VM)
			if weather.name == "Snow" then
				changeWeather(weather, othrelethSporefallFog, othrelethSporefallFogMGE, othrelethSporefallWind, othrelethSporefallWindMGE, othrelethSporefallColors, othrelethSporefallClouds, othrelethSporefallSound, othrelethSporefallParticles)
				if not e.to and not e.previousCell then
					fixParticlesOnLoad(weather, false)
				end
			elseif nextWeather.name and nextWeather.name == "Snow" then	-- Exists to change the next weather if the player loads a game where the weather should be changing to the spore storm
				changeWeather(nextWeather, othrelethSporefallFog, othrelethSporefallFogMGE, othrelethSporefallWind, othrelethSporefallWindMGE, othrelethSporefallColors, othrelethSporefallClouds, othrelethSporefallSound, othrelethSporefallParticles)
				if not e.to and not e.previousCell then
					fixParticlesOnLoad(nextWeather, true)
				end
			end
		elseif currentRegion.id == "Armun Ashlands Region" and not tes3.getPlayerCell().isInterior and tes3.getPlayerCell().gridX > -11 then	-- This is a very temporary solution for weather transitions that will work until the WBM release; MWSE will need actual support for custom weathers in order for transitions to work at that point
			if weather.name == "Snow" then
				changeWeather(weather, othrelethSporefallFog, othrelethSporefallFogMGE, othrelethSporefallWind, othrelethSporefallWindMGE, othrelethSporefallColors, othrelethSporefallClouds, othrelethSporefallSound, othrelethSporefallParticles)
			end
		else
			if weather.name == "Snow" then
				changeWeather(weather, defaultSnowFog, defaultSnowFogMGE, defaultSnowWind, defaultSnowWindMGE, defaultSnowColors, defaultSnowClouds, defaultSnowSound, defaultSnowParticles)
			end
		end
	end
end

function this.changeRegionWeatherChances()
	for _,v in pairs(region_weather_chances) do
		local regionID, weatherChanceAsh, weatherChanceBlight, weatherChanceBlizzard, weatherChanceClear, weatherChanceCloudy, weatherChanceFoggy, weatherChanceOvercast, weatherChanceRain, weatherChanceSnow, weatherChanceThunder = unpack(v)
		local region = tes3.findRegion(regionID)
		
		region.weatherChanceAsh = weatherChanceAsh
		region.weatherChanceBlight = weatherChanceBlight
		region.weatherChanceBlizzard = weatherChanceBlizzard
		region.weatherChanceClear = weatherChanceClear
		region.weatherChanceCloudy = weatherChanceCloudy
		region.weatherChanceFoggy = weatherChanceFoggy
		region.weatherChanceOvercast = weatherChanceOvercast
		region.weatherChanceRain = weatherChanceRain
		region.weatherChanceSnow = weatherChanceSnow
		region.weatherChanceThunder = weatherChanceThunder
	end
end

-- Ideally the following function could just be run on cell changes, but trying to access the weather field of the weather controller causes problems so it is instead called by the two functions beneath it
---@param e weatherChangedImmediateEventData
function this.changeStormOrigin(e)
	local weather
	if not e.to then
		weather = tes3.getCurrentWeather()
	else
		weather = e.to
	end

	if weather.index == tes3.weather.ash then
		for _,v in pairs(region_storm_origins) do
			local regionID, xCoord, yCoord = unpack(v)
			if tes3.getRegion({ useDoors = true }).id == regionID then
				weather.stormOrigin = tes3vector2.new(xCoord, yCoord)
				return
			end
		end

		weather.stormOrigin = defaultStormOrigin	-- This kind of solution shouldn't be necessary, but MWSE doesn't allow for weathers to be nicely reset to their default settings
	end
end

return this