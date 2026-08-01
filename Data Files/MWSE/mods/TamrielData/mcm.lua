local common = require("TamrielData.common")
local config = require("TamrielData.config")

----------------------
-- MCM Template --
----------------------

local function registerModConfig()
    local template = mwse.mcm.createTemplate{name=common.i18n("mcm.name")}
    template:saveOnClose("tamrielData", config)

    local function createPage(label)
        local page = template:createSideBarPage{
            label = label,
            noScroll = true,
        }

        page.sidebar:createInfo{text=common.i18n("mcm.version")}

        -- Sidebar Credits
        local credits = page.sidebar:createCategory{label=common.i18n("mcm.credits")}
        credits:createHyperlink{
            text = common.i18n("mcm.Kynesifnar"),
            url = "https://www.nexusmods.com/profile/Kynesifnar/mods",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.EvilEye"),
            url = "https://www.nexusmods.com/profile/Assumeru/mods",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.mort"),
            url = "https://www.nexusmods.com/profile/mortimermcmire/mods",
        }
        credits:createInfo{
            text = common.i18n("mcm.Rakanishu")
        }
        credits:createHyperlink{
            text = common.i18n("mcm.Stele"),
            url = "https://www.nexusmods.com/profile/tanstele/mods",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.chef"),
            url = "https://github.com/cheflul/Chefmod",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.Cicero"),
            url = "https://www.nexusmods.com/profile/CiceroTR/mods",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.NullCascade"),
            url = "https://www.nexusmods.com/profile/NullCascade/mods",
        }
        credits:createHyperlink{
            text = common.i18n("mcm.Hrnchamd"),
            url = "https://www.nexusmods.com/profile/Hrnchamd/mods",
        }

        return page
    end

    -- Feature Settings
    local magic = createPage(common.i18n("mcm.magic"))
    local magicToggles = magic:createCategory({description = ""})       -- Setting the description to be "" prevents the credits from rapidly appearing and disappearing as the cursor is moved over the settings
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.summonSpellsLabel"),
        description = common.i18n("mcm.summonSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "summoningSpells",
            table = config,
            restartRequired = true
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.boundSpellsLabel"),
        description = common.i18n("mcm.boundSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "boundSpells",
            table = config,
            restartRequired = true
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.interventionSpellsLabel"),
        description = common.i18n("mcm.interventionSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "interventionSpells",
            table = config,
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.miscSpellsLabel"),
        description = common.i18n("mcm.miscSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "miscSpells",
            table = config,
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.passwallAlterationLabel"),
        description = common.i18n("mcm.passwallAlterationDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "passwallAlteration",
            table = config,
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.blinkIndicatorLabel"),
        description = common.i18n("mcm.blinkIndicatorDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "blinkIndicator",
            table = config,
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.argonianBloodMagicLabel"),
        description = common.i18n("mcm.argonianBloodMagicDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "argonianBloodMagic",
            table = config,
        },
    }
    magicToggles:createSlider{
        label = common.i18n("mcm.detectValuablesThresholdLabel"),
        description = common.i18n("mcm.detectValuablesThresholdDescription"),
        min = 2000,
        max = 20000,
        step = 100,
        jump = 1000,
        variable = mwse.mcm.createTableVariable{
            id = "detectValuablesThreshold",
            table = config,
        },
    }
    magicToggles:createSlider{
        label = common.i18n("mcm.prismaticLightSaturationLabel"),
        description = common.i18n("mcm.prismaticLightSaturationDescription"),
        min = 0.2,
        max = 0.6,
        step = 0.01,
        jump = 0.05,
        decimalPlaces = 2,
        variable = mwse.mcm.createTableVariable{
            id = "prismaticLightSaturation",
            table = config,
        },
    }
    magicToggles:createSlider{
        label = common.i18n("mcm.prismaticLightPeriodLabel"),
        description = common.i18n("mcm.prismaticLightPeriodDescription"),
        min = 3,
        max = 12,
        step = 0.2,
        jump = 1,
        decimalPlaces = 1,
        variable = mwse.mcm.createTableVariable{
            id = "prismaticLightPeriod",
            table = config,
        },
    }
    magicToggles:createOnOffButton{
        label = common.i18n("mcm.magickaExpandedLabel"),
        description = common.i18n("mcm.magickaExpandedDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "overwriteMagickaExpanded",
            table = config,
        },
    }

    local equipment = createPage(common.i18n("mcm.equipment"))
    local equipmentToggles = equipment:createCategory({description = ""})
    equipmentToggles:createOnOffButton{
        label = common.i18n("mcm.hatsLabel"),
        description = common.i18n("mcm.hatsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "hats",
            table = config,
        },
    }
    equipmentToggles:createOnOffButton{
        label = common.i18n("mcm.restrictEquipmentLabel"),
        description = common.i18n("mcm.restrictEquipmentDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "restrictEquipment",
            table = config,
        },
    }
    equipmentToggles:createOnOffButton{
        label = common.i18n("mcm.femaleArgoniansUseMaleEquipmentLabel"),
        description = common.i18n("mcm.femaleArgoniansUseMaleEquipmentDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "femaleArgoniansUseMaleEquipment",
            table = config,
        },
    }

    local fixes = createPage(common.i18n("mcm.fixes"))
    local fixesToggles = fixes:createCategory({description = ""})
    fixesToggles:createOnOffButton{
        label = common.i18n("mcm.animationFixLabel"),
        description = common.i18n("mcm.animationFixDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "fixPlayerRaceAnimations",
            table = config,
        },
    }
    fixesToggles:createOnOffButton{
        label = common.i18n("mcm.wereCreatureFixLabel"),
        description = common.i18n("mcm.wereCreatureFixDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "hideWerewolfMesh",
            table = config,
        },
    }
    fixesToggles:createOnOffButton{
        label = common.i18n("mcm.fixVampireLabel"),
        description = common.i18n("mcm.fixVampireDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "fixVampireHeads",
            table = config,
        },
    }

    local miscellaneous = createPage(common.i18n("mcm.miscellaneous"))
    local miscellaneousToggles = miscellaneous:createCategory({description = ""})
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.weatherChangesLabel"),
        description = common.i18n("mcm.weatherChangesDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "weatherChanges",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.provincialReputationLabel"),
        description = common.i18n("mcm.provincialReputationDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "provincialReputation",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.provincialFactionsUILabel"),
        description = common.i18n("mcm.provincialFactionsUIDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "provincialFactionUI",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.creatureBehaviorsLabel"),
        description = common.i18n("mcm.creatureBehaviorsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "creatureBehaviors",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.creatureSoundsLabel"),
        description = common.i18n("mcm.creatureSoundsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "creatureSounds",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.itemSoundsLabel"),
        description = common.i18n("mcm.itemSoundsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "improveItemSounds",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.travelPricesLabel"),
        description = common.i18n("mcm.travelPricesDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "adjustTravelPrices",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.reactCellItemsLabel"),
        description = common.i18n("mcm.reactCellItemsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "handleReactCellItems",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.khajiitFormCharacterCreationLabel"),
        description = common.i18n("mcm.khajiitFormCharacterCreationDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "khajiitFormCharCreation",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.butterflyMothTooltipLabel"),
        description = common.i18n("mcm.butterflyMothTooltipDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "butterflyMothTooltip",
            table = config,
        },
    }
    miscellaneousToggles:createOnOffButton{
        label = common.i18n("mcm.interventionRangeLabel"),
        description = common.i18n("mcm.interventionRangeDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "limitIntervention",
            table = config,
        },
    }

    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)