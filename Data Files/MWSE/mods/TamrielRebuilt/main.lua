tes3.claimSpellEffectId("TR_summonDevourer", 2090)
tes3.claimSpellEffectId("TR_summonDremArch", 2091)
tes3.claimSpellEffectId("TR_summonDremCast", 2092)
tes3.claimSpellEffectId("TR_summonGuardian", 2093)
tes3.claimSpellEffectId("TR_summonLesserClfr", 2094)
tes3.claimSpellEffectId("TR_summonSeducer", 2095)
tes3.claimSpellEffectId("TR_summonSeducDark", 2096)
tes3.claimSpellEffectId("TR_summonVerm", 2097)
tes3.claimSpellEffectId("TR_summonAtroStormMon", 2098)

-- unique id, spell id to override, spell name, creature id, spell cost, effect cost (for spellmaking)
local tr_summons = {	
{ 2090, "fireball", "Summon Devourer", "T_Dae_Cre_Devourer_01", 1, 1},
--{ 2091, "summon_drem_sharpshooter", "Summon Dremora Sharpshooter", "T_Dae_Cre_Drem_Arch_01", 1, 1 },
--{ 2092, "summon_drem_spellcaster", "Summon Dremora Spellcaster", "T_Dae_Cre_Drem_Cast_01", 1, 1 },
--{ 2093, "summon_guardian", "Summon Guardian", "T_Dae_Cre_Guardian_01", 1, 1 },
--{ 2094, "Summon Rock Chisel Clannfear", "T_Dae_Cre_LesserClfr_01", 1, 1 },
--{ 2095, "Summon Seducer", "T_Dae_Cre_Seduc_01", 1, 1 },
--{ 2096, "Summon Dark Seducer", "T_Dae_Cre_SeducDark_02", 1, 1 },
--{ 2097, "Summon Vermai", "T_Dae_Cre_Verm_01", 1, 1 },
--{ 2098, "Summon Storm Monarch", "T_Dae_Cre_MonarchSt_01", 1, 1 },
}

event.register(tes3.event.magicEffectsResolved, function()
	local summonHungerEffect = tes3.getMagicEffect(tes3.effect.summonHunger)

	for k, v in pairs(tr_summons) do
		tes3.addMagicEffect{
			id = v[1],
			name = v[3],
			description = "",
			school = tes3.magicSchool.conjuration,
			baseCost = v[6],
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
				eventData:triggerSummon(v[4])
			end,
			onCollision = nil
		}
	end

end)

event.register(tes3.event.loaded, function()

for k,v in pairs(tr_summons) do
	local overridden_spell = tes3.getObject(v[2])
	overridden_spell.name = v[3]

	local effect = overridden_spell.effects[1]
	effect.id = v[1]
end

end)
