-- Inventory Cleanup Hotkey

local cleanup = {}
local distribute = scripts.distribute
local item_lib = scripts["item-lib"]
local util = scripts.util
local setup = scripts.setup

local rangeMultiplier = 3

function cleanup.on_inventory_cleanup(event)
	local player = game.players[event.player_index]
	
	if util.isValidPlayer(player) then
		local items = cleanup.getTrashItems(player)
		if util.isEmpty(items) then return end
		
		local area = util.getPerimeter(player.position, cleanup.getDropRange(player))
		local entities = cleanup.getEntities(area, player)
		if #entities == 0 then return end
		
		local offY, marked = 0, setup.newEAITable()
		local dropToChests = player.mod_settings["drop-trash-to-chests"].value
		for item,count in pairs(items) do
			local filtered = cleanup.filterEntities(entities, item, dropToChests)
			
			if #filtered > 0 then
				distribute.distributeItem(player, filtered, item, false, count, true, offY, marked)
				offY = offY - 0.5
			end
		end
	end
end

function cleanup.filterEntities(entities, item, dropToChests)
	local result = setup.newEAITable()
	local prototype = game.item_prototypes[item]
	
	for _,entity in ipairs(entities) do
		if entity.can_insert{ name = item } then
			if entity.burner and entity.burner.fuel_categories[prototype.fuel_category] and entity.get_fuel_inventory().can_insert{ name = item } then
				result[entity] = entity
			elseif util.isCraftingMachine(entity) and item_lib.isIngredient(item, entity.get_recipe() or (entity.type == "furnace" and entity.previous_recipe)) then
				result[entity] = entity
			elseif entity.prototype.logistic_mode == "requester" and item_lib.getRemainingRequest(item, entity) > 0 then
				result[entity] = entity
			elseif dropToChests and (entity.type == "container" or entity.type == "logistic-container") and entity.get_item_count(item) > 0 then
				result[entity] = entity
			elseif entity.type == "lab" and prototype.subgroup.name == "science-pack" then
				result[entity] = entity
			elseif entity.type == "ammo-turret" and item_lib.isTurretAmmo(prototype, entity) then
				result[entity] = entity
			elseif entity.type == "roboport" then
				result[entity] = entity
			elseif entity.type == "car" and prototype.type == "ammo" then
				result[entity] = entity
			end
		end
	end
	
	return result
end

function cleanup.getEntities(area, player)
	local entities = {}
	for _,entity in ipairs(player.surface.find_entities_filtered{ area = area, force = player.force }) do
		if util.isValid(entity) and entity.operable and not distribute.isIgnoredEntity(entity, player) then
			entities[#entities + 1] = entity
		end
	end
	return entities
end

function cleanup.getTrashItems(player)
	local playerContents = item_lib.getPlayerContents(player)
	local customTrash = global.settings[player.index].customTrash
	local defaultTrash = global.defaultTrash
	
	local trashslots = player.get_inventory(defines.inventory.player_trash)
	local trash
	if util.isValid(trashslots) then trash = trashslots.get_contents() else trash = {} end
	
	local autoTrash
	if util.isValid(player.character) then autoTrash = player.auto_trash_filters else autoTrash = {} end
	
	local requests
	if player.mod_settings["cleanup-logistic-request-overflow"].value then requests = item_lib.getPlayerRequests(player) else requests = {} end
	
	for item,count in pairs(playerContents) do
		local targetAmount = autoTrash[item] or requests[item] or customTrash[item] or defaultTrash[item]
		
		if targetAmount then
			local surplus = count - targetAmount
			if surplus > 0 then trash[item] = (trash[item] or 0) + surplus end
		end
	end
	
	return trash
end

function cleanup.getDropRange(player)
	return math.min(player.reach_distance * rangeMultiplier, player.mod_settings["max-inventory-cleanup-drop-range"].value)
end

return cleanup