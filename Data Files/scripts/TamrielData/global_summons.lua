local types = require('openmw.types')
local world = require('openmw.world')

local startVfx = types.Static.records['VFX_Summon_Start'].model
local endVfx = types.Static.records['VFX_Summon_End'].model

return {
    eventHandlers = {
        T_Summon = function(data)
            local creature = world.createObject(data.creature)
            local caster = data.caster
            creature:teleport(caster.cell.name, data.position, { onGround = true })
            creature:sendEvent('StartAIPackage', { type = 'Follow', target = caster })
            creature:sendEvent('T_MarkSummon', { key = data.key, caster = caster })
            creature:sendEvent('AddVfx', { model = startVfx })
            caster:sendEvent('T_Summoned', { key = data.key, creature = creature })
        end,
        T_Unsummon = function(data)
            data.creature.enabled = false
            world.vfx.spawn(startVfx, data.creature.position)
        end
    }
}
