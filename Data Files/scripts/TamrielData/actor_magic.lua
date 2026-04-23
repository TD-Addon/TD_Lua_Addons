local core = require('openmw.core')
local I = require('openmw.interfaces')
local self = require('openmw.self')
local auxUtil = require('openmw_aux.util')

local activeEffects = self.type.activeEffects(self)
local activeSpells = self.type.activeSpells(self)

local function calculateReflect(health, fatigue)
    local reflectedHealth = 0
    local reflectedFatigue = 0
    for _, spell in pairs(activeSpells) do
        for _, effect in pairs(spell.effects) do
            if effect.id == 't_mysticism_reflectdmg' then
                local mult = effect.magnitudeThisFrame / 100
                reflectedHealth = reflectedHealth + health * mult
                health = health * (1 - mult)
                reflectedFatigue = reflectedFatigue + fatigue * mult
                fatigue = fatigue * (1 - mult)
            end
        end
    end
    if health <= 0 then
        health = nil
    end
    if fatigue <= 0 then
        fatigue = nil
    end
    if reflectedHealth <= 0 then
        reflectedHealth = nil
    end
    if reflectedFatigue <= 0 then
        reflectedFatigue = nil
    end
    return health, fatigue, reflectedHealth, reflectedFatigue
end

I.Combat.addOnHitHandler(function(attack)
    if not attack.successful or not attack.damage or not attack.attacker or not attack.attacker:isValid() then
        return
    elseif attack.sourceType ~= I.Combat.ATTACK_SOURCE_TYPES.Melee and attack.sourceType ~= I.Combat.ATTACK_SOURCE_TYPES.Ranged then
        return
    end
    local health = attack.damage.health or 0
    local fatigue = attack.damage.fatigue or 0
    if health <= 0 and fatigue <= 0 then
        return
    elseif activeEffects:getEffect('t_mysticism_reflectdmg').magnitude <= 0 then
        return
    end
    local newHealth, newFatigue, reflectedHealth, reflectedFatigue = calculateReflect(health, fatigue)
    local reflectedAttack = auxUtil.shallowCopy(attack)
    reflectedAttack.attacker = self.object
    reflectedAttack.sourceType = I.Combat.ATTACK_SOURCE_TYPES.Unspecified
    reflectedAttack.damage = {}
    if attack.damage.health then
        attack.damage.health = newHealth
        reflectedAttack.damage.health = reflectedHealth
    end
    if attack.damage.fatigue then
        attack.damage.fatigue = newFatigue
        reflectedAttack.damage.fatigue = reflectedFatigue
    end
    attack.attacker:sendEvent('Hit', reflectedAttack)
end)

return {
    engineHandlers = {
        onInactive = function()
            core.sendGlobalEvent('T_ActorInactive', self.object)
        end
    }
}
