local this = {}

local common = require("TamrielData.common")

local lamiaReferences = {}
local dreughReferences = {}

---@param e combatStartedEventData
---@param creatureID string
local function creatureGroupDefend(e, creatureID)
	local actors = tes3.findActorsInProximity({ reference = e.target, range = 2048 })
	if actors then
		for _,actor in pairs(actors) do
			if actor.reference.baseObject.id == creatureID then
				actor:startCombat(e.actor)
			end
		end
	end
end

---@param e combatStartedEventData
function this.onGroupAttacked(e)
	if e.target.reference.baseObject.id == "T_Cyr_Fau_Tantha_01" then
		creatureGroupDefend(e, "T_Cyr_Fau_Tantha_01")
	end
end

---@param e activateEventData
---@param creatureID string
local function creatureNestDefend(e, creatureID)
	local actors = tes3.findActorsInProximity({ reference = e.target, range = 2048 })
	if actors then
		local playerDetected = false
		for _,actor in pairs(actors) do
			if actor.reference.baseObject.id == creatureID then
				if e.activator.mobile.isSneaking and tes3.worldController.mobManager.processManager:detectSneak(actor, e.activator.mobile) then
					playerDetected = true
					break
				end
			end
		end

		if not e.activator.mobile.isSneaking or playerDetected then
			for _,actor in pairs(actors) do
				if actor.reference.baseObject.id == creatureID then
					actor:startCombat(e.activator.mobile)
				end
			end
		end
	end
end

---@param e activateEventData
function this.onNestLoot(e)
	if e.target.id == "T_Cyr_Fauna_NestTant_01" or e.target.id == "T_Cyr_Fauna_NestTant_02" or e.target.id == "T_Cyr_Fauna_NestTant_03" or e.target.id == "T_Cyr_Fauna_NestTant_04" then
		creatureNestDefend(e, "T_Cyr_Fau_Tantha_01")
	end
end

---@param e mobileActivatedEventData
function this.onMobileActivated(e)
	if e.mobile.actorType == tes3.actorType.creature then
		if e.reference.baseObject.id == "T_Glb_Cre_Lami_01" or e.reference.baseObject.id == "T_Glb_Cre_LamiLess_01" then
			lamiaReferences[e.reference] = true		-- Special thanks to G7 for showing me where he used this kind of setup in one of his mods; it is a much more efficient system than what I had in mind.
		elseif e.reference.baseObject.id == "dreugh" or e.reference.baseObject.id == "T_Cyr_Cre_Dreu_01" or e.reference.baseObject.id:find("T_Glb_Cre_Dreu") or e.reference.baseObject.id:find("T_Glb_Cre_LandDreu") then
			dreughReferences[e.reference] = true
		end
	end
end

---@param e mobileDeactivatedEventData
function this.onMobileDeactivated(e)
	if e.mobile.actorType == tes3.actorType.creature then
		lamiaReferences[e.reference] = nil
		dreughReferences[e.reference] = nil
	end
end

function this.creatureDetectionTick()
	for lamia in pairs(lamiaReferences) do
		---@cast lamia tes3reference
		for dreugh in pairs(dreughReferences) do
			if lamia.position:distanceXY(dreugh.position) < 4096 then
				lamia.mobile:startCombat(dreugh.mobile)
				dreugh.mobile:startCombat(lamia.mobile)
			end
		end
	end
end

---@param e playGroupEventData
function this.loopStridentRunnerNesting(e)
	if e.reference.baseObject.id == "T_Cyr_Fau_BirdStridN_01" and e.group == tes3.animationGroup.idle6 then
		e.loopCount = -1	-- Ordinarily idles don't loop correctly (e.g. Vivec) and a MWScript solution (like the one that some mods use for Vivec) doesn't work well on a hostile creature such as the Strident Runners, but this does.
	end
end

-- The Welkynd Spirit has a script that reenables its light like so upon changing cells, but it cannot account for the game being loaded. I would just do this in onMobileActivated, but mobileActivated does not run on loading the game.
---@param e cellChangedEventData
function this.fixWelkyndSpiritLight(e)
	if not e.previousCell then
		for creature in e.cell:iterateReferences(tes3.objectType.creature, false) do
			if creature.baseObject.mesh:find("ayl_guard") then
				if not creature.isDead then
					tes3.removeItem({ reference = creature, item = "T_Ayl_DngRuin_LightWelkynd_256", count = 999 })
					tes3.addItem({ reference = creature, item = "T_Ayl_DngRuin_LightWelkynd_256" })
				end
			end
		end
	end
end

return this