local core = require('openmw.core')
local I = require('openmw.interfaces')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local types = require('openmw.types')
local auxUtil = require('openmw_aux.util')

local FT_TO_UNITS = 22.1

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

local function getDistractDestination(caster, range)
    local casterPos = caster and caster.position
    local selfPos = self.position
    local agentBounds = self.type.getPathfindingAgentBounds(self)

    local function getCasterPenalty(candidate)
        if not casterPos then
            return 0
        end
        local status, path = nearby.findPath(selfPos, candidate, { agentBounds = agentBounds })
        local penalty = (candidate - casterPos):length() * 0.25
        if status == nearby.FIND_PATH_STATUS.Success and next(path) then
            local min = math.huge
            for _, point in pairs(path) do
                local distance = (point - casterPos):length2()
                min = math.min(min, distance)
            end
            penalty = penalty + min
        end
        return penalty
    end

    local bestPos = nil
    local bestScore = 0
    local SAMPLES = 12

    for i = 1, SAMPLES do
        local candidate = nearby.findRandomPointAroundCircle(selfPos, range, { agentBounds = agentBounds })
        if candidate and math.abs(candidate.z - selfPos.z) < 384 then
            local score = getCasterPenalty(candidate) + (candidate - selfPos):length() * 0.5
            if score > bestScore then
                bestScore = score
                bestPos = candidate
            end
        end
    end
	return bestPos
end

function playDistractedVoiceLine(isEnd)
    if types.NPC.objectIsInstance(self) and not self.type.isDead(self) and not self.type.isWerewolf(self) and activeEffects:getEffect('Vampirism').magnitude <= 0 then
        -- Handling this in a global script so we only need one instance of the voice lines table in memory
        core.sendGlobalEvent('T_DistractVoice', { actor = self.object, isEnd = isEnd })
    end
end

local state = {}

local timer = 0

return {
    engineHandlers = {
        onInactive = function()
            core.sendGlobalEvent('T_ActorInactive', self.object)
        end,
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data then
                state = data
            end
        end,
        onUpdate = function(dt)
            if not state.distract or not state.distract.returning then
                return
            end
            timer = timer + dt
            if timer >= 1 then
                timer = 0
                local active = I.AI.getActivePackage()
                if not active or active.type ~= 'Travel' then
                    self.type.stats.ai.hello(self).base = state.distract.hello
                    local resetRotation = true
                    if state.distract.wander then
                        resetRotation = state.distract.wander.distance == 0
                        I.AI.startPackage(state.distract.wander)
                    end
                    if resetRotation then
                        local yaw = self.rotation:getYaw()
                        self.controls.yawChange = state.distract.originYaw - yaw
                    end
                    state.distract = nil
                end
            end
        end
    },
    eventHandlers = {
        Died = function()
            state.distract = nil
        end,
        T_Distract = function(data)
            local active = I.AI.getActivePackage()
            if active and active.type ~= 'Wander' then
                return
            end
            local destination = getDistractDestination(data.caster, data.magnitude * FT_TO_UNITS)
            if destination then
                if not state.distract then
                    local hello = self.type.stats.ai.hello(self)
                    state.distract = {
                        hello = hello.base,
                        origin = self.position,
                        originYaw = self.rotation:getYaw(),
                        worldSpace = self.cell.worldSpaceId
                    }
                    if active then
                        state.distract.wander = {
                            type = 'Wander',
                            distance = active.distance,
                            duration = active.duration,
                            idle = active.idle and auxUtil.shallowCopy(active.idle),
                            isRepeat = active.isRepeat
                        }
                    end
                    hello.base = 0
                end
                state.distract.returning = false
                if math.random() < 0.45 then
                    playDistractedVoiceLine(false)
                end
                I.AI.startPackage({ type = 'Travel', destPosition = destination, cancelOther = true, isRepeat = false })
            end
        end,
        T_DistractFinished = function(effect)
            if not state.distract then
                return
            end
            if activeEffects:getEffect(effect).magnitude <= 0 then
                state.distract.returning = true
                if math.random() < 0.45 then
                    playDistractedVoiceLine(true)
                end
                if self.cell and self.cell.worldSpaceId == state.distract.worldSpace then
                    timer = 0
                    I.AI.startPackage({ type = 'Travel', destPosition = state.distract.origin, cancelOther = true, isRepeat = false })
                end
            end
        end
    }
}
