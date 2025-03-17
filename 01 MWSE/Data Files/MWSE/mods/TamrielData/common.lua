local this = {}

this.i18n = mwse.loadTranslations("TamrielData")

this.gh_config = include("graphicHerbalism.config")

-- Util functions
--	function table.contains(table, element)
--		for _,v in pairs(table) do
--		  if v == element then
--			return true
--		  end
--		end
--		return false
--	end

---@param cell tes3cell
---@param cellVisitTable table<tes3cell, boolean>|nil
---@return tes3cell?
function this.getExteriorCell(cell, cellVisitTable)
	if cell.isOrBehavesAsExterior then
		return cell
	end

	-- A hashset of cells that have already been checked, to prevent infinite loops and redundant checks.
	cellVisitTable = cellVisitTable or {}
	if (cellVisitTable[cell]) then
		return
	end
	cellVisitTable[cell] = true

	for ref in cell:iterateReferences(tes3.objectType.door) do
		if ref.destination and ref.destination.cell then
			local linkedExterior = this.getExteriorCell(ref.destination.cell, cellVisitTable)
			if (linkedExterior) then
				return linkedExterior
			end
		end
	end
end

function this.initQueue()
    local q = {}

    q.stack = {}

    function q:push(e)
        table.insert(self.stack, e)
    end

    function q:pull()
        local e = self.stack[1]

        table.remove(self.stack, 1)

        return e
    end

    function q:count()
        return #self.stack
    end

    return q
end

---@param ref tes3reference
---@return tes3pathGridNode
function this.getInitialNode(ref)
    local distance = 0
    local bestDistance = 2147483647
    local initialNode

    for _,node in pairs(ref.cell.pathGrid.nodes) do
        distance = ref.position:distance(node.position)
        --mwse.log("Node")
        --mwse.log(node.position.x)
        --mwse.log(node.position.y)
        --mwse.log(node.position.z)
        --mwse.log(distance)

        if distance < bestDistance then -- Infuriatingly, the closest node is not necessarily the first node that an actor with a travel package will go to and I am not sure how to actually get that node
            bestDistance = distance
            initialNode = node
        end
    end
    
    --mwse.log("Initial Node")
    --mwse.log(initialNode.position.x)
    --mwse.log(initialNode.position.y)
    --mwse.log(initialNode.position.z)
    --mwse.log(bestDistance)

    return initialNode
end

---@param firstNode tes3pathGridNode
---@param finalNode tes3pathGridNode
function this.pathGridSearch(firstNode, finalNode)
    local visited = {}
    local queue = this.initQueue()
	
    queue:push({firstNode})
    table.insert(visited, firstNode)

    while queue:count() > 0 do
        local path = queue:pull()
        local node = path[#path]

        if node == finalNode then return path end

        for _,connectedNode in pairs(node.connectedNodes) do
            if not table.contains(visited, connectedNode) then
                table.insert(visited, connectedNode)

                if connectedNode.connectedNodes then
                    local new = table.copy(path)

                    table.insert(new, connectedNode)
                    queue:push(new)
                end
            end
        end
    end

    return false
end

return this