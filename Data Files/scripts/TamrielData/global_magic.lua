local core = require('openmw.core')

if core.API_REVISION < 125 then
    return
end

local types = require('openmw.types')
local world = require('openmw.world')
local auxUtil = require('openmw_aux.util')

local effectStartHandlers = {}
local effectUpdateHandlers = {}
local effectEndHandlers = {}

local function onEffectStart(actor, spell, effect)
    local track = { ignore = true }
    auxUtil.callEventHandlers(effectStartHandlers, actor, spell, effect, track)
    return track.ignore
end

local function onEffectUpdate(actor, spell, effect)
    local track = { ignore = false }
    auxUtil.callEventHandlers(effectUpdateHandlers, actor, spell, effect, track)
    return track.ignore
end

local function onEffectEnd(actor, id, index)
    auxUtil.callEventHandlers(effectEndHandlers, actor, id, index)
end

local STATE_INIT = 0
local STATE_ACTIVE = 1
local STATE_ONCE = 2
local STATE_IGNORE = 3

local MAX_WAIT = 0.25

local appliedOnce = {}
for _, effect in pairs(core.magic.effects.records) do
    if effect.isAppliedOnce then
        appliedOnce[effect.id] = true
    end
end

local persistentState = {
    actors = {}
}
local tempState = {}

local function initActorState(actor, state)
    local activeSpells = types.Actor.activeSpells(actor)
    for _, spell in pairs(activeSpells) do
        local effects = {}
        for _, effect in pairs(spell.effects) do
            effects[effect.index] = STATE_IGNORE
        end
        state.spells[spell.activeSpellId] = effects
    end
    return {
        waited = math.random() * MAX_WAIT,
        activeSpells = activeSpells
    }
end

local function deleteActorState(actor)
    local id = actor.id
    persistentState.actors[id] = nil
    tempState[id] = nil
end

local function getActorState(actor, init)
    local id = actor.id
    local state = persistentState.actors[id]
    if not state then
        if not init then
            return nil
        end
        state = {
            delayUpdateChecks = true,
            spells = {},
            actor = actor
        }
        persistentState.actors[id] = state
        tempState[id] = initActorState(actor, state)
    elseif not tempState[id] then
        tempState[id] = {
            waited = math.random() * MAX_WAIT,
            activeSpells = types.Actor.activeSpells(actor)
        }
    end
    return state, tempState[id]
end

-- This should all be replaced with built in OpenMW stuff, but that doesn't exist yet. This code cannot track effect lifecycles properly
local function updateEffects(actor, state, tempState)
    local canDiscard = true
    state.delayUpdateChecks = true
    local active = {}
    for _, spell in pairs(tempState.activeSpells) do
        local id = spell.activeSpellId
        active[id] = true
        local effects = state.spells[id]
        if effects == nil then
            effects = {}
            state.spells[id] = effects
        end
        local activeIndices = {}
        for _, effect in pairs(spell.effects) do
            local index = effect.index
            activeIndices[index] = true
            local s = effects[index]
            if s == nil then
                effects[index] = STATE_INIT
                if onEffectStart(actor, spell, effect) then
                    effects[index] = STATE_IGNORE
                else
                    state.delayUpdateChecks = false
                    canDiscard = false
                end
            elseif s == STATE_INIT then
                if appliedOnce[effect.id] then
                    effects[index] = STATE_ONCE
                    canDiscard = false
                else
                    s = STATE_ACTIVE
                    effects[index] = s
                end
            elseif s == STATE_ONCE then
                canDiscard = false
            end
            if s == STATE_ACTIVE then
                if onEffectUpdate(actor, spell, effect) then
                    effects[index] = STATE_IGNORE
                else
                    state.delayUpdateChecks = false
                    canDiscard = false
                end
            end
        end
        for index, s in pairs(effects) do
            if activeIndices[index] == nil then
                if s ~= STATE_IGNORE then
                    onEffectEnd(actor, id, index)
                end
                effects[index] = nil
            end
        end
    end
    for id, effects in pairs(state.spells) do
        if active[id] == nil then
            for index, s in pairs(effects) do
                if s ~= STATE_IGNORE then
                    onEffectEnd(actor, id, index)
                end
            end
            state.spells[id] = nil
        end
    end
    return canDiscard
end

local function waitOrUpdate(actor, dt)
    local state, tempState = getActorState(actor, true)
    if state.delayUpdateChecks then
        tempState.waited = tempState.waited + dt
        if tempState.waited < MAX_WAIT then
            return
        else
            tempState.waited = tempState.waited - MAX_WAIT
        end
    end
    updateEffects(actor, state, tempState)
end

local activeActors = world.activeActors

return {
    engineHandlers = {
        onSave = function()
            return persistentState
        end,
        onLoad = function(data)
            if data then
                persistentState = data
                local actors = {}
                for id, actorData in pairs(data.actors) do
                    if actorData.actor:isValid() then
                        actors[actorData.actor.id] = actorData
                    end
                end
                persistentState.actors = actors
            end
        end,
        onUpdate = function(dt)
            for _, actor in pairs(activeActors) do
                waitOrUpdate(actor, dt)
            end
        end
    },
    eventHandlers = {
        T_ActorInactive = function(actor)
            local state, tempState = getActorState(actor, false)
            if not state then
                return
            end
            local discard = updateEffects(actor, state, tempState)
            if discard then
                deleteActorState(actor)
            end
        end
    },
    interfaceName = 'T_ActorMagic',
    interface = {
        version = 1,
        addEffectStartHandler = function(handler)
            effectStartHandlers[#effectStartHandlers + 1] = handler
        end,
        addEffectUpdateHandler = function(handler)
            effectUpdateHandlers[#effectUpdateHandlers + 1] = handler
        end,
        addEffectEndHandler = function(handler)
            effectEndHandlers[#effectEndHandlers + 1] = handler
        end,
        removeEffect = function(actor, id, index)
            -- This isn't possible and this implementation is slightly wrong, but it's better than nothing
            local state, tempState = getActorState(actor, false)
            if not state then
                return
            end
            local effects = state.spells[id]
            if effects == nil then
                return
            end
            for i, _ in pairs(effects) do
                if i ~= index then
                    return
                end
            end
            tempState.activeSpells:remove(id)
        end
    }
}
