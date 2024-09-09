local common = require("tamrielData.common")
local config = require("tamrielData.config")

----------------------
-- MCM Template --
----------------------

local function registerModConfig()

    local template = mwse.mcm.createTemplate{name=common.i18n("mcm.name")}
    template:saveOnClose("tamrielData", config)

    -- Preferences Page
    local preferences = template:createSideBarPage{label=common.i18n("mcm.preferences")}
    preferences.sidebar:createInfo{text=common.i18n("mcm.preferencesInfo")}

    -- Sidebar Credits
    local credits = preferences.sidebar:createCategory{label=common.i18n("mcm.credits")}
    credits:createHyperlink{
        text = "mort - Scripting",
        exec = "start https://www.nexusmods.com/morrowind/users/4138441/?tab=user+files",
    }
    credits:createHyperlink{
        text = "Kynesifnar - Scripting",
        exec = "start https://www.nexusmods.com/users/56893332?tab=user+files",
    }
    credits:createHyperlink{
        text = "chef - TD_Addon Management",
        exec = "start https://github.com/cheflul/Chefmod",
    }
    credits:createHyperlink{
        text = "Cicero - Icons",
        exec = "start https://www.nexusmods.com/morrowind/users/64610026?tab=user+files",
    }
    credits:createHyperlink{
        text = "NullCascade - MWSE Support",
        exec = "start https://www.nexusmods.com/morrowind/users/26153919?tab=user+files",
    }

    -- Feature Toggles
    local toggles = preferences:createCategory{label="Feature Toggles"}
    toggles:createOnOffButton{
        label = common.i18n("mcm.summonSpellsLabel"),
        description = common.i18n("mcm.summonSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "summoningSpells",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.boundSpellsLabel"),
        description = common.i18n("mcm.boundSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "boundSpells",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.interventionSpellsLabel"),
        description = common.i18n("mcm.interventionSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "interventionSpells",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.miscSpellsLabel"),
        description = common.i18n("mcm.miscSpellsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "miscSpells",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.vanillaEnchantmentsLabel"),
        description = common.i18n("mcm.vanillaEnchantmentsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "changeVanillaEnchantments",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.magickaExpandedLabel"),
        description = common.i18n("mcm.magickaExpandedDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "overwriteMagickaExpanded",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.weatherChangesLabel"),
        description = common.i18n("mcm.weatherChangesDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "weatherChanges",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.animationFixLabel"),
        description = common.i18n("mcm.animationFixDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "fixPlayerRaceAnimations",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.restrictEquipmentLabel"),
        description = common.i18n("mcm.restrictEquipmentDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "restrictEquipment",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.fixVampireLabel"),
        description = common.i18n("mcm.fixVampireDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "fixVampireHeads",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.itemSoundsLabel"),
        description = common.i18n("mcm.itemSoundsDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "improveItemSounds",
            table = config,
        },
    }
    toggles:createOnOffButton{
        label = common.i18n("mcm.travelPricesLabel"),
        description = common.i18n("mcm.travelPricesDescription"),
        variable = mwse.mcm.createTableVariable{
            id = "adjustTravelPrices",
            table = config,
        },
    }
    toggles:createOnOffButton{
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