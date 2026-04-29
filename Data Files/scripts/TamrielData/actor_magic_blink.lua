local core = require('openmw.core')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local util = require('openmw.util')

local FT_TO_UNITS = 22.1
local BLINK_COLLISION = nearby.COLLISION_TYPE.AnyPhysical + nearby.COLLISION_TYPE.VisualOnly - nearby.COLLISION_TYPE.Water - nearby.COLLISION_TYPE.Projectile

local function getBlinkDestination(magnitude)
    local range = magnitude * FT_TO_UNITS
    local halfExtents = self.type.getPathfindingAgentBounds(self).halfExtents
    local start = self.position + util.vector3(0, 0, halfExtents.z * 1.4)
    local destination = start + self.rotation * util.vector3(0, range, 0)
    local rayOptions = { ignore = self, collisionType = BLINK_COLLISION }
    local result = nearby.castRay(start, destination, rayOptions)
    local options
    local ground
    if result.hit then
        destination = result.hitPos - self.rotation * util.vector3(0, halfExtents.y + 16, 0)
    end
    local height = util.vector3(0, 0, halfExtents.z * 2)
    result = nearby.castRay(destination, destination + height, rayOptions)
    if result.hit then -- bumped into the ceiling
        local floor = result.hitPos - height
        result = nearby.castRay(result.hitPos, floor, rayOptions)
        if result.hit then -- bumped into the floor; no room here
            destination = self.position
        else
            destination = floor
        end
    end
    if self.cell.isExterior then
        local height = core.land.getHeightAt(destination, self.cell)
        if destination.z < height then
            ground = height
            options = { onGround = true }
        end
    end
    return destination, options, ground
end

return {
    getBlinkDestination = getBlinkDestination
}
