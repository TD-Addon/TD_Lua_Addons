---@type mwseSafeObjectHandle
local safeNarsisPad
local narsisMGCell = "narsis, guild of mages: commons"
local narsisPadId = "tr_m7_ns_mg_mys_act"
local lissiniaID = "TR_m7_Lissinia Bax"
local log = mwse.Logger.new()
--log.level = "DEBUG"

local function getNarsisMGPad()
	local cell = tes3.player.cell
    if not cell then return end

    if cell.id:lower() ~= narsisMGCell then return end
	if safeNarsisPad and safeNarsisPad:valid() then
        return safeNarsisPad:getObject()
    end

	for reference in cell:iterateReferences(tes3.objectType.activator) do
        if reference.id:lower() == narsisPadId then
            safeNarsisPad = tes3.makeSafeObjectHandle(reference)
            return reference
        end
    end
end


local function handleMGRecall(pad, teleCompanions)
    log:debug("[MultiMark-TR] Entering Narsis MG handle function")
    if tes3.getJournalIndex{id="TR_m7_Ns_MG_Arch03"} >= 70 then
		return
	end
    local distance = pad.position:distance(tes3.player.position)
    if distance > 500 then
        return
    end
    
    log:debug("[MultiMark-TR] Disabling controls, pad distance is: "..distance)
    --Disable player controls and start doing funky magic voodoo
	tes3.setPlayerControlState{enabled = false}
	tes3.playSound{sound="magic sound"}

    local function sparkles()
		tes3.createReference{object="T_Glb_Var_SummonFX", position=tes3.player.position, orientation=tes3.player.orientation, cell=tes3.player.cell}
	end
    log:debug("[MultiMark-TR] Setting timers")
	timer.start({ duration = 0.5, callback = sparkles })
	timer.start({ duration = 1.5, callback = sparkles })
	timer.start({ duration = 2.5, callback = sparkles })

    timer.start({ duration = 3.0, callback = function()
        local x,y,z,o,cell
        log:debug("[MultiMark-TR] Teleporting player")
		tes3.setPlayerControlState{enabled = true}
        local roll = math.random()
        -- Pick randomly which location the player will get teleported to
        if roll <= 0.25 then
            if tes3.getGlobal("T_Glob_Installed_PC") == 1 then
                x,y,z,o,cell = -92762,-465506,59,0,"Dasek Marsh Region"
            else
                x,y,z,o,cell = -10162,-193741,3957,339,"Mount Annu"
            end
        elseif roll <= 0.5 then
            x,y,z,o,cell = 473,4230,4278,286,"TEM Emperor Antiochus, Hold"
        elseif roll <= 0.75 then
            x,y,z,o,cell = 3997,4139,2592,270,"Nivalis, Icebreaker Keep: Dock Tower"
        else
            if tes3.getGlobal("T_Glob_Installed_SHotN") == 1 then
                x,y,z,o,cell = -849057,102112,1360,270,"Vorndgad Forest Region"
            else
                x,y,z,o,cell = 358046,-30177,182,197,"Padomaic Ocean"
            end
        end
        log:debug(string.format("[MultiMark-TR] Final params - xyz=%f,%f,%f, o=%f, cell=%s",x,y,z,o,cell))
        tes3.positionCell({
            reference = tes3.player,
            cell = cell,
            position = {x,y,z},
            orientation = {0,0,math.rad(o)},
            teleportCompanions = teleCompanions
        })
        local journalIndex = tes3.getJournalIndex{id="TR_m7_Ns_MG_Mys"}
        log:debug(string.format("[MultiMark-TR] Journal index: %d",journalIndex))
        if journalIndex == 10 then
            tes3.updateJournal{id="TR_m7_Ns_MG_Mys", index=40}
        elseif journalIndex == 20 then
            --local lissinia = getLissinia()
            local lissinia = tes3.getReference(lissiniaID)
            if lissinia and lissinia.context then
                lissinia.context.controlQ = 4
            end
            tes3.updateJournal{id="TR_m7_Ns_MG_Mys", index=40}
        end
	end})
end

event.register(tes3.event.magicEffectsResolved, function()
    if include("Virnetch.multimark.main") then
        local config = mwse.loadConfig("multi_mark")
        if not config then
            return
        end

        local function handleCheck(e)
            local pad = getNarsisMGPad()
            if pad then
                log:debug("[MultiMark-TR] Narsis MG recall pad found.")
                timer.delayOneFrame(function()
                    if tes3.isAffectedBy{reference=tes3.player, effect=tes3.effect.multiRecall} then
                        handleMGRecall(pad, config.teleportCompanions)
                    end
                end)
            end
        end
    
        if config.multiMarkEnabled then
            event.register(tes3.event.cellChanged, handleCheck, { filter = tes3.getCell{ id = narsisMGCell }})
            mwse.log("TR compatibility for Customizable Multi-Mark and Recall's Multi-Mark mode initialized.")
        end
    end
end)