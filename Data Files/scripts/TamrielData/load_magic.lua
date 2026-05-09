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

local implementedEffects = {}
local RANGE = {
    self = content.RANGE.Self,
    touch = content.RANGE.Touch,
    target = content.RANGE.Target
}

local function parseEffects(values, offset)
    local effects = {}
    local implemented = true
    for i = 1,8 do
        local row = values[offset + i]
        if not row then
            break
        end
        if not implementedEffects[row.id] then
            implemented = false
            break
        end
        effects[i] = row
        if row.id == 'T_mysticism_Passwall' then
            row.range = RANGE.self
            row.magnitudeMin = row.area
            row.magnitudeMax = row.area
            row.area = nil
        else
            row.range = RANGE[row.range]
            row.magnitudeMin = row.min or row.magnitude
            row.magnitudeMax = row.max or row.magnitude
        end
        row.min = nil
        row.max = nil
        row.magnitude = nil
    end
    return implemented, effects
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
    local spells = content.spells.records
    for _, values in pairs(table) do
        local id = values[1]
        local type = values[2]
        local name = values[3]
        local cost = values[4]
        local implemented, effects = parseEffects(values, 4)
        local spell = spells[id]
        if spell and implemented then
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

local modifiedEnchantments = {}

local function replaceEnchantments(table)
    local types = {
        castOnce = content.enchantments.TYPE.CastOnce,
        onStrike = content.enchantments.TYPE.CastOnStrike,
        onUse = content.enchantments.TYPE.CastOnUse,
        constant = content.enchantments.TYPE.ConstantEffect,
    }
    local enchantments = content.enchantments.records
    for _, values in pairs(table) do
        local id = values[1]
        local type = values[2]
        local implemented, effects = parseEffects(values, 2)
        local enchantment = enchantments[id]
        if enchantment and implemented then
            modifiedEnchantments[enchantment.id] = true
            enchantment.type = types[type]
            enchantment.effects = effects
        end
    end
end

local function replacePotions(table)
    local potions = content.potions.records
    for _, values in pairs(table) do
        local id = values[1]
        local name = values[2]
        local implemented, effects = parseEffects(values, 2)
        local potion = potions[id]
        if potion and implemented then
            if name then
                potion.name = t(name)
            end
            potion.effects = effects
        end
    end
end

local enchantableTypes = { 'armor', 'books', 'clothes', 'weapons' }

local function getItem(id)
    for _, type in pairs(enchantableTypes) do
        local c = content[type]
        if c then
            local item = c.records[id]
            if item then
                return item
            end
        end
    end
end

local function editItems(table)
    for _, values in pairs(table) do
        local id = values[1]
        local name = values[2]
        local value = values[3]
        local item = getItem(id)
        if item and modifiedEnchantments[item.enchant] then
            if name then
                item.name = t(name)
            end
            if value then
                item.value = value
            end
        end
    end
end

local function replaceIngredients(table)
    local ingredients = content.ingredients.records
    for _, values in pairs(table) do
        local id = values[1]
        local ingredient = ingredients[id]
        if ingredient then
            for i = 1,4 do
                local row = values[i + 1]
                if row and implementedEffects[row.id] then
                    local effect = ingredient.effects[i]
                    effect.id = row.id
                    effect.affectedAttribute = row.attribute
                    effect.affectedSkill = row.skill
                end
            end
        end
    end
end

local function addSummons()
    local effects = content.magicEffects.records
    for _, values in pairs(magicData.td_summon_effects) do
        local id, name, creature, cost, icon, desc, template = unpack(values)
        if template == 'callBear' then
            template = 'summonbear'
        end
        effects[id] = { template = effects[template], baseCost = cost, icon = icon, name = t(name), description = t(desc), allowsSpellmaking = true, allowsEnchanting = true }
        implementedEffects[id] = true
    end
end

local function addMiscEffects()
    local effects = content.magicEffects.records
    local function addMiscEffect(id, params)
        local name, cost, icon, desc, template = unpack(magicData.td_misc_effects[id])
        params.name = t(name)
        params.baseCost = params.baseCost or cost
        params.icon = icon
        params.description = t(desc)
        params.template = effects[template]
        effects[id] = params
        implementedEffects[id] = true
    end
    addMiscEffect('T_mysticism_Passwall', {
        onTarget = false, onTouch = false, hasDuration = false,
        baseCost = magicData.td_misc_effects.T_mysticism_Passwall[2] * 0.5 -- compensate for MWSE using area instead of magnitude
    })
    addMiscEffect('T_mysticism_BanishDae', {
        hasDuration = false, hasMagnitude = true, unreflectable = true, hitSound = 'T_SndObj_Silence',
        hitStatic = 'T_VFX_Empty', areaSound = 'T_SndObj_Silence', areaStatic = 'T_VFX_Empty', harmful = false
    })
    addMiscEffect('T_mysticism_ReflectDmg', {})
    --addMiscEffect('T_mysticism_DetHuman', {}) -- Requires map dehardcoding
    --addMiscEffect('T_alteration_RadShield', {}) -- Requires a (more elegant) way of applying variable magnitude blind effects
    addMiscEffect('T_alteration_Wabbajack', {
        allowsSpellmaking = false, allowsEnchanting = false, hasDuration = false, onSelf = false, onTarget = true,
        onTouch = true, harmful = true, unreflectable = true, hitSound = 'T_SndObj_Silence', hitStatic = 'T_VFX_Empty',
        areaSound = 'T_SndObj_Silence', areaStatic = 'T_VFX_Empty'
    })
    addMiscEffect('T_alteration_WabbajackHelper', {
        isAppliedOnce = false, allowsSpellmaking = false, allowsEnchanting = false, onSelf = false, onTarget = true,
        onTouch = true, unreflectable = true, hitSound = 'T_SndObj_Silence', hitStatic = 'T_VFX_Empty'
    })
    addMiscEffect('T_restoration_ArmorResartus', { hasDuration = false })
    addMiscEffect('T_restoration_WeaponResartus', { hasDuration = false })
    addMiscEffect('T_conjuration_Corruption', {
        allowsSpellmaking = false, allowsEnchanting = false, hasDuration = false, onSelf = false,
        onTarget = true, onTouch = true, harmful = true, unreflectable = true
    })
    addMiscEffect('T_conjuration_CorruptionSummon', { allowsSpellmaking = false, allowsEnchanting = false })
    addMiscEffect('T_illusion_DistractCreature', { unreflectable = true, onSelf = false, harmful = false })
    addMiscEffect('T_illusion_DistractHumanoid', { unreflectable = true, onSelf = false, harmful = false })
    addMiscEffect('T_mysticism_Blink', { hasDuration = false, hitSound = 'T_SndObj_BlinkHit', hitStatic = 'T_VFX_Empty' })
    addMiscEffect('T_restoration_FortifyCasting', {})
    addMiscEffect('T_conjuration_SanguineRose', { allowsSpellmaking = false, allowsEnchanting = false })
end

return {
    engineHandlers = {
        onContentFilesLoaded = function()
            if version_check.isFeatureEnabled('summoningSpells') then
                addSummons()
            end
            if version_check.isFeatureEnabled('miscSpells') then
                addMiscEffects()
            end
            replaceSpells(magicData.td_summon_spells)
            replaceSpells(magicData.td_misc_spells)
            replaceEnchantments(magicData.td_enchantments)
            editItems(magicData.td_enchanted_items)
            replacePotions(magicData.td_potions)
            replaceIngredients(magicData.td_ingredients)
        end
    }
}
