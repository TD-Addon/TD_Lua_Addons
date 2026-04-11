local content = require('openmw.content')
local core = require('openmw.core')
local magicData = require('MWSE.mods.TamrielData.magicdata')
local version_check = require('scripts.TamrielData.utils.version_check')

local l10n = core.l10n('TamrielData')

local function t(key)
    if not key then
        return ''
    end
    return l10n('Magic_' .. key)
end

local function replaceSpells(table)
    local types = {
        spell = content.spells.TYPE.Spell,
        ability = content.spells.TYPE.Ability,
        blight = content.spells.TYPE.Blight,
        disease = content.spells.TYPE.Disease,
        curse = content.spells.TYPE.Curse,
        power = content.spells.TYPE.Power,
    }
    local range = {
        self = content.RANGE.Self,
        touch = content.RANGE.Touch,
        target = content.RANGE.Target
    }
    local spells = content.spells.records
    for _, values in pairs(table) do
        local id = values[1]
        local type = values[2]
        local name = values[3]
        local cost = values[4]
        local effects = {}
        for i = 1,8 do
            local row = values[4 + i]
            if not row then
                break
            end
            effects[i] = row
            row.range = range[row.range]
        end
        local spell = spells[id]
        if spell then
            if cost then
                spell.cost = cost
            end
            spell.type = types[type]
            if name then
                spell.name = t(name)
            end
            spell.effects = effects
        end
    end
end

local function addSummons()
    local effects = content.magicEffects.records
    for _, values in pairs(magicData.td_summon_effects) do
        local id, name, creature, cost, icon, description, template = unpack(values)
        if template == 'callBear' then
            template = 'summonbear'
        end
        effects[id] = { template = effects[template], cost = cost, icon = icon, name = t(name), description = t(desc), allowsSpellmaking = true, allowsEnchanting = true }
    end
end

return {
    engineHandlers = {
        onContentFilesLoaded = function()
            if version_check.isFeatureEnabled('summoningSpells') then
                addSummons()
                replaceSpells(magicData.td_summon_spells)
            end
        end
    }
}
