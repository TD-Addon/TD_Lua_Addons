local core = require('openmw.core')

if core.API_REVISION < 125 then
    return
end

local I = require('openmw.interfaces')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local util = require('openmw.util')

local summons = {
	t_summon_devourer = 't_dae_cre_devourer_01',
	t_summon_dremarch = 't_dae_cre_drem_arch_01',
	t_summon_dremcast = 't_dae_cre_drem_cast_01',
	t_summon_guardian = 't_dae_cre_guardian_01',
	t_summon_lesserclfr = 't_dae_cre_lesserclfr_01',
	t_summon_ogrim = 'ogrim',
	t_summon_seducer = 't_dae_cre_seduc_01',
	t_summon_seducerdark = 't_dae_cre_seducdark_02',
	t_summon_vermai = 't_dae_cre_verm_01',
	t_summon_atrostormmon = 't_dae_cre_monarchst_01',
	t_summon_icewraith = 't_sky_cre_icewr_01',
	t_summon_dwespectre = 'dwarven ghost',
	t_summon_steamcent = 'centurion_steam',
	t_summon_spidercent = 'centurion_spider',
	t_summon_welkyndspirit = 't_ayl_cre_welkspr_01',
	t_summon_auroran = 't_dae_cre_auroran_01',
	t_summon_herne = 't_dae_cre_herne_01',
	t_summon_morphoid = 't_dae_cre_morphoid_01',
	t_summon_draugr = 't_sky_und_drgr_01',
	t_summon_spriggan = 't_sky_cre_spriggan_01',
	t_summon_boneldgr = 't_mw_und_boneldgr_01',
	t_summon_ghost = 't_cyr_und_ghst_01',
	t_summon_wraith = 't_cyr_und_wrth_01',
	t_summon_barrowguard = 't_cyr_und_mum_01',
	t_summon_minobarrowguard = 't_cyr_und_minobarrow_01',
	t_summon_skeletonchampion = 't_glb_und_skelcmpgls_01',
	t_summon_atrofrostmon = 't_dae_cre_monarchfr_01',
	t_summon_spiderdaedra = 't_dae_cre_spiderdae_01',
}

local state = {
    summons = {}
}

local function toKey(id, index)
    return id .. ',' .. index
end

local FRONT = 0
local BACK = 3
local LEFT = 2
local RIGHT = 1
local collisionType = nearby.COLLISION_TYPE.World + nearby.COLLISION_TYPE.Door

local function getSafeSpawn()
    local origin = self.position + util.vector3(0, 0, 20)
    local rotation = util.transform.rotateZ(self.rotation:getYaw())
    for direction = FRONT,BACK do
        local spawn
        if direction == FRONT then
            spawn = origin + rotation:apply(util.vector3(0, 120, 10))
        elseif direction == BACK then
            spawn = origin - rotation:apply(util.vector3(0, 120, 10))
        elseif direction == LEFT then
            spawn = origin - rotation:apply(util.vector3(120, 0, 10))
        elseif direction == RIGHT then
            spawn = origin + rotation:apply(util.vector3(120, 0, 10))
        end
        local result = nearby.castRay(spawn, origin, { collisionType = collisionType })
        if not result.hit then
            return spawn
        end
    end
    return origin
end

I.T_ActorMagic.addEffectStartHandler(function(spell, effect)
    local creature = summons[effect.id]
    if creature == nil then
        return
    end
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(id, index)
    state.summons[key] = { id = id, index = index }
    core.sendGlobalEvent('T_Summon', { key = key, creature = creature, caster = self.object, position = getSafeSpawn() })
end)

I.T_ActorMagic.addEffectEndHandler(function(id, index)
    local key = toKey(id, index)
    local summon = state.summons[key]
    if summon == nil then
        return
    end
    local creature = summon.creature
    if creature and creature:isValid() then
        core.sendGlobalEvent('T_Unsummon', { creature = creature })
    end
    state.summons[key] = nil
end)

return {
    eventHandlers = {
        T_Summoned = function(data)
            local summon = state.summons[data.key]
            if summon == nil then
                summon = {}
                state.summons[data.key] = summon
            end
            summon.creature = data.creature
        end,
        T_SummonDied = function(data)
            local summon = state.summons[data.key]
            if summon ~= nil and summon.id ~= nil and summon.index ~= nil then
                I.T_ActorMagic.removeEffect(summon.id, summon.index)
            end
        end,
        T_MarkSummon = function(data)
            state.caster = data.caster
            state.key = data.key
            self.type.stats.ai.fight(self).base = 30 -- we should probably be using dedicated creature variants
        end,
        Died = function()
            if state.key ~= nil then
                core.sendGlobalEvent('T_Unsummon', { creature = self.object })
                if state.caster:isValid() then
                    state.caster:sendEvent('T_SummonDied', { key = state.key })
                end
            end
        end
    },
    engineHandlers = {
        onSave = function()
            return state
        end,
        onLoad = function(data)
            state = data
        end
    }
}
