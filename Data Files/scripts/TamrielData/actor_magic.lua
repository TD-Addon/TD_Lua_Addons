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
    auxUtil.callEventHandlers(effectStartHandlers, spell, effect)
end

local function onEffectUpdate(spell, effect)
    auxUtil.callEventHandlers(effectUpdateHandlers, spell, effect)
end

local function onEffectEnd(id, index)
    auxUtil.callEventHandlers(effectEndHandlers, id, index)
end

local STATE_INIT = 0
local STATE_ACTIVE = 1
local STATE_ONCE = 2

local appliedOnce = {}
for _, effect in pairs(core.magic.effects.records) do
    if effect.isAppliedOnce then
        appliedOnce[effect.id] = true
    end
end

local state

local activeSpells = types.Actor.activeSpells(self)

-- This should all be replaced with built in OpenMW stuff, but that doesn't exist yet. This code cannot track effect lifecycles properly
local function updateEffects()
    local active = {}
    for _, spell in pairs(activeSpells) do
        local id = spell.activeSpellId
        active[id] = true
        local effects = state[id]
        if effects == nil then
            effects = {}
            state[id] = effects
            for _, effect in pairs(spell.effects) do
                effects[effect.index] = STATE_INIT
                onEffectStart(spell, effect)
            end
        else
            local activeIndices = {}
            for _, effect in pairs(spell.effects) do
                local index = effect.index
                activeIndices[index] = true
                local s = effects[index]
                if s == nil then
                    effects[index] = STATE_INIT
                    onEffectStart(spell, effect)
                elseif s == STATE_INIT then
                    if appliedOnce[effect.id] then
                        effects[index] = STATE_ONCE
                    else
                        s = STATE_ACTIVE
                        effects[index] = s
                    end
                end
                if s == STATE_ACTIVE then
                    onEffectUpdate(spell, effect)
                end
            end
            for index, _ in pairs(effects) do
                if activeIndices[index] == nil then
                    onEffectEnd(id, index)
                    effects[index] = nil
                end
            end
        end
    end
    for id, effects in pairs(state) do
        if active[id] == nil then
            for index, _ in pairs(effects) do
                onEffectEnd(id, index)
            end
            state[id] = nil
        end
    end
end

local function onInit()
    state = {}
    for _, spell in pairs(activeSpells) do
        local effects = {}
        for _, effect in pairs(spell.effects) do
            effects[effect.index] = STATE_INIT
        end
        state[spell.activeSpellId] = effects
    end
end

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
        onUpdate = updateEffects
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
            local effects = state[id]
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
