local core = require('openmw.core')

if core.API_REVISION < 125 then
    return
end

local types = require('openmw.types')
local self = require('openmw.self')
local auxUtil = require('openmw_aux.util')

local effectStartHandlers = {}
local effectUpdateHandlers = {}
local effectEndHandlers = {}

local function onEffectStart(spell, effect)
    local track = { ignore = true }
    auxUtil.callEventHandlers(effectStartHandlers, spell, effect, track)
    return track.ignore
end

local function onEffectUpdate(spell, effect)
    local track = { ignore = false }
    auxUtil.callEventHandlers(effectUpdateHandlers, spell, effect, track)
    return track.ignore
end

local function onEffectEnd(id, index)
    auxUtil.callEventHandlers(effectEndHandlers, id, index)
end

local STATE_INIT = 0
local STATE_ACTIVE = 1
local STATE_ONCE = 2
local STATE_IGNORE = 3

local appliedOnce = {}
for _, effect in pairs(core.magic.effects.records) do
    if effect.isAppliedOnce then
        appliedOnce[effect.id] = true
    end
end

local state = {
    delayUpdateChecks = true,
    spells = {}
}

local activeSpells = types.Actor.activeSpells(self)

-- This should all be replaced with built in OpenMW stuff, but that doesn't exist yet. This code cannot track effect lifecycles properly
local function updateEffects()
    state.delayUpdateChecks = true
    local active = {}
    for _, spell in pairs(activeSpells) do
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
                if onEffectStart(spell, effect) then
                    effects[index] = STATE_IGNORE
                else
                    state.delayUpdateChecks = false
                end
            elseif s == STATE_INIT then
                if appliedOnce[effect.id] then
                    effects[index] = STATE_ONCE
                else
                    s = STATE_ACTIVE
                    effects[index] = s
                end
            end
            if s == STATE_ACTIVE then
                if onEffectUpdate(spell, effect) then
                    effects[index] = STATE_IGNORE
                else
                    state.delayUpdateChecks = false
                end
            end
        end
        for index, s in pairs(effects) do
            if activeIndices[index] == nil then
                if s ~= STATE_IGNORE then
                    onEffectEnd(id, index)
                end
                effects[index] = nil
            end
        end
    end
    for id, effects in pairs(state.spells) do
        if active[id] == nil then
            for index, _ in pairs(effects) do
                onEffectEnd(id, index)
            end
            state.spells[id] = nil
        end
    end
end

local function onInit()
    for _, spell in pairs(activeSpells) do
        local effects = {}
        for _, effect in pairs(spell.effects) do
            effects[effect.index] = STATE_IGNORE
        end
        state.spells[spell.activeSpellId] = effects
    end
end

local MAX_WAIT = 0.25
local waited = math.random()

return {
    engineHandlers = {
        onInit = onInit,
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data == nil then
                onInit()
            else
                state = data
            end
        end,
        onUpdate = function(dt)
            if state.delayUpdateChecks then
                waited = waited + dt
                if waited < MAX_WAIT then
                    return
                else
                    waited = waited - MAX_WAIT
                end
            end
            updateEffects()
        end,
        onInactive = updateEffects
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
        removeEffect = function(id, index)
            -- This isn't possible and this implementation is slightly wrong, but it's better than nothing
            local effects = state.spells[id]
            if effects == nil then
                return
            end
            for i, _ in pairs(effects) do
                if i ~= index then
                    return
                end
            end
            activeSpells:remove(id)
        end
    }
}
