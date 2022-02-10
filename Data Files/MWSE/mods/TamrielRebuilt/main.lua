tes3.claimSpellEffectId("TR_summonDevourer", 20901)

event.register(tes3.event.magicEffectsResolved, function()
	local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)
	tes3.addMagicEffect{
		id = 20901,
		name = "Summon Devourer",
		description = "",
		school = tes3.magicSchool.mysticism,
		baseCost = summonHungerEffect.baseMagickaCost,
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
			eventData:triggerSummon("T_Dae_Cre_Devourer_01")
		end,
		onCollision = nil
	}
end)

event.register(tes3.event.loaded, function()

    local spell2 = tes3.createObject({ objectType = tes3.objectType.spell })
    tes3.setSourceless(spell2)
    spell2.name = "Summon Devourer"
    spell2.magickaCost = 1

    local effect = spell2.effects[1]
    effect.id = 20901
    effect.rangeType = tes3.effectRange.self
    effect.duration = 60
	effect.radius = 0
    effect.skill = tes3.skill.conjuration
    effect.attribute = -1
	
	tes3.addSpell({ reference = tes3.mobilePlayer, spell = spell2 })
end)