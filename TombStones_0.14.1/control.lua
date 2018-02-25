script.on_event(defines.events.on_player_died, function(event)
	local player = game.players[event.player_index]
	local pos = game.surfaces[player.surface.name].find_non_colliding_position("tomb-stone", player.position, 16, 1)

	if game.surfaces[player.surface.name].can_place_entity({name = "tomb-stone", position = pos, force = game.forces.neutral}) then
		local tomb = game.surfaces[player.surface.name].create_entity({name = "tomb-stone", position = pos, force = game.forces.neutral})
		local tomb_inventory = tomb.get_inventory(defines.inventory.chest)
		local count = 0
		
		for _, inventory_type in ipairs
		{
			defines.inventory.player_guns,
			defines.inventory.player_tools,
			defines.inventory.player_ammo,
			defines.inventory.player_armor,
			defines.inventory.player_quickbar,
			defines.inventory.player_main,
			defines.inventory.player_trash,
			defines.inventory.player_vehicle
		}
		do 
			local inventory = player.get_inventory(inventory_type)
			if inventory ~= nil then
				for item = 1, #inventory do
					if inventory[item].valid_for_read then
						count = count + 1
						tomb_inventory[count].set_stack(inventory[item])
					end
				end
			end
		end
		tomb.operable = false
	end
end)


script.on_event(defines.events.on_pre_player_mined_item, function(event)
	if event.entity.name == "tomb-stone" then
		local temp = game.surfaces[event.entity.surface.name].create_entity({name="memorial-stone", position=event.entity.position, force=game.forces.neutral})
	end
end)

