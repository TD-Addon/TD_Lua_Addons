if not require("scripts.TamrielData.utils.version_check").isFeatureSupported("miscSpells") then
    return
end

local self = require('openmw.self')
local types = require('openmw.types')
local ui = require('openmw.ui')
local core = require('openmw.core')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local l10n = core.l10n("TamrielData")
local settings = require("scripts.TamrielData.utils.settings")
local debug = require("scripts.TamrielData.utils.debug_logging")

local FT_TO_UNITS = 22.1
local maxSpellDistance = 25 * FT_TO_UNITS -- 25ft is a default Passwall spell range in the MWSE version
local passwallSpellId = "t_com_mys_uni_passwall"

local function getActivationVector()
    -- Camera direction cast on a XY plane
    local cameraVector = camera.viewportToWorldVector(util.vector2(0.5, 0.5))
    return util.vector3(cameraVector.x, cameraVector.y, 0.0):normalize()
end

local function getActivationDistance()
    return core.getGMST("iMaxActivateDist") + 0.1
end

local function getRaycastingInputData()
    local activationVector = getActivationVector()
    local activateDistance = getActivationDistance()
    local playerBoundingBox = self:getBoundingBox()

    -- castPosition as in MWSE version
    local castPosition = playerBoundingBox.center.z - playerBoundingBox.halfSize.z + (2 * playerBoundingBox.halfSize.z * 0.7)

    return {
        startPos = util.vector3(playerBoundingBox.center.x, playerBoundingBox.center.y, castPosition),
        directionVector = activationVector,
        activateDistance = activateDistance
    }
end

local function startTeleporting(newPosition, newCell, newRotation, targetObject)
    core.sendGlobalEvent("T_Passwall_teleportPlayer",
    {
        player = self,
        position = newPosition,
        cell = newCell,
        rotation = newRotation,
        targetObject = targetObject
    })
end

local function isDoorForbiddenFromPasswall(object)
    local recordName = types.Door.records[object.recordId].name
    local forbiddenDoorNames = { "Trap", "Cell", "Tent", "Grate", "Bearskin", "Mystical", "Skyrender" }
    for _, value in pairs(forbiddenDoorNames) do
        if recordName:find(value) then
            return true
        end
    end
    return false
end

local function handleAsDoor(object)
    local doorHandled = false
    if types.Door.objectIsInstance(object) then
        if types.Door.isTeleport(object) then
            local destCell = types.Door.destCell(object)
            if destCell.isExterior or destCell.isQuasiExterior then
                ui.showMessage(l10n("TamrielData_magic_passwallDoorExterior"))
            else
                local destPos = types.Door.destPosition(object)
                local destRotation = types.Door.destRotation(object)
                startTeleporting(destPos, destCell.name, destRotation, object)
            end
            doorHandled = true
        elseif isDoorForbiddenFromPasswall(object) then
            debug.log(
                string.format("Door '%s' is forbidden from being passed by a Passwall spell", object.recordId),
                passwallSpellId
            )
            doorHandled = true
        end
    end
    return doorHandled
end

local function isObjectReachable(from, targetObject)
    local to = targetObject:getBoundingBox().center

    if (from - to):length() > 1024 then -- Probably no need to look for further objects
        return false
    end

    -- Find a walkable navmesh path to the object
    local status, path = nearby.findPath(
        from,
        to,
        { includeFlags = nearby.NAVIGATOR_FLAGS.Walk, destinationTolerance = 0.0 })

    if status == nearby.FIND_PATH_STATUS.Success or status == nearby.FIND_PATH_STATUS.PartialPath then
        -- Even though a navmesh path is found, it still could have hopped through an obstacle,
        -- so try a raycast - if it doesn't collide with anything else, we could assume the object is reachable
        local lastRayCheck = nearby.castRay(
            path[#path],
            to,
            { collisionType = nearby.COLLISION_TYPE.AnyPhysical + nearby.COLLISION_TYPE.VisualOnly })

        -- However, the raycast doesn't work on some objects, like items. Last chance check is just a distance one.
        -- If points are very close, we could assume the player can go from one to another.
        -- For this check it seems that comparing the distance with the bottom of the targetObject yields best results.
        local veryClose = 11 -- an arbitrary value representing a close enough object that no wall is between
        local isObjectVeryClose = util.vector3(
            to.x - path[#path].x,
            to.y - path[#path].y,
            to.z - path[#path].z - targetObject:getBoundingBox().halfSize.z
        ):length() < veryClose

        local lastCheckResult = (lastRayCheck.hitObject and lastRayCheck.hitObject == targetObject) or isObjectVeryClose
        return lastCheckResult
    end

    return false
end

local function isBlockedByWard(object)
    local isWardPresent = object.recordId:find("t_aid_passwallward_")
    if isWardPresent then
        ui.showMessage(l10n("TamrielData_magic_passwallWard"))
    end
    return isWardPresent
end

local function isBlockedByIllegalActivator(object)
    if not types.Activator.objectIsInstance(object) then
        return false
    end
    local objectRecord = types.Activator.records[object.recordId]

    local forbiddenModels = { "force", "gg_", "water", "blight", "_grille_", "field", "editormarker", "barrier",
        "_portcullis_", "bm_ice_wall", "_mist", "_web", "_cryst", "collision", "grate", "shield", "smoke",
        "Ex_colony_ouside_tend01", "akula", "act_sotha_green", "act_sotha_red", "lava", "bug", "clearbox" }
    for _, value in pairs(forbiddenModels) do
        if objectRecord.model:find(value) then
            ui.showMessage(l10n("TamrielData_magic_passwallAlpha"))
            debug.log(
                string.format("Object '%s' (%s) is an illegal activator you can't pass through with Passwall.", object.recordId, objectRecord.model),
                passwallSpellId
            )
            return true
        end
    end
    return false
end

local function isObjectInstanceOfOneOfTheTypes(object, types)
    for _, type in pairs(types) do
        if type.objectIsInstance(object) then
            return true
        end
    end
    return false
end

local function findAReachableObjectFromPositionOutOf(startPosition, listOfObjects, exclusions)
    for _, object in pairs(listOfObjects) do
        if not isObjectInstanceOfOneOfTheTypes(object, exclusions) then
            if isObjectReachable(startPosition, object) then
                return object
            end
        end
    end
    return nil
end

local function findAReachableItemFromPosition(startPosition)
    -- If no other check passed until now, then perhaps there is nothing of interest except items in that area.
    -- In that case a reachable item hopefully is close by, so no need for far checks.

    -- lights are excluded from checking, because their radius often bleeds through walls and floors, leading to false positives
    local excludedItemTypes = {types.Light}

    for _, object in pairs(nearby.items) do
        if (startPosition - object:getBoundingBox().center):length() <= maxSpellDistance then
            if not isObjectInstanceOfOneOfTheTypes(object, excludedItemTypes) then
                if isObjectReachable(startPosition, object) then
                    return object
                end
            end
        end
    end
    return nil
end

local function isCalculatedPositionIntendedForThePlayer(position)
    if not position then
        return false
    end
    -- Look for any "useful" object that is reachable via navmesh from this position.
    -- If there is one, we could assume that the position was intended to be reachable by the player.
    local foundObject = findAReachableObjectFromPositionOutOf(position, nearby.doors, {})
    or findAReachableObjectFromPositionOutOf(position, nearby.actors, {types.Player})
    or findAReachableObjectFromPositionOutOf(position, nearby.activators, {})
    or findAReachableObjectFromPositionOutOf(position, nearby.containers, {})
    or findAReachableItemFromPosition(position)
    return foundObject ~= nil
end

local function isRayHitOnBlocker(rayHit)
    local object = rayHit.hitObject
    return isBlockedByWard(object) or isBlockedByIllegalActivator(object)
end

local function calculatePasswallPosition(intermediateRayHits, limitingPosition, directionVector)
    local rayTestOffset = 19 -- We could say that a 2*19 square is enough to fit the player in
    local minDistance = 108 -- minDistance from the MWSE version
    local maxZDifference = 105 -- upCoord from the MWSE version

    for i = 1, #intermediateRayHits do
        local thisRayHit = intermediateRayHits[i]

        if isRayHitOnBlocker(thisRayHit) then
            return nil
        end

        local nextPosition = limitingPosition
        if i < #intermediateRayHits then
            nextPosition = intermediateRayHits[i+1].hitPos
        end

        local distanceToNext = (nextPosition - thisRayHit.hitPos):length()
        local potentialPosition = thisRayHit.hitPos + directionVector * rayTestOffset

        while distanceToNext >= rayTestOffset * 2 do
            local navMeshPosition = nearby.findNearestNavMeshPosition(
                potentialPosition,
                {
                    includeFlags = nearby.NAVIGATOR_FLAGS.Walk,
                    searchAreaHalfExtents = util.vector3(100, 100, maxZDifference*10) -- fewer calculations when passwalling around corners
                }
            )
            if navMeshPosition == nil then
                break
            end

            local isPositionNotTooClose = (self.position - navMeshPosition):length() >= (minDistance)
            local isPositionNotTooHighOrLow = math.abs(self.position.z - navMeshPosition.z) < maxZDifference
            local isPositionInsideLimits = isPositionNotTooClose and isPositionNotTooHighOrLow
            local isIntendedForThePlayer = isCalculatedPositionIntendedForThePlayer(navMeshPosition)
            if isPositionInsideLimits and isIntendedForThePlayer then
                return navMeshPosition
            else
                potentialPosition = potentialPosition + directionVector * rayTestOffset
                distanceToNext = (nextPosition - potentialPosition):length()
            end
        end

    end

    return nil
end

local function gatherAllRayHitsAndLimitingPosition(raycastingInputData, firstRaycastHit)
    local remainingTeleportDistance = maxSpellDistance
    local intermediateRayHits = {firstRaycastHit}
    local limitingPosition = firstRaycastHit.hitPos + raycastingInputData.directionVector * maxSpellDistance

    local previousRaycastSourceObjects = {firstRaycastHit.hitObject}
    while remainingTeleportDistance > 0 do
        local prevHit = intermediateRayHits[#intermediateRayHits]
        table.insert(previousRaycastSourceObjects, prevHit.hitObject)
        local thisRaycastEnd = prevHit.hitPos + raycastingInputData.directionVector * remainingTeleportDistance
        local thisHit = nearby.castRay(
            prevHit.hitPos,
            thisRaycastEnd,
            { ignore = previousRaycastSourceObjects })
        if thisHit.hitObject then
            table.insert(intermediateRayHits, thisHit)
            remainingTeleportDistance = remainingTeleportDistance - (thisHit.hitPos - prevHit.hitPos):length()
        else
            remainingTeleportDistance = -1
        end
    end

    return intermediateRayHits, limitingPosition
end

local function finishPasswall()
    core.sendGlobalEvent("T_magic_spellHandlingFinished", { spellId = passwallSpellId })
end

local PSW = {}

function PSW.onCastPasswall()
    if not settings.isFeatureEnabled["miscSpells"]() then
        return finishPasswall()
    end

    for _, spell in pairs(types.Actor.activeSpells(self)) do
        if spell.id == passwallSpellId then
            types.Actor.activeSpells(self):remove(spell.activeSpellId)
        end
    end

    debug.log(
        string.format(
            "START: pos:%s, cell:%s, rotation:%s, race:%s, isMale:%s",
            self.position,
            self.cell,
            self.rotation,
            types.NPC.record(self).race,
            types.NPC.record(self).isMale
        ),
        passwallSpellId
    )

    if self.cell.isExterior then
        ui.showMessage(l10n("TamrielData_magic_passwallExterior"))
        return finishPasswall()
    elseif types.Actor.isSwimming(self) then
        ui.showMessage(l10n("TamrielData_magic_passwallUnderwater"))
        return finishPasswall()
    elseif not types.Player.isTeleportingEnabled(self) then
        ui.showMessage(core.getGMST("sTeleportDisabled"))
        return finishPasswall()
    end

    local raycastingInputData = getRaycastingInputData()
    local raycastingEnd = raycastingInputData.startPos + raycastingInputData.directionVector * raycastingInputData.activateDistance

    local firstRaycastHit = nearby.castRay(
        raycastingInputData.startPos,
        raycastingEnd,
        {
            ignore = self,
            collisionType =nearby.COLLISION_TYPE.AnyPhysical + nearby.COLLISION_TYPE.VisualOnly
        })

    if not firstRaycastHit.hitObject or isRayHitOnBlocker(firstRaycastHit) then
        debug.log("No target detected on spell cast.", passwallSpellId)
        return finishPasswall()
    end

    local targetObject = firstRaycastHit.hitObject

    if not (types.Static.objectIsInstance(targetObject) or types.Activator.objectIsInstance(targetObject) or types.Door.objectIsInstance(targetObject)) then
        debug.log(
            string.format("Object '%s' is not a legal spell target. You need to hit an activator or a static or a door.", targetObject.recordId),
            passwallSpellId
        )
        return finishPasswall()
    end

    if handleAsDoor(targetObject) then
        return finishPasswall()
    end

    local hitObjectHalfHeight = targetObject:getBoundingBox().halfSize.z
    local minObstacleHeight = 93 -- MWSE version uses 96, but In_impsmall_d_hidden_01 needs these additional 3 points in OpenMW
    if hitObjectHalfHeight < minObstacleHeight then
        debug.log(string.format("Object '%s' height (%s) is too low for Passwall (need %s).", targetObject.recordId, hitObjectHalfHeight, minObstacleHeight), passwallSpellId)
        return finishPasswall()
    end

    local intermediateRayHits, limitingPosition = gatherAllRayHitsAndLimitingPosition(raycastingInputData, firstRaycastHit)
    -- intermediateRayHits include the first raycast hit (a spell target object, i.e. wall) as element [1]
    -- limitingPosition is the max distance the spell could reach: should be farther from the player than (or as far as) all intermediateRayHits

    local finalTeleportPosition = calculatePasswallPosition(intermediateRayHits, limitingPosition, raycastingInputData.directionVector)

    if finalTeleportPosition then
        startTeleporting(finalTeleportPosition, self.cell.name, self.rotation, targetObject)
    else
        debug.log(
            "No valid teleport position for Passwall found",
            passwallSpellId
        )
    end
    finishPasswall()
end

return PSW