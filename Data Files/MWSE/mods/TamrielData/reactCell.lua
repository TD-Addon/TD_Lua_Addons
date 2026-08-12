local this = {}

local common = require("TamrielData.common")

local react_cells = {
	{ cells = { "TEM Parhelion: Cabin", "TEM Parhelion: Flight Deck", "TEM Parhelion: Hold" }, dialogue = { id = "Enman Septim", global = "PC_m1_Anv_EnmanAirshipState", value = 2 }, container = { id = "reactCellChestTest", cell = { id = nil, x = -121, y = -57 } } },	-- The dialogue ID will need i18n translations
}

local react_cell_container_inventory

---@param e itemDroppedEventData
function this.markItem(e)
	for _,reactCell in pairs(react_cells) do
		for _,cellID in pairs(reactCell.cells) do
			if e.reference.cell.id == cellID then
				local data	
				if e.reference.data then			-- The data field on the reference type is not usable if the reference is for multiple copies of an item, but the itemData's data field is not available for references of a single copy, so both have to be used in this function; later in the frame reference.data and itemData.data will start pointing to the same tables
					data = e.reference.data
				elseif e.reference.itemData then	-- For some inane reason, dropping a single piece of ammunition results in a reference that has no data field and no itemData attachment, so it cannot be accounted for and requires these unsightly conditions to not produce an error
					data = e.reference.itemData.data
				end

				if data then
					data.tamrielData = data.tamrielData or {}
					data.tamrielData.playerItem = true
				end

				return
			end
		end
	end
end

---@param itemData tes3itemData
local function removeItemDataDataFields(itemData)
	if itemData and itemData.data and itemData.data.tamrielData and itemData.data.tamrielData.playerItem then
		itemData.data.tamrielData.playerItem = nil
		if #itemData.data.tamrielData == 0 then itemData.data.tamrielData = nil end		-- tamrielData should only be removed if it does not have any fields
	end
end

---@param e activateEventData
function this.onContainerActivate(e)
	if e.activator == tes3.player and e.target.baseObject.objectType == tes3.objectType.container then
		for _,reactCell in pairs(react_cells) do
			for _,cellID in pairs(reactCell.cells) do
				if tes3.player.cell.id == cellID then
					react_cell_container_inventory = {}
					timer.delayOneFrame(function()		-- A delay of one (real) frame is needed for an uninstantiated containers' leveled items to be resolved
						for _,item in pairs(e.target.object.inventory) do
							react_cell_container_inventory[item.object.id] = {}
							react_cell_container_inventory[item.object.id].count = item.count
							if item.variables then
								react_cell_container_inventory[item.object.id].variables = {}
								for _,itemData in pairs(item.variables) do
									table.insert(react_cell_container_inventory[item.object.id].variables, itemData)
								end
							end
						end
					end, timer.real)
				end
			end
		end
	end
end

-- Unfortauntly the data cannot be removed from an item being picked up during the activate event, so it is done here instead
---@param e convertReferenceToItemEventData
function this.removePlayerItemDataField(e)
	removeItemDataDataFields(e.reference.itemData)
end

---@param itemData tes3itemData
---@param savedData table
local function isSavedItemDataEquivalent(itemData, savedData)
	if itemData.condition == savedData.condition  and itemData.timeLeft == savedData.timeLeft and
		((not itemData.owner and not savedData.owner) or (itemData.owner and itemData.owner.id == savedData.owner)) and
		((not itemData.requirement and not savedData.requirement) or (itemData.requirement and (itemData.requirement == savedData.requirement or (table.isarray(itemData.requirement) and itemData.requirement.id == savedData.requirement)))) and
		((not itemData.soul and not savedData.soul) or (itemData.soul and (itemData.soul.id == savedData.soul))) then
		return true
	end

	return false
end

---@param e containerClosedEventData
function this.onContainerClosed(e)
	---@param variablesTable table
	---@param itemData tes3itemData
	local function addNewItemData(variablesTable, itemData)
		local itemDataTable = {}							-- Charge is not saved because it can regenerate while in a container; script id is not saved because it should not ever be needed
		itemDataTable.condition = itemData.condition
		itemDataTable.timeLeft = itemData.timeLeft
		if itemData.owner then itemDataTable.owner = itemData.owner.id end
		if itemData.requirement then
			if table.isarray(itemData.requirement) then
				itemDataTable.requirement = itemData.requirement.id
			else
				itemDataTable.requirement = itemData.requirement
			end
		end
		if itemData.soul then itemDataTable.soul = itemData.soul.id end

		table.insert(variablesTable, itemDataTable)
	end

	if react_cell_container_inventory then	-- If react_cell_container_inventory exists, then the player must currently be in a valid cell
		e.reference.data.tamrielData = e.reference.data.tamrielData or {}
		e.reference.data.tamrielData.reactCellItems = e.reference.data.tamrielData.reactCellItems or {}

		for _,item in pairs(e.reference.object.inventory) do
			e.reference.data.tamrielData.reactCellItems[item.object.id] = e.reference.data.tamrielData.reactCellItems[item.object.id] or {}
			e.reference.data.tamrielData.reactCellItems[item.object.id].count = e.reference.data.tamrielData.reactCellItems[item.object.id].count or 0
			e.reference.data.tamrielData.reactCellItems[item.object.id].variables = e.reference.data.tamrielData.reactCellItems[item.object.id].variables or {}
			if react_cell_container_inventory[item.object.id] then		-- True if the item was already present in the container
				e.reference.data.tamrielData.reactCellItems[item.object.id].count = (item.count - react_cell_container_inventory[item.object.id].count) + e.reference.data.tamrielData.reactCellItems[item.object.id].count

				if #e.reference.data.tamrielData.reactCellItems[item.object.id].variables > 0 then	-- If distinct items have been written to the container's data, then check if any have been removed by the player
					local missingItemIndices = {}
					for index,savedItemData in pairs(e.reference.data.tamrielData.reactCellItems[item.object.id].variables) do	
						local isPresent = false
						if item.variables then
							for _,currentItemData in pairs(item.variables) do
								if isSavedItemDataEquivalent(currentItemData, savedItemData) then
									isPresent = true
									break
								end
							end
						end

						if not isPresent then table.insert(missingItemIndices, index) end		-- Removing the saved items no longer in from savedItemData that while iterating through savedItemData is asking for problems, so they are saved and done afterwards
					end

					for _,index in pairs(missingItemIndices) do e.reference.data.tamrielData.reactCellItems[item.object.id].variables[index] = nil end
				end

				if item.variables then
					for _,currentItemData in pairs(item.variables) do	-- Check if any items with itemData have been added to the container
						local isNew = true
						if react_cell_container_inventory[item.object.id].variables then
							for _,initialItemData in pairs(react_cell_container_inventory[item.object.id].variables) do
								if currentItemData == initialItemData then
									isNew = false
									break
								end
							end
						end

						if isNew then addNewItemData(e.reference.data.tamrielData.reactCellItems[item.object.id].variables, currentItemData) end
					end
				end
			else		-- If an item of this type was not present when opening the container, then it must be new
				e.reference.data.tamrielData.reactCellItems[item.object.id].count = item.count
				if item.variables then
					for _,currentItemData in pairs(item.variables) do		-- Check if anyway items with itemData have been added to the container
						addNewItemData(e.reference.data.tamrielData.reactCellItems[item.object.id].variables, currentItemData)
					end
				end
			end
		end

		react_cell_container_inventory = nil
	end
end

---@param reactCell table
local function moveItems(reactCell)
	local containerCell = tes3.getCell({ id = reactCell.container.cell.id, x = reactCell.container.cell.x, y = reactCell.container.cell.y })
	local playerItemsContainer

	if containerCell then
		for container in containerCell:iterateReferences(tes3.objectType.container, true) do
			if container.baseObject.id == reactCell.container.id then
				playerItemsContainer = container
				break
			end
		end
	end

	if playerItemsContainer then
		for _,cellID in pairs(reactCell.cells) do
			local cell = tes3.getCell({ id = cellID })

			if cell then
				for item in cell:iterateReferences(common.itemTypes) do
					if item.itemData and item.itemData.data.tamrielData and item.itemData.data.tamrielData.playerItem then
						removeItemDataDataFields(item.itemData)
						tes3.addItem({ reference = playerItemsContainer, item = item.baseObject, playSound = false, itemData = (item.stackSize == 1 and item.itemData or nil), count = item.stackSize })
						item.itemData = nil
						item:delete()
					end
				end

				for container in cell:iterateReferences(tes3.objectType.container) do
					if container.data.tamrielData and container.data.tamrielData.reactCellItems then
						for itemID,data in pairs(container.data.tamrielData.reactCellItems) do
							if data.variables and #data.variables > 0 then
								for _,savedItemData in pairs(data.variables) do
									local itemFound = false
									local itemDataForTransfer
									for _,itemStack in pairs(container.object.inventory) do
										if itemStack.variables then
											for _,itemData in pairs(itemStack.variables) do
												if isSavedItemDataEquivalent(itemData, savedItemData) then
													itemFound = true
													itemDataForTransfer = itemData
													break
												end
											end
										end

										if itemFound then
											tes3.transferItem({ from = container, to = playerItemsContainer, item = itemID, itemData = itemDataForTransfer, playSound = false, limitCapacity = false })
											break
										end
									end

									data.count = data.count - 1
								end
							end

							if data.count > 0 then	-- If none of the (remaining) items of this ID have itemData, then performing the transfer is trivial
								tes3.transferItem({ from = container, to = playerItemsContainer, item = itemID, count = data.count, playSound = false, limitCapacity = false })
							end
						end
					end
				end
			end
		end
	end
end

---@param e dialogueFilteredEventData
function this.checkOnDialogue(e)
	for _,reactCell in pairs(react_cells) do
		if e.dialogue.type == tes3.dialogueType.topic and e.dialogue.id == reactCell.dialogue.id and tes3.findGlobal(reactCell.dialogue.global).value >= reactCell.dialogue.value then
			local hasRun = false
			for _,pastReactCellDialogue in pairs(tes3.player.data.tamrielData.pastReactCellDialogues) do							-- The pastReactCellDialogue are checked so that cells only have items removed from them once
				if reactCell.dialogue.id == pastReactCellDialogue.id and reactCell.dialogue.global == pastReactCellDialogue.global and reactCell.dialogue.value >= pastReactCellDialogue.value then
					hasRun = true
					break
				end
			end

			if not hasRun then
				moveItems(reactCell)
				table.insert(tes3.player.data.tamrielData.pastReactCellDialogues, reactCell.dialogue)
			end
		end

		-- break cannot be used here because that might cause other suitable reactCells with different indices to be missed
	end
end

return this