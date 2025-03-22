local this = {}

local common = require("tamrielData.common")

-- Provinces must be in reverse alphabetical order
local provinceTable = {
    {
        id = "Sky",
        name = common.i18n("reputation.Skyrim")         -- Might as well reuse the strings from the reputation feature
    },
    {
        id = "Pi",                                      -- Not sure what this one will actually be
        name = common.i18n("reputation.PadomaicIsles")
    },
    {
        id = "Mw",
        name = common.i18n("reputation.Morrowind")
    },
    {
        id = "Hr",
        name = common.i18n("reputation.HighRock")
    },
    {
        id = "Ham",
        name = common.i18n("reputation.Hammerfell")
    },
    {
        id = "Cyr",
        name = common.i18n("reputation.Cyrodiil")
    }
}

-- Create new faction section with header, province categories, and new entries whenever something updates the Stat Menu and forces rebuild
--- @param e uiRefreshedEventData
function this.uiRefreshedCallback(e)
    local statMenu = tes3ui.findMenu("MenuStat")

    if not statMenu then return end

    -- Find vanilla MenuStat_misc_layout that holds the vanilla "Faction" label and destroy it
    local vanillaFactionTitle = statMenu:findChild("MenuStat_faction_title")
	local factionParent = vanillaFactionTitle.parent
    vanillaFactionTitle:destroy()

	-- This is some code that I experimented with that just hides the faction labels instead of deleting them like the while loop below does, in case we want to stop doing that at some point
	--local factionProperties = {}
	--for i = #factionParent.children - 1, 1, -1 do
	--	if factionParent.children[i].name == "MenuStat_faction_layout" then
	--		local factionLabel = factionParent.children[i]
	--		table.insert(factionProperties, { help = factionLabel:getPropertyCallback("help"), id = factionLabel:getPropertyProperty("id"), MenuStat_skills_flag = factionLabel:getPropertyInt("MenuStat_skills_flag"), MenuStat_message = factionLabel:getPropertyObject("MenuStat_message") })
	--		factionLabel.visible = false
	--	elseif factionParent.children[i].name == "MenuStat_faction_title" then
	--		break
	--	end
	--end

	local topDivider

	for i = #factionParent.children - 1, 1, -1 do
		if factionParent.children[i].name == "MenuStat_divider" then
			if factionParent.children[i + 1].name == "MenuStat_faction_layout" then
				topDivider = factionParent.children[i]	-- The labels and titles are placed after top divider because it works for both vanilla and Tidy Charsheet
				break
			end
		end
	end

	if not topDivider then return end

	local factionProperties = {}

	local hasMessage = true
	local factionLabel = factionParent:findChild("MenuStat_faction_layout")
	while factionLabel do
		if factionLabel:getPropertyObject("MenuStat_message") then
			table.insert(factionProperties, { help = factionLabel:getPropertyCallback("help"), id = factionLabel:getPropertyProperty("id"), MenuStat_skills_flag = factionLabel:getPropertyInt("MenuStat_skills_flag"), MenuStat_message = factionLabel:getPropertyObject("MenuStat_message") })
		else
			hasMessage = false
		end
		factionLabel:destroy()
		factionLabel = factionParent:findChild("MenuStat_faction_layout")
	end

	local statPane
	if not hasMessage and factionParent.name ~= "PartScrollPane_pane" then						-- This is a convoluted solution to deal with the fact that Tidy Charsheet doesn't actually copy over all of the properties. At least it doesn't delete the original labels either.
		statPane = factionParent.parent.parent:findChild("PartScrollPane_pane")
		if statPane then
			local factionLabel = statPane:findChild("MenuStat_faction_layout")
			while factionLabel do
				table.insert(factionProperties, { help = factionLabel:getPropertyCallback("help"), id = factionLabel:getPropertyProperty("id"), MenuStat_skills_flag = factionLabel:getPropertyInt("MenuStat_skills_flag"), MenuStat_message = factionLabel:getPropertyObject("MenuStat_message") })
				factionLabel:destroy()
				factionLabel = statPane:findChild("MenuStat_faction_layout")
			end
		end
	end

    local playerFactions = {}
    for _,faction in ipairs(tes3.dataHandler.nonDynamicData.factions) do
        if faction.playerJoined then
            table.insert(playerFactions, faction)	-- Change all of the table functions to use OO syntax?
        end
    end

    for _,province in ipairs(provinceTable) do
		local provinceHasFaction = false
        for _,faction in ipairs(playerFactions) do
            ---@cast faction tes3faction
            if faction.id:find(province.id) or (province.id == "Mw" and faction.sourceMod ~= "Tamriel_Data.esm") then   -- All factions that are not from TD are assumed to fall under Morrowind
				provinceHasFaction = true

				local modifiedName = faction.name:gsub(province.name .. " ", "")

                factionLabel = factionParent:createLabel({ id = "MenuStat_faction_layout", text = modifiedName })
                factionLabel.borderLeft = 20

				for _,properties in ipairs(factionProperties) do
					if properties.MenuStat_message == faction then
						if properties.help then factionLabel:setPropertyCallback("help", properties.help) end
						if properties.id then factionLabel:setPropertyProperty("id", properties.id) end
						if properties.MenuStat_skills_flag then factionLabel:setPropertyInt("MenuStat_skills_flag", properties.MenuStat_skills_flag) end
						if properties.MenuStat_message then factionLabel:setPropertyObject("MenuStat_message", properties.MenuStat_message) end
					end
				end

				factionLabel:reorder({ after = topDivider })
            end
        end

		if provinceHasFaction then	-- If the player is not a member of any factions in a province, then they shouldn't see that province in their statmenu
			local provinceLabel = factionParent:createLabel({ id = "MenuStat_province_title" })
			provinceLabel.text = province.name
			provinceLabel.color = tes3ui.getPalette("header_color")
			provinceLabel.borderLeft = 10
			provinceLabel:reorder({ after = topDivider })
		end
    end

    -- Create text label for new "Reputation" section header
    local titleLabel = factionParent:createLabel({ id = "MenuStat_faction_title" })
    titleLabel.text = common.i18n("faction.title")
    titleLabel.color = tes3ui.getPalette("header_color")
	titleLabel:reorder({ after = topDivider })
	factionParent:updateLayout()
end

return this