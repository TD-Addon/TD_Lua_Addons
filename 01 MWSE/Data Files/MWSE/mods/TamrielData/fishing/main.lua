local Interop = require("mer.fishing")

local fishingNets = {
	{ id = "t_de_fishingnet_01" },
}
event.register("initialized", function(_)
	for _, data in ipairs(fishingNets) do
		Interop.registerFishingNet(data)
	end
end)
