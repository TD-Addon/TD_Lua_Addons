local core = require('openmw.core')
local passwallEffect = core.magic.effects.records['T_mysticism_Passwall']

if not passwallEffect then
    return
end

local I = require('openmw.interfaces')
local types = require('openmw.types')
local world = require('openmw.world')
local l10n = core.l10n('TamrielData')
local magicData = require('MWSE.mods.TamrielData.magicdata')

local passwall_target_effect_model = types.Static.records[passwallEffect.hitStatic].model
local distractedVoices = {}
for _, line in pairs(magicData.distractedVoiceLines) do
    local raceID, isFemale, voicesStart, voicesEnd = unpack(line)
    raceID = raceID:lower()
    distractedVoices[raceID] = distractedVoices[raceID] or {}
    distractedVoices[raceID][isFemale and "female" or "male"] = { voicesStart, voicesEnd }
end
local safeScripts = {}
for k, v in pairs(magicData.safeScripts) do
    safeScripts[k:lower()] = v
end

local function triggerCrimeIfTrespassing(data)
    if not data.targetObject or not data.targetObject.owner or not types.Lockable.isLocked(data.targetObject) then
        return
    end

    if data.targetObject.globalVariable and world.mwscript.getGlobalVariables(data.player)[data.targetObject.globalVariable] ~= 0 then
        return
    end

    local ownerData = data.targetObject.owner

    local isTrespassing =
        ownerData.recordId
        or
        (ownerData.factionId and types.NPC.getFactionRank(data.player, ownerData.factionId) == 0)
        or
        (ownerData.factionId and types.NPC.getFactionRank(data.player, ownerData.factionId) < (ownerData.factionRank or 1))

    if isTrespassing then
        I.Crimes.commitCrime(
            data.player,
            {
                faction = ownerData.factionId,
                type = types.Player.OFFENSE_TYPE.Trespassing
            }
        )
    end
end

local function teleportPlayer(data)
    data.player:teleport(data.cell, data.position, { onGround = true, rotation = data.rotation })

    triggerCrimeIfTrespassing(data)

    world.vfx.spawn(passwall_target_effect_model, data.position)
end

local function resartusEquipment(actor, magnitude, type)
    if magnitude <= 0 then
        return
    end
    local equipment = actor.type.getEquipment(actor)
    local toFix = {}
    for slot, item in pairs(equipment) do
        if type.objectIsInstance(item) then
            local data = types.Item.itemData(item)
            local record = item.type.records[item.recordId]
            local maxHealth = record.health
            local maxCharge = 0
            if record.enchant then
                local enchantment = core.magic.enchantments.records[record.enchant]
                if enchantment then
                    -- FIXME: this is incorrect for autocalc
                    maxCharge = enchantment.charge
                end
            end
            local hasDamage = data.condition and data.condition < maxHealth
            local missingCharge = data.enchantmentCharge and data.enchantmentCharge < maxCharge
            if hasDamage or missingCharge then
                table.insert(toFix, {
                    data = data,
                    hasDamage = hasDamage,
                    missingCharge = missingCharge,
                    maxHealth = maxHealth,
                    maxCharge = maxCharge
                })
            end
        end
    end
    local healthRemaining = magnitude
    local chargeRemaining = magnitude
    while healthRemaining > 0 and chargeRemaining > 0 do
        local changed = false
        for _, data in pairs(toFix) do
            if data.hasDamage and healthRemaining > 0 then
                local health = math.min(data.data.condition + 1, data.maxHealth)
                data.hasDamage = health ~= data.maxHealth
                data.data.condition = health
                healthRemaining = healthRemaining - 1
                changed = true
            end
            if data.missingCharge and chargeRemaining > 0 then
                local charge = math.min(data.data.enchantmentCharge + 1, data.maxCharge)
                data.missingCharge = charge ~= data.maxCharge
                data.data.enchantmentCharge = charge
                chargeRemaining = chargeRemaining - 1
                changed = true
            end
        end
        if not changed then
            break
        end
    end
end

local function playDistractedVoiceLine(data)
    local record = data.actor.type.records[data.actor.recordId]
    local race = distractedVoices[record.race]
    if not race then
        return
    end
    local lines = race[record.isMale and "male" or "female"]
    if lines then
        local files = data.isEnd and lines[2] or lines[1]
        local path = files and files[math.random(#files)]
        if path then
            core.sound.say('sound/' .. path, data.actor)
        end
    end
end

local function canBeCorrupted(target)
    if types.Player.objectIsInstance(target) then
        return false
    end
    local record = target.type.records[target.recordId]
    local script = record.mwscript
    if script and not (script:find("t_scnpc") and not script:find("_were") or safeScripts[script]) then
        return false
    end
    for _, item in pairs(target.type.inventory(target):getAll()) do
        if item.type.records[item.recordId].mwscript then
            return false
        end
    end
    return true
end

local function restoreCharge(item, caster)
    --TODO !3029
    if not item or not I.SpellCasting then
        return
    end
    local charge = I.SpellCasting.getCostCharge(item, caster)
    local data = types.Item.itemData(item)
    --TODO cap
    data.enchantmentCharge = data.enchantmentCharge + charge
end

local function toKey(actor, id, index)
    return actor.id .. ',' .. id .. ',' .. index
end

local state = {
    effects = {}
}

local function store(target, spell, effect)
    local id = spell.activeSpellId
    local index = effect.index
    local key = toKey(target, id, index)
    state.effects[key] = { id = id, index = index, actor = target, magnitude = effect.magnitudeThisFrame, effect = effect.id }
end

local function distract(type)
    return function(target, spell, effect, track)
        if type.objectIsInstance(target) and not types.Player.objectIsInstance(target) then
            target:sendEvent('T_Distract', { magnitude = effect.magnitudeThisFrame, caster = spell.caster })
            store(target, spell, effect)
            track.ignore = false
        else
            target.type.activeEffects(target):remove(effect.id)
        end
    end
end

local onStart = {
    t_mysticism_passwall = function(target, spell, effect, track)
        if types.Player.objectIsInstance(target) then
            track.ignore = false
            target:sendEvent('T_Passwall_Cast', effect.magnitudeThisFrame)
        end
    end,
    t_mysticism_reflectdmg = function(target, spell, effect, track)
        track.ignore = false
    end,
    t_restoration_armorresartus = function(target, spell, effect, track)
        resartusEquipment(target, effect.magnitudeThisFrame, types.Armor)
        track.ignore = false
    end,
    t_restoration_weaponresartus = function(target, spell, effect, track)
        resartusEquipment(target, effect.magnitudeThisFrame, types.Weapon)
        track.ignore = false
    end,
    t_conjuration_corruption = function(target, spell, effect, track)
        if not spell.caster or not spell.caster:isValid() then
            return
        end
        if I.T_SummonMagic.isCorruptionSummon(target) then
            if types.Player.objectIsInstance(spell.caster) then
                spell.caster:sendEvent('ShowMessage', { message = l10n('Magic_corruptionSummon') })
            end
            target.type.activeEffects(target):remove(effect.id)
            restoreCharge(spell.item, spell.caster)
        elseif canBeCorrupted(target) then
            I.T_SummonMagic.setCorruptedId(spell.caster, target.recordId)
            track.ignore = false
            types.Actor.activeSpells(spell.caster):add({ id = 'T_Dae_Cnj_UNI_CorruptionSummon', effects = { 0 }, ignoreResistances = true, ignoreSpellAbsorption = true, ignoreReflect = true, caster = spell.caster })
        else
            if types.Player.objectIsInstance(spell.caster) then
                local record = target.type.records[target.recordId]
                spell.caster:sendEvent('ShowMessage', { message = l10n('Magic_corruptionScript', { target = record.name or record.id }) })
            end
            target.type.activeEffects(target):remove(effect.id)
            restoreCharge(spell.item, spell.caster)
        end
    end,
    t_illusion_distractcreature = distract(types.Creature),
    t_illusion_distracthumanoid = distract(types.NPC),
    t_restoration_fortifycasting = function(target, spell, effect, track)
        local activeEffects = target.type.activeEffects(target)
        activeEffects:modify(-effect.magnitudeThisFrame, 'sound')
        store(target, spell, effect)
        track.ignore = false
    end,
}

local onEnd = {
    t_restoration_fortifycasting = function(effect)
        local activeEffects = effect.actor.type.activeEffects(effect.actor)
        activeEffects:modify(effect.magnitude, 'sound')
    end,
    t_illusion_distractcreature = function(effect)
        effect.actor:sendEvent('T_DistractFinished', effect.effect)
    end,
    t_illusion_distracthumanoid = function(effect)
        effect.actor:sendEvent('T_DistractFinished', effect.effect)
    end
}

I.T_ActorMagic.addEffectStartHandler(function(target, spell, effect, track)
    local handler = onStart[effect.id]
    if handler then
        handler(target, spell, effect, track)
    end
end)

I.T_ActorMagic.addEffectEndHandler(function(actor, id, index)
    local key = toKey(actor, id, index)
    local effect = state.effects[key]
    if effect then
        local handler = onEnd[effect.effect]
        if handler then
            handler(effect)
        end
        state.effects[key] = nil
    end
end)

return {
    engineHandlers = {
        onSave = function()
            return state
        end,
        onLoad = function(data)
            if data then
                state = data
                local effects = {}
                for _, actorData in pairs(data.effects) do
                    if actorData.actor:isValid() then
                        local key = toKey(actorData.actor, actorData.id, actorData.index)
                        effects[key] = actorData
                    end
                end
                state.effects = effects
            end
        end
    },
    eventHandlers = {
        T_Passwall_teleportPlayer = teleportPlayer,
        T_DistractVoice = playDistractedVoiceLine,
    }
}
