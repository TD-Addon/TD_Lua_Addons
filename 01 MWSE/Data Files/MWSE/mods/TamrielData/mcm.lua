local EasyMCM = include("easyMCM.EasyMCM")

-- Create a placeholder page if EasyMCM is not installed.
if (EasyMCM == nil) or (EasyMCM.version < 1.4) then
    local function placeholderMCM(element)
        element:createLabel{text="This mod config menu requires EasyMCM v1.4 or later."}
        local link = element:createTextSelect{text="Go to EasyMCM Nexus Page"}
        link.color = tes3ui.getPalette("link_color")
        link.widget.idle = tes3ui.getPalette("link_color")
        link.widget.over = tes3ui.getPalette("link_over_color")
        link.widget.pressed = tes3ui.getPalette("link_pressed_color")
        link:register("mouseClick", function()
            os.execute("start https://www.nexusmods.com/morrowind/mods/46427?tab=files")
        end)
    end
    mwse.registerModConfig("Tamriel Data", {onCreate=placeholderMCM})
    return
end

local config = require("tamrielData.config")

----------------------
-- EasyMCM Template --
----------------------
local template = EasyMCM.createTemplate{name="Tamriel Data"}
template:saveOnClose("tamrielData", config)
template:register()

-- Preferences Page
local preferences = template:createSideBarPage{label="Preferences"}
preferences.sidebar:createInfo{text="Tamriel Data MWSE-Lua v1.2"}

-- Sidebar Credits
local credits = preferences.sidebar:createCategory{label="Credits:"}
credits:createHyperlink{
    text = "mort - Scripting",
    exec = "start https://www.nexusmods.com/morrowind/users/4138441/?tab=user+files",
}
credits:createHyperlink{
    text = "Kynesifnar - Scripting",
    exec = "start https://www.nexusmods.com/users/56893332?tab=user+files",
}
credits:createHyperlink{			
    text = "chef - TD_addon Management",
    exec = "start https://github.com/cheflul/Chefmod",
}
credits:createHyperlink{
    text = "Cicero - Icons",
    exec = "start https://www.nexusmods.com/morrowind/users/64610026?tab=user+files",
}
credits:createHyperlink{
    text = "Greatness7 - MCM Template",
    exec = "start https://www.nexusmods.com/morrowind/users/64030?tab=user+files",
}
credits:createHyperlink{
    text = "NullCascade - MWSE Support",
    exec = "start https://www.nexusmods.com/morrowind/users/26153919?tab=user+files",
}

-- Feature Toggles
local toggles = preferences:createCategory{label="Feature Toggles"}
toggles:createOnOffButton{
    label = "Add New Summoning Spells",
    description = "Adds new summoning spells using creatures from Tamriel Rebuilt, Project Cyrodiil, and Skyrim: Home of the Nords.\nRequires reload.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "summoningSpells",
        table = config,
    },
}

toggles:createOnOffButton{
    label = "Fix Player Animations for Tamriel Data Races",
    description = "Fixes animations when playing as Ohmes-raht or Suthay Khajiit via 3rd party mods.\nRequires reload. Tail may vanish until reload when animations from other MWSE addons are applied to the player character.\nIf using an animation replacer that adds tail bones to base_anim.nif, then this feature is likely not necessary.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "fixPlayerRaceAnimations",
        table = config,
    },
}
toggles:createOnOffButton{
    label = "Restrict Equipment for Tamriel Data Races",
    description = "Prevents races added by Tamriel Data from wearing certain kinds of equipment when doing so would be physically implausible or technically problematic.\nRequires reload.\n\nAffected races and equipment:" ..
	"\n- Stops male Imga from equipping helmets and all Imga from equipping footwear." ..
	"\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "restrictEquipment",
        table = config,
    },
}
toggles:createOnOffButton{
    label = "Fix Vampire Heads",
    description = "Stops Namira's shroud from hiding the player's head when equipped and allows vampire NPCs to use unique heads made specifically for them.\nRequires reload.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "fixVampireHeads",
        table = config,
    },
}
toggles:createOnOffButton{
    label = "Improve Item Sounds",
    description = "Gives some items from Tamriel Data, such as perfume, more reasonable sounds when they are used or added to/removed from one's inventory.\nRequires reload.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "improveItemSounds",
        table = config,
    },
}
toggles:createOnOffButton{
    label = "Limit Intervention Spell Range",
    description = "Restricts the range at which some intervention spells work, preventing them from being used to teleport across the entirety of Tamriel.\nMay conflict with MWSE addons that affect intervention spells or mods that add additional regions to Morrowind.\nRequires reload.\n\nDefault: Off\n\n",
    variable = EasyMCM:createTableVariable{
        id = "limitIntervention",
        table = config,
    },
}