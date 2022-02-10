tes3.claimSpellEffectId("TR_summonDevourer", 20901)
tes3.claimSpellEffectId("TR_summonDremArch", 20902)
tes3.claimSpellEffectId("TR_summonDremCast", 20903)
tes3.claimSpellEffectId("TR_summonGuardian", 20904)
tes3.claimSpellEffectId("TR_summonLesserClfr", 20905)
tes3.claimSpellEffectId("TR_summonSeducer", 20906)
tes3.claimSpellEffectId("TR_summonSeducDark", 20907)
tes3.claimSpellEffectId("TR_summonVerm", 20908)
tes3.claimSpellEffectId("TR_summonAtroStormMon", 20909)

-- unique id, name, creature, spell cost, effect cost (for spellmaking)
local tr_summons = {	
{ 20901, "Summon Devourer", "T_Dae_Cre_Devourer_01", 1, 1},
{ 20902, "Summon Dremora Sharpshooter", "T_Dae_Cre_Drem_Arch_01", 1, 1 },
{ 20903, "Summon Dremora Spellcaster", "T_Dae_Cre_Drem_Cast_01", 1, 1 },
{ 20904, "Summon Guardian", "T_Dae_Cre_Guardian_01", 1, 1 },
{ 20905, "Summon Rock Chisel Clannfear", "T_Dae_Cre_LesserClfr_01", 1, 1 },
{ 20906, "Summon Seducer", "T_Dae_Cre_Seduc_01", 1, 1 },
{ 20907, "Summon Dark Seducer", "T_Dae_Cre_SeducDark_02", 1, 1 },
{ 20908, "Summon Vermai", "T_Dae_Cre_Verm_01", 1, 1 },
{ 20909, "Summon Storm Monarch", "T_Dae_Cre_AtroStMw_02", 1, 1 },
}

event.register(tes3.event.magicEffectsResolved, function()
	local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

	for k, v in pairs(tr_summons) do
		tes3.addMagicEffect{
			id = v[1],
			name = v[2],
			description = "",
			school = tes3.magicSchool.conjuration,
			baseCost = v[5],
			speed = summonHungerEffect.speed,
			allowEnchanting = true,
			allowSpellmaking = true,
			appliesOnce = summonHungerEffect.appliesOnce,
			canCastSelf = true,
			canCastTarget = false,
			canCastTouch = false,
			casterLinked = summonHungerEffect.casterLinked,
			hasContinuousVFX = summonHungerEffect.hasContinuousVFX,
			hasNoDuration = summonHungerEffect.hasNoDuration,
			hasNoMagnitude = summonHungerEffect.hasNoMagnitude,
			illegalDaedra = summonHungerEffect.illegalDaedra,
			isHarmful = summonHungerEffect.isHarmful,
			nonRecastable = summonHungerEffect.nonRecastable,
			targetsAttributes = summonHungerEffect.targetsAttributes,
			targetsSkills = summonHungerEffect.targetsSkills,
			unreflectable = summonHungerEffect.unreflectable,
			usesNegativeLighting = summonHungerEffect.usesNegativeLighting,
			icon = summonHungerEffect.icon,
			particleTexture = summonHungerEffect.particleTexture,
			castSound = summonHungerEffect.castSoundEffect.id,
			castVFX = summonHungerEffect.castVisualEffect.id,
			boltSound = summonHungerEffect.boltSoundEffect.id,
			boltVFX = summonHungerEffect.boltVisualEffect.id,
			hitSound = summonHungerEffect.hitSoundEffect.id,
			hitVFX = summonHungerEffect.hitVisualEffect.id,
			areaSound = summonHungerEffect.areaSoundEffect.id,
			areaVFX = summonHungerEffect.areaVisualEffect.id,
			lighting = {x = summonHungerEffect.lightingRed, y = summonHungerEffect.lightingGreen, z = summonHungerEffect.lightingBlue},
			size = summonHungerEffect.size,
			sizeCap = summonHungerEffect.sizeCap,
			onTick = function(eventData)
				eventData:triggerSummon(v[3])
			end,
			onCollision = nil
		}
	end

end)

local function tr_createsummons(id,spellname,creature,cost)

    local spell = tes3.createObject({ objectType = tes3.objectType.spell })
    tes3.setSourceless(spell)
    spell.name = spellname
    spell.magickaCost = cost
    local effect = spell.effects[1]
    effect.id = id
    effect.rangeType = tes3.effectRange.self
    effect.duration = 60
	effect.radius = 0
    effect.skill = tes3.skill.conjuration
    effect.attribute = -1
	
	return spell
end

event.register(tes3.event.loaded, function()

	for k, v in pairs(tr_summons) do
		local spell = tr_createsummons(v[1],v[2],v[3],v[4])
		tes3.addSpell({ reference = tes3.mobilePlayer, spell = spell })
	end	

end)
