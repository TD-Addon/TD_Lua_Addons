local types = require('openmw.types')
local util = require('openmw.util')
local world = require('openmw.world')

local distance = util.vector3(0, 120, 0)

local startVfx = types.Static.records['VFX_Summon_Start'].model
local endVfx = types.Static.records['VFX_Summon_End'].model

return {
    eventHandlers = {
        T_Summon = function(data)
            local creature = world.createObject(data.creature)
            local caster = data.caster
            local position = caster.rotation:apply(distance) + caster.position
            creature:teleport(caster.cell.name, position, { onGround = true, rotation = caster.rotation })
            creature:sendEvent('StartAIPackage', { type = 'Follow', target = caster })
            creature:sendEvent('T_MarkSummon', { key = data.key, caster = caster })
            caster:sendEvent('T_Summoned', { key = data.key, creature = creature })
            world.vfx.spawn(startVfx, position)
        end,
        T_Unsummon = function(data)
            data.creature.enabled = false
            world.vfx.spawn(startVfx, data.creature.position)
        end
    }
}
