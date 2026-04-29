local core = require('openmw.core')

if not core.magic.effects.records['T_mysticism_Passwall'] then
    return
end
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local types = require('openmw.types')
local util = require('openmw.util')
local Actor = types.Actor

local version_check = require('scripts.TamrielData.utils.version_check')
local magic_passwall = require('scripts.TamrielData.player_magic_passwall')
local magic_blink = require('scripts.TamrielData.actor_magic_blink')

local blinkOn = false
local cachedMagnitude = {
    spell = {},
    item = {}
}

local function getBlinkMagnitude()
    local spell = Actor.getSelectedSpell(self)
    local effects
    local cache
    if spell then
        cache = cachedMagnitude.spell
        if cache.id == spell.id then
            return cache.magnitude
        else
            cache.id = spell.id
            cache.magnitude = nil
        end
        effects = spell.effects
    else
        local item = Actor.getSelectedEnchantedItem(self)
        if not item then
            return
        end
        cache = cachedMagnitude.item
        if cache.id == item.recordId then
            return cache.magnitude
        else
            cache.id = item.recordId
            cache.magnitude = nil
        end
        local record = item.type.records[item.recordId]
        if record.enchant then
            local enchantment = core.magic.enchantments.records[record.enchant]
            effects = enchantment and enchantment.effects
        end
    end
    if not effects then
        return
    end
    for _, effect in pairs(effects) do
        if effect.id == 't_mysticism_blink' and effect.range == core.magic.RANGE.Self then
            cache.magnitude = effect.magnitudeMin
            return cache.magnitude
        end
    end
end

local function showBlinkIndicator()
    -- TODO: switch to RTT/UI
    if Actor.getStance(self) == Actor.STANCE.Spell then
        local magnitude = getBlinkMagnitude()
        if magnitude then
            local destination, _, ground = magic_blink.getBlinkDestination(magnitude)
            local groundPos
            if ground then
                groundPos = util.vector3(destination.x, destination.y, ground + 6)
            else
                groundPos = util.vector3(destination.x, destination.y, destination.z - 7168)
                local result = nearby.castRay(destination, groundPos, { ignore = self })
                if result.hitPos then
                    groundPos = result.hitPos + util.vector3(0, 0, 6)
                end
            end
            local position = util.vector3(destination.x, destination.y, (ground or destination.z) + 24)
            core.sendGlobalEvent('T_BlinkIndicator', { position = position, groundPos = groundPos, actor = self })
            blinkOn = true
            return true
        end
    end
    return false
end

return {
    eventHandlers = {
        T_Passwall_Cast = magic_passwall.onCastPasswall
    },
    engineHandlers = {
        onUpdate = function()
            if version_check.isFeatureEnabled('blinkIndicator') then
                if showBlinkIndicator() then
                    return
                end
            end
            if blinkOn then
                blinkOn = false
                core.sendGlobalEvent('T_BlinkIndicator', { actor = self })
            end
        end
    }
}
