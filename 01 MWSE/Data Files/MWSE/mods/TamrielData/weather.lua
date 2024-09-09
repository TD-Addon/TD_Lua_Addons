local this = {}

local common = require("tamrielData.common")
local config = require("tamrielData.config")

--[[ OW spore weather colors made with Weather Adjuster for Foggy weather, put here for safekeeping
	"sunDayColor":[0.43529415130615,0.5137255191803,0.59215688705444],
	"skySunsetColor":[0.69924533367157,0.60070633888245,0.46759128570557],
	"fogSunsetColor":[0.60532134771347,0.50507992506027,0.34875121712685],
	"fogDayColor":[0.79109632968903,0.70632523298264,0.48063969612122],
	"skyNightColor":[0.070588238537312,0.090196080505848,0.10980392992496],
	"fogSunriseColor":[0.73101019859314,0.63647925853729,0.43306562304497],
	"ambientSunsetColor":[0.24049001932144,0.19473248720169,0.10193577408791],
	"skyDayColor":[0.74376100301743,0.73490351438522,0.59003269672394],
	"ambientDayColor":[0.33154195547104,0.30509635806084,0.23243916034698],
	"sunNightColor":[0.28891077637672,0.39492139220238,0.4935542345047],
	"ambientNightColor":[0.15254998207092,0.12697984278202,0],
	"sunSunsetColor":[0.53818500041962,0.61064475774765,0.6895512342453],
	"sundiscSunsetColor":[0.87450987100601,0.87450987100601,0.87450987100601],
	"sunSunriseColor":[0.69411766529083,0.63529413938522,0.53725492954254],
	"ambientSunriseColor":[0.21572290360928,0.1626899689436,0.085801161825657],
	"fogNightColor":[0.10387838631868,0.090302668511868,0.066596813499928],
	"skySunriseColor":[0.85004240274429,0.72914785146713,0.58642137050629]
]]

local defaultStormOrigin = tes3vector2.new(25000, 70000)

-- region id, origin x-coordinate, origin y-coordinate
local region_storm_origins = {
	{ "Armun Ashlands Region", -132386.328, -200454.234 }	-- Should eventually be set to the large volcano west of Armun once it is made
}

---@param weather tes3weatherAsh
local function changeStormOrigin(weather)
	for _,v in pairs(region_storm_origins) do
		local regionID, xCoord, yCoord = unpack(v)
		if tes3.getRegion({ useDoors = true }).name == regionID then
			weather.stormOrigin = tes3vector2.new(xCoord, yCoord)
			return
		end
	end

	weather.stormOrigin = defaultStormOrigin	-- This kind of solution shouldn't be necessary, but MWSE doesn't allow for weathers to be nicely reset to their default settings
end

---@param e weatherChangedImmediateEventData
function this.stormOriginWeatherChanged(e)
	if e.to.name == "Ashstorm" then
		changeStormOrigin(e.to)
	end
end

function this.stormOriginCellLoad()
	local weather = tes3.getCurrentWeather()
	if weather.name == "Ashstorm" then
		changeStormOrigin(weather)
	end
end

return this