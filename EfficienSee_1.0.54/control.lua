-- debug_status = 1
debug_mod_name = "EfficienSee"
debug_file = debug_mod_name .. "-debug.txt"
require("util")
require("utils")
require("config")

local time_units = { per_s = 1, per_m = 2, per_h = 3 }
local machines = { assembler = 1, furnace = 2, drill = 3 }

--------------------------------------------------------------------------------------
local function set_polling(t)
	if t < 14 then t = 14 end
	
	global.polling_sel = math.floor(t *2/7)
	
	global.polling_time1 = math.floor(t *7/7)
	global.polling_time2 = math.floor(t *6/7)
	global.polling_time3 = math.floor(t *5/7)
	global.polling_time4 = math.floor(t *4/7)
	global.polling_time5 = math.floor(t *3/7)
	global.polling_time6 = math.floor(t *2/7)
	global.polling_time7 = math.floor(t *1/7)
end

--------------------------------------------------------------------------------------
local function add_history(player_mem)
	-- clean history after current position
	if #player_mem.history >= max_history then
		table.remove(player_mem.history,1)
		player_mem.history_pos = player_mem.history_pos - 1
	end
	
	for i = #player_mem.history, player_mem.history_pos +1, -1 do
		table.remove(player_mem.history,i)
	end

	if player_mem.history_pos == 0 or player_mem.object_sel_name ~= player_mem.history[#player_mem.history].object_sel_name or player_mem.recipe_sel_name ~= player_mem.history[#player_mem.history].recipe_sel_name then
		table.insert(player_mem.history,{object_sel_name=player_mem.object_sel_name, recipe_sel_name=player_mem.recipe_sel_name})
	end
	
	player_mem.history_pos = #player_mem.history
	-- debug_print("histo=",player_mem.history_pos,"/",#player_mem.history)
end

--------------------------------------------------------------------------------------
local function recall_history(player_mem)
	if player_mem.history_pos > 0 then
		local histo = player_mem.history[player_mem.history_pos]
		player_mem.object_sel_name = histo.object_sel_name
		player_mem.recipe_sel_name = histo.recipe_sel_name
	end
end

--------------------------------------------------------------------------------------
local function find_assembler(entity,force)
	local force_mem = global.force_mem[force.name]
	for _, machine in pairs(force_mem.assemblers) do
		if machine.entity == entity then
			return(machine)
		end
	end
	return(nil)
end

--------------------------------------------------------------------------------------
local function find_furnace(entity,force)
	local force_mem = global.force_mem[force.name]
	for _, machine in pairs(force_mem.furnaces) do
		if machine.entity == entity then
			return(machine)
		end
	end
	return(nil)
end

--------------------------------------------------------------------------------------
local function find_drill(entity,force)
	local force_mem = global.force_mem[force.name]
	for _, machine in pairs(force_mem.drills) do
		if machine.entity == entity then
			return(machine)
		end
	end
	return(nil)
end

--------------------------------------------------------------------------------------
local function find_ore_around(drill)
	local a = square_area(drill.position,2)
	local ents = drill.surface.find_entities_filtered({area=a, type="resource"})
	if ents then
		return(ents[1])
	else
		return(nil)
	end
end

--------------------------------------------------------------------------------------
local function find_recipient_content(tank)
	if tank.fluidbox and tank.fluidbox[1] ~= nil then
		return( tank.fluidbox[1].type ) -- a string !
	else
		return( nil )
	end
end

--------------------------------------------------------------------------------------
local function update_selected_machine(selected,player_mem)
	if selected then
		local force = selected.force
		if force ~= player_mem.player.force or force == game.forces.enemy or force == game.forces.neutral then
			selected = nil
		else
			-- debug_print("selected=",selected.name)
			
			local force = player_mem.player.force
			local force_mem = global.force_mem[force.name]
			local type = selected.type
			local found
			local recipe
			
			if type == "assembling-machine" then
				found = find_assembler(selected,force)
				if found then
					player_mem.selected_machine = found
					recipe = (player_mem.selected_machine.target or selected.get_recipe())
					-- if recipe and force_mem.recipes_stat[recipe.name].hidden then
						-- recipe = nil
					-- end
					player_mem.selected_machine_recipe = recipe
					player_mem.selected_machine_object = nil
				else
					selected = nil
				end
			elseif type == "furnace" then
				found = find_furnace(selected,force)
				if found then
					player_mem.selected_machine = found
					recipe = (player_mem.selected_machine.target or selected.get_recipe())
					-- if recipe and force_mem.recipes_stat[recipe.name].hidden then
						-- recipe = nil
					-- end
					player_mem.selected_machine_recipe = recipe
					player_mem.selected_machine_object = nil
				else
					selected = nil
				end
			elseif type == "mining-drill" then
				found = find_drill(selected,force)
				if found then
					player_mem.selected_machine = found
					player_mem.selected_machine_recipe = nil
					if selected.mining_target then
						player_mem.selected_machine_object = selected.mining_target.prototype
					else
						player_mem.selected_machine_object = player_mem.selected_machine.target
					end
				else
					selected = nil
				end
			elseif type == "rocket-silo" then
				player_mem.selected_machine = nil
				player_mem.selected_machine_recipe = selected.get_recipe()
				player_mem.selected_machine_object = nil
			elseif type == "storage-tank" or type == "offshore-pump" or type == "pipe" then
				player_mem.selected_machine = nil
				player_mem.selected_machine_recipe = nil
				local fluid_name = find_recipient_content(selected)
				if fluid_name then
					player_mem.selected_machine_object = game.fluid_prototypes[fluid_name]
				else
					player_mem.selected_machine_object = nil
				end
			elseif type == "lab" then
				player_mem.selected_machine = nil
				for _,s in pairs({"science-pack-3","science-pack-2","science-pack-1"}) do
					-- debug_print(s)
					if force.recipes[s].enabled then
						player_mem.selected_machine_recipe = force.recipes[s]
						player_mem.selected_machine_object = game.item_prototypes[s]
						break
					end
				end
			else
				selected = nil
			end
		end
	end
	
	if selected == nil then
		player_mem.selected_machine = nil
		player_mem.selected_machine_recipe = nil
		player_mem.selected_machine_object = nil
	end
	
	if player_mem.selected_machine_recipe or player_mem.selected_machine_object then 
		return(2) 
	elseif selected == nil then
		return(0)
	else
		return(1)
	end
end

--------------------------------------------------------------------------------------
local function new_machine(entity,type)
	local machine = {entity=entity, type=type, n_on = 0, n_tot = 0, working = false, progress = 0, io_state = 1, target = nil}
	-- 
	local box = entity.prototype.selection_box
	if box.right_bottom.y-box.left_top.y > 3 then
		machine.dx = box.left_top.x+1.4
		machine.dy = box.right_bottom.y-1.4
	else
		machine.dx = box.left_top.x+0.4
		machine.dy = box.right_bottom.y-0.4
	end
	return(machine)
end

--------------------------------------------------------------------------------------
local function show_machines()
	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		
		for _, machine in pairs(force_mem.assemblers) do
			local ent = machine.entity
			-- debug_print( "assmb=", ent.name, " ", ent.position.x, "," , ent.position.y )
		end
		for _, machine in pairs(force_mem.furnaces) do
			local ent = machine.entity
			-- debug_print( "furnc=", ent.name, " ", ent.position.x, "," , ent.position.y )
		end
		for _, machine in pairs(force_mem.drills) do
			local ent = machine.entity
			-- debug_print( "drill=", ent.name, " ", ent.position.x, "," , ent.position.y )
		end
	end
end

--------------------------------------------------------------------------------------
local function init_machines()
	-- retrieve existing producers
	
	debug_print( "init_machines" )
	
	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		force_mem.assemblers = {}
		force_mem.furnaces = {}
		force_mem.drills = {}
	end
	
	for _, surf in pairs(game.surfaces) do
		for _, entity in pairs(surf.find_entities_filtered{type="assembling-machine"}) do
			table.insert(global.force_mem[entity.force.name].assemblers,new_machine(entity,machines.assembler))
		end
		for _, entity in pairs(surf.find_entities_filtered{type="furnace"}) do
			table.insert(global.force_mem[entity.force.name].furnaces,new_machine(entity,machines.furnace))
		end
		for _, entity in pairs(surf.find_entities_filtered{type="mining-drill"}) do
			table.insert(global.force_mem[entity.force.name].drills,new_machine(entity,machines.drill))
		end
	end
	
	-- show_machines()
end

--------------------------------------------------------------------------------------
local function update_machines_stat(type)
	-- calculate machines stats
	
	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		local recipes_stat = force_mem.recipes_stat
		local working, progress, recipe, recipe_stat, entity
		
		local function update_assembler_stat(machine)
			local function assembler_has_filled_output_slot(ass)
				-- check output inventory
				local inv = ass.get_inventory(defines.inventory.assembling_machine_output)
				if (#inv ~= 0) and (inv.get_item_count() > 1) then return(true) end -- item output
				-- but also possible fluid outputs
				local fluidbox = ass.fluidbox
				if fluidbox then
					for i=#fluidbox+#inv-#recipe.products+1,#fluidbox do
						if fluidbox[i] and fluidbox[i].amount > 0 then
							return(true)
						end
					end
				end
				return(false)
			end
			
			entity = machine.entity
			
			if machine.tag and entity and entity.valid then
				progress = entity.crafting_progress
				working = (progress ~= machine.progress) -- entity.is_crafting() and (progress < 0.99)
				machine.working = working
				
				machine.progress = progress
				recipe = entity.get_recipe()
				machine.target = recipe
				machine.n_tot = machine.n_tot + 1
				
				if recipe then
					recipe_stat = recipes_stat[recipe.name]
					recipe_stat.polling = true
					recipe_stat.nb_tot = recipe_stat.nb_tot + 1
				
					if working then
						if assembler_has_filled_output_slot(entity) then
							machine.io_state = 2 -- machine working but output growing...
						else
							machine.io_state = 1
						end
						machine.n_on = machine.n_on + 1
						recipe_stat.nb_on = recipe_stat.nb_on + 1
					else
						if assembler_has_filled_output_slot(entity) then
							machine.io_state = 2
						else
							machine.io_state = 0
						end
					end
				else 
					machine.io_state = 0 -- assembler with no recipe
				end
			end
		end
	
		local function update_furnace_stat(machine)
			local function furnace_has_filled_output_slot(furn)
				return(furn.get_inventory(defines.inventory.furnace_result).get_item_count() > 1)
			end
			
			entity = machine.entity
			
			if machine.tag and entity and entity.valid then
				if entity.get_recipe() then
					machine.target = entity.get_recipe() -- memo last recipe
				end
				progress = entity.crafting_progress
				working = (progress ~= machine.progress) -- entity.is_crafting() and (progress < 0.99)
				machine.working = working
				machine.progress = progress
				machine.n_tot = machine.n_tot + 1
				
				if machine.target then
					recipe_stat = recipes_stat[machine.target.name]
					recipe_stat.polling = true
					recipe_stat.nb_tot = recipe_stat.nb_tot + 1
				
					if working then
						if furnace_has_filled_output_slot(entity) then
							machine.io_state = 2 -- machine working but output growing...
						else
							machine.io_state = 1
						end
						machine.n_on = machine.n_on + 1
						recipe_stat.nb_on = recipe_stat.nb_on + 1
					else
						if furnace_has_filled_output_slot(entity) then
							machine.io_state = 2
						else
							machine.io_state = 0
						end
					end
				else -- no recipe
					if working then
						machine.n_on = machine.n_on + 1
						machine.io_state = 1
					else
						machine.io_state = 0 -- assembler of furnace with no recipe
					end
				end
			end
		end
		
		local function update_drill_stat(machine)
			entity = machine.entity
			
			if machine.tag and entity and entity.valid then
				if entity.mining_target then
					machine.target = entity.mining_target.prototype
				end
				progress = entity.mining_progress
				working = (progress ~= machine.progress) 
				machine.working = working
				machine.progress = progress
				machine.n_tot = machine.n_tot + 1
				
				if working then
					machine.n_on = machine.n_on + 1
					machine.io_state = 1
				else
					if entity.mining_target == nil then
						machine.io_state = 0 -- no more ore at input
					else
						machine.io_state = 2 -- no output possible ?
					end
				end
			end
		end
		
		if recipes_stat then
			-- 3 successive calls to update_machines_stat, in this order
			-- or 1 single call
			
			if type == nil or type == machines.assembler then
				for _, recipe_stat in pairs(recipes_stat) do
					recipe_stat.nb_on = 0
					recipe_stat.nb_tot = 0
					recipe_stat.polling = false
				end
				
				for _, machine in pairs(force_mem.assemblers) do
					update_assembler_stat(machine)
				end
			end
			
			if type == nil or type == machines.furnace then
				for _, machine in pairs(force_mem.furnaces) do
					update_furnace_stat(machine)
				end
			end	
			
			if type == nil or type == machines.drill then
				for _, machine in pairs(force_mem.drills) do
					update_drill_stat(machine)
				end
				
				force_mem.show_on_map = false
				
				for _, recipe_stat in pairs(recipes_stat) do
					if recipe_stat.polling then
						force_mem.show_on_map = true
						break
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function display_on_map_tag( machine, force_build )
	local exist = (machine.tag and machine.tag.valid)

	local tag_id
	
	if machine.n_on * 100 >= machine.n_tot * global.lim_busy then
		tag_id = "2"
	elseif machine.n_on * 100 >= machine.n_tot * global.lim_lazy then
		tag_id = "1"
	else
		tag_id = "0"
	end
	
	tag_id = tonumber(machine.io_state) .. tag_id
	
	local build = false

	if exist then
		if tag_id ~= machine.tag_id then
			machine.tag.destroy()
			build = true
		end
	else
		build = force_build
	end
	
	if build then
		local pos = machine.entity.position
		machine.tag = machine.entity.surface.create_entity({ name = "effic-map-" .. tag_id, position = {pos.x+machine.dx,pos.y+machine.dy}, force = machine.entity.force})
		machine.tag_id = tag_id
	end	
end

--------------------------------------------------------------------------------------
local function wipe_on_map_tag( machine )
	if machine.tag then
		if machine.tag.valid then machine.tag.destroy() end
		machine.tag = nil
	end
end

--------------------------------------------------------------------------------------
local function show_on_map_tags( force_mem, type, recipe, object )
	if type == machines.assembler then
		for _, machine in pairs( force_mem.assemblers ) do
			if (machine.target or machine.entity.get_recipe()) == recipe then
				display_on_map_tag(machine,true)
			end
		end
	elseif type == machines.furnace then
		for _, machine in pairs( force_mem.furnaces ) do
			if (machine.target or machine.entity.get_recipe()) == recipe then
				display_on_map_tag(machine,true)
			end
		end
	elseif type == machines.drill then
		local proto
		for _, machine in pairs( force_mem.drills ) do
			if machine.entity.mining_target then
				proto = machine.entity.mining_target.prototype
			else
				proto = nil
			end
			if (machine.target or proto) == object then
				display_on_map_tag(machine,true)
			end
		end
	end
end
				
--------------------------------------------------------------------------------------
local function toggle_on_map_tags( force_mem, recipe )
	local todo = 0
	
	if recipe then
		if recipe.category == "smelting" then
			-- furnace (don't check recipe as it changes, or even dissappear)
			for _, machine in pairs( force_mem.furnaces ) do
				if (machine.target or machine.entity.get_recipe()) == recipe then
					if todo == 0 then todo = iif( machine.tag == nil, 1, 2 ) end
					if todo == 1 then
						display_on_map_tag(machine,true)
					else
						wipe_on_map_tag(machine)
					end
				end
			end
		else
			-- recipe of assembler
			for _, machine in pairs( force_mem.assemblers ) do
				if (machine.target or machine.entity.get_recipe()) == recipe then
					if todo == 0 then todo = iif( machine.tag == nil, 1, 2 ) end
					if todo == 1 then
						display_on_map_tag(machine,true)
					else
						wipe_on_map_tag(machine)
					end
				end
			end
		end
	end
end
				
--------------------------------------------------------------------------------------
local function wipe_on_map_tags( force_mem, type, recipe, object )
	if type == machines.assembler then
		for _, machine in pairs( force_mem.assemblers ) do
			if (machine.target or machine.entity.get_recipe()) == recipe then
				wipe_on_map_tag(machine)
			end
		end
	elseif type == machines.furnace then
		for _, machine in pairs( force_mem.furnaces ) do
			if (machine.target or machine.entity.get_recipe()) == recipe then
				wipe_on_map_tag(machine)
			end
		end
	elseif type == machines.drill then
		local proto
		for _, machine in pairs( force_mem.drills ) do
			if machine.entity.mining_target then
				proto = machine.entity.mining_target.prototype
			else
				proto = nil
			end
			if (machine.target or proto) == object then
				wipe_on_map_tag(machine)
			end
		end
	end
end
				
--------------------------------------------------------------------------------------
local function show_all_on_map_tags( force_mem )
	for _, machine in pairs( force_mem.assemblers ) do
		display_on_map_tag(machine,true)
	end
	for _, machine in pairs( force_mem.furnaces ) do
		display_on_map_tag(machine,true)
	end
	for _, machine in pairs( force_mem.drills ) do
		display_on_map_tag(machine,true)
	end
end
				
--------------------------------------------------------------------------------------
local function wipe_all_on_map_tags( force_mem )
	if force_mem.assemblers then
		for _, machine in pairs( force_mem.assemblers ) do
			if machine.tag and machine.tag.valid then
				machine.tag.destroy()
				machine.tag = nil
			end
		end
	end
	if force_mem.furnaces then
		for _, machine in pairs( force_mem.furnaces ) do
			if machine.tag and machine.tag.valid then
				machine.tag.destroy()
				machine.tag = nil
			end
		end
	end
	if force_mem.drills then
		for _, machine in pairs( force_mem.drills ) do
			if machine.tag and machine.tag.valid then
				machine.tag.destroy()
				machine.tag = nil
			end
		end
	end
end
				
--------------------------------------------------------------------------------------
local function update_button_on_map(force_mem)
	local force = force_mem.force
	
	for _, player in pairs(game.players) do
		local player_mem = global.player_mem[player.index]
		if player.force == force and player.gui.left.frm_effic and player_mem.but_effic_map_toggle and player_mem.but_effic_map_toggle.valid then
			-- player_mem.but_effic_map_toggle.sprite = "sprite_map_toggle_effic"
			if force_mem.show_on_map then
				player_mem.but_effic_map_toggle.sprite = "sprite_map_toggle_on_effic"
			else
				player_mem.but_effic_map_toggle.sprite = "sprite_map_toggle_off_effic"
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function init_recipes_stat(force_mem)
	-- debug_print("init_recipes_stat ", force_mem.name )
	
	force_mem.recipes_stat = {}
	local recipes_stat = force_mem.recipes_stat
	global.groups = {}
	local groups = global.groups
	local n = 0
	
	for name, recipe in pairs(force_mem.force.recipes) do
		recipes_stat[name] = {name=name, recipe=recipe, 
			enabled = false, hidden = (recipe.hidden and recipe.category ~= "rocket-building"), smelting = (recipe.category == "smelting"), 
			used = false, nb_on=0, nb_tot=0, polling = false}
		n = n+1
		local group_name = recipe.group.name
		if groups[group_name] == nil then groups[group_name] = recipe.group end
	end
	
	force_mem.nb_recipes = n
	
	-- debug_print("init_recipes_stat ", #recipes_stat )
end

--------------------------------------------------------------------------------------
local function complete_techno_recipes_stat(force_mem)
	-- debug_print("complete_techno_recipes_stat ", force_mem.name )
	
	local recipes_stat = force_mem.recipes_stat
	
	for name,techno in pairs(force_mem.force.technologies) do
		if not techno.enabled then -- memorize hidden techno that should remain hidden, even if research_all unhide them...
			global.technos_hidden[name] = true
		end
		if global.technos_hidden[name] == nil then
			-- debug_print( "techno ", name, " ena=", techno.enabled, " res=", techno.researched)
			for _, effect in pairs(techno.effects) do
				if effect.type == "unlock-recipe" then
					local recipe_stat = recipes_stat[effect.recipe]
					if recipe_stat then
						recipe_stat.techno = techno
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function complete_prod_recipes_stat(force_mem)
	-- debug_print("complete_prod_recipes_stat ", force_mem.name )
	
	local recipes_stat = force_mem.recipes_stat
	
	for name, recipe_stat in pairs(recipes_stat) do
		local products = recipe_stat.recipe.products
		if #products > 0 then
			recipe_stat.product_name = products[1].name
		end
	end
end

--------------------------------------------------------------------------------------
local function check_used_recipes_stat(force_mem,player_mem)
	-- debug_print("check_used_recipes_stat ", force_mem.name )
	
	local recipes_stat = force_mem.recipes_stat
	local objects = player_mem.objects
	
	for name, recipe_stat in pairs(recipes_stat) do
		recipe_stat.enabled = recipe_stat.recipe.enabled
		local product_name = recipe_stat.product_name
		if product_name then
			local object = objects[product_name]
			if object then
				recipe_stat.used = (object.p2 ~= 0) or (object.c2 ~= 0)
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function debug_product(recipe_stat)
	if recipe_stat.product_name then
		return( "product=" .. recipe_stat.product_name.name .. "/prod=" .. recipe_stat.product_name.produced .. "/dpt=" .. recipe_stat.product_name.dpt )
	else
		return( "product=empty" )
	end
end

--------------------------------------------------------------------------------------
local function debug_recipes(force_mem)
	for name in pairs(global.technos_hidden) do
		debug_print("techno hidden: ", name)
	end
	
	for name_rec, recipe_stat in pairs(force_mem.recipes_stat) do
		debug_print("recipe: ", name_rec, " used=", recipe_stat.used, 
			" prod=", recipe_stat.product_name, " techno=", (recipe_stat.techno==nil) and "base" or recipe_stat.techno.name)
	end
end

--------------------------------------------------------------------------------------
local function debug_groups()
	for _, group in pairs(global.groups) do
		debug_print("group:", group.name, " childs=", #group.subgroups)
		for _, subgroup in pairs(group.subgroups) do
			debug_print("-> subgroup:", subgroup.name)
		end
	end
end

--------------------------------------------------------------------------------------
local function update_time_diff(player_mem)
	if player_mem.display_total then
		player_mem.tdiff = game.tick
	else
		player_mem.tdiff = game.tick - player_mem.tick_ref
	end
end

--------------------------------------------------------------------------------------
local function count_object_in_recipes(object,force_mem)
	-- debug_print( "count_objects_in_recipes" )
	
	local name = object.name
	object.nb_recipes = 0
	
	for _, recipe in pairs(force_mem.force.recipes) do
		for _, ingr in pairs(recipe.ingredients) do
			if ingr.name == name then
				object.nb_recipes = object.nb_recipes+1
				break
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function new_object(name,force_mem)
	-- debug_print("new_object ",name)
	local object = {name=name,is_item=false,is_res=false,p1=0,p2=0,c1=0,c2=0,dp=0,dc=0,ds=0,dpt=0,dct=0,dst=0,color=nil,nb_recipes=0} -- color = nil to show that no calculation done yet
		
	proto = game.item_prototypes[name]
	if proto then
		object.is_item = true
	else
		proto = game.fluid_prototypes[name]
	end
		
	ent = game.entity_prototypes[name]
	if ent and (ent.type == "resource") then
		object.is_res = true
	end
	
	if proto == nil then
		object.localised_name = "???"
	else
		object.localised_name = proto.localised_name
	end
	
	object.proto = proto
	
	count_object_in_recipes(object,force_mem)
	
	return(object)
end

--------------------------------------------------------------------------------------
local function get_object(name,objects,force_mem)
	local object = objects[name]
	if object == nil then
		object = new_object(name,force_mem)
		objects[name] = object
	end
	return(object)
end

--------------------------------------------------------------------------------------
local function copy_objects_ref(player_mem)
	for _, object in pairs(player_mem.objects) do	
		object.p1 = object.p2
		object.c1 = object.c2
	end
	player_mem.tick_ref = game.tick
end
	
--------------------------------------------------------------------------------------
local function update_object_production(force,object)
	if object.is_item then
		if object.is_res then
			object.p2 = force.item_production_statistics.get_input_count(object.name)
			object.c2 = -force.item_production_statistics.get_output_count(object.name)
		else
			object.p2 = force.item_production_statistics.get_input_count(object.name)
			object.c2 = -force.item_production_statistics.get_output_count(object.name)
		end
	else
		if object.is_res then
			object.p2 = force.fluid_production_statistics.get_input_count(object.name)
			object.c2 = -force.fluid_production_statistics.get_output_count(object.name)
		else
			object.p2 = force.fluid_production_statistics.get_input_count(object.name)
			object.c2 = -force.fluid_production_statistics.get_output_count(object.name)
		end
	end
	-- debug_print("update_object_production ", object.name, " p=", object.p1, ",", object.p2, " c=", object.c1, ",", object.c2)
end

--------------------------------------------------------------------------------------
local function update_objects_production(force_mem,player_mem)
	-- debug_print( "update_objects_production" )
	local force = force_mem.force
	local objects = player_mem.objects
	
	local function get_counts(stats)
		local obj

		-- count production
		for name, count in pairs( stats.input_counts ) do
			obj = objects[name]
			if obj == nil then 
				objects[name] = new_object(name,force_mem)
				obj = objects[name]
			end
			obj.p2 = count
		end
		
		-- count consumption
		for name, count in pairs( stats.output_counts ) do
			obj = objects[name]
			if obj == nil then 
				objects[name] = new_object(name,force_mem)
				obj = objects[name]
			end
			obj.c2 = -count
		end
	end
	
	get_counts( force.item_production_statistics )
	get_counts( force.fluid_production_statistics )
end

--------------------------------------------------------------------------------------
local function debug_production(force_mem)
	debug_print( "debug_production" )
	local force = force_mem.force
	
	local function debug_counts(stats, type)
		local obj

		-- count production
		for name, count in pairs( stats.input_counts ) do
			debug_print( "debug_production prod ", type, ":", name, "=", count )
		end
		
		-- count consumption
		for name, count in pairs( stats.output_counts ) do
			debug_print( "debug_production cons ", type, ":", name, "=", count )
		end
	end
	
	debug_counts( force.item_production_statistics, "item" )
	debug_counts( force.fluid_production_statistics, "fluid" )
end

--------------------------------------------------------------------------------------
local function calculate_object(object,force_mem,player_mem)
	
	if player_mem.display_total then
		object.dp = object.p2
		object.dc = object.c2
	else
		object.dp = object.p2-object.p1
		object.dc = object.c2-object.c1
	end

	object.ds = object.dp+object.dc

	if player_mem.tdiff == 0 then
		object.dpt = 0
		object.dct = 0
		object.dst = 0
	else
		object.dpt = object.dp*60/player_mem.tdiff
		object.dct = object.dc*60/player_mem.tdiff
		object.dst = object.dpt+object.dct
	end
	
	local p = 0
	
	if object.dpt > 0 then
		p = object.dst / object.dpt * 100
	end
	
	if p < player_mem.lim_under then
		object.color = colors.red
	elseif p < player_mem.lim_over then
		object.color = colors.yellow
	else
		object.color = colors.green
	end
	
	if force_mem.do_check_used_recipes_stat then
		check_used_recipes_stat(force_mem,player_mem)
		force_mem.do_check_used_recipes_stat = false
	end
end

--------------------------------------------------------------------------------------
local function calculate_objects(force_mem,player_mem)
	-- debug_print( "calculate_objects ", player_mem.name )
	
	update_time_diff(player_mem)
	
	for _, object in pairs(player_mem.objects) do
		calculate_object(object,force_mem,player_mem)
	end
end

--------------------------------------------------------------------------------------
local function debug_object(object)
	debug_print("object: ", object.name, " item=", object.is_item, " res=", object.is_res, " prod=", object.p2, " cons=", object.c2, " dst=", object.dst  )
end

--------------------------------------------------------------------------------------
local function debug_objects(player_mem)
	debug_print( "debug_objects" )
	for _, object in pairs(player_mem.objects) do
		debug_object(object)
	end
end

--------------------------------------------------------------------------------------
local function debug_uplist(uplist_objects)
	debug_print( "uplist_objects " )
	for name, uplist_object in pairs(uplist_objects) do
		debug_print( "uplist ", name, " ", uplist_object.amount )
	end
end

--------------------------------------------------------------------------------------
local function format_prod_item( v )
	-- return(string.format("%.3g", v))
	if v < 1e3 and v > -1e3 then
		return( string.format("%.3g", v) )
	elseif v < 1e6 and v > -1e6 then
		return( string.format("%.3gK",v/1e3) )
	else
		return( string.format("%.3gM", v/1e6) )
	end
end

--------------------------------------------------------------------------------------
local function format_rate( v, time_unit )
	local s = "/s"
	-- local p = ""
	if time_unit == time_units.per_m then
		v = v *60
		s = "/m"
	elseif time_unit == time_units.per_h then
		v = v * 3600
		s = "/h"
	end
	v = math.floor(v*100)/100
	
	if v < 1e3 and v > -1e3 then
		return( string.format("%.3g%s", v,s) )
	elseif v < 1e6 and v > -1e6 then
		return( string.format("%.3gK%s",v/1e3,s) )
	else
		return( string.format("%.3gM%s", v/1e6,s) )
	end
end
	
--------------------------------------------------------------------------------------
local function format_time( t )
	t = math.floor(t / 60)
	local s = t % 60
	t = math.floor(t / 60)
	local m = t % 60
	t = math.floor(t / 60)
	local h = t
	
	return(string.format("%uh%02um%02us", h, m, s ))
end
	
--------------------------------------------------------------------------------------
local function format_employ( machine )
	if machine.n_tot == 0 then
		return( 0 )
	else
		return( math.floor(machine.n_on / machine.n_tot * 100 ) )
	end
end

--------------------------------------------------------------------------------------
local function color_stat( recip_stat )
	local p = recip_stat.nb_tot
	
	if p == 0 then
		p = 1
	else
		p = recip_stat.nb_on * 100 / recip_stat.nb_tot
	end
	
	if p > global.lim_busy then
		return( colors.green )
	elseif p > global.lim_lazy then
		return( colors.yellow)
	else
		return( colors.red )
	end
end

--------------------------------------------------------------------------------------
local function clean_gui(gui)
	if gui then
		for _, guiname in pairs( gui.children_names ) do
			gui[guiname].destroy()
		end
	end
end

--------------------------------------------------------------------------------------
local function info_player(player_mem,s)
	local label = player_mem.lbl_effic_info
	if label and label.valid then
		label.caption = s
	end
end

--------------------------------------------------------------------------------------
local function build_menu_help( player, open_or_close )
	if open_or_close == nil then
		open_or_close = (player.gui.center.frm_effic_help == nil)
	end
	
	if player.gui.center.frm_effic_help then
		player.gui.center.frm_effic_help.destroy()
	end
	
	if open_or_close and not global.computing then
		local player_mem = global.player_mem[player.index]
		local gui1, gui2
		gui1 = player.gui.center.add({type = "frame", name = "frm_effic_help", caption = {"effic-gui-help0"}, style = "frame_effic_style"})
		gui1 = gui1.add({type = "flow", name = "flw_effic_help", direction = "vertical", style = "flow_main_effic_style"})
		
		for n=1,10 do
			gui1.add({type = "label", caption = {"effic-gui-help"..n}, style = "label_effic_style"})	
		end
		
		gui1.add({type = "button", name = "but_effic_help_close", caption = {"effic-gui-close"}, tooltip = {"effic-gui-close-tt"}, style = "button_effic_style"})
	end
end

--------------------------------------------------------------------------------------
local function build_menu_options( player, open_or_close )
	if open_or_close == nil then
		open_or_close = (player.gui.center.frm_effic_opt == nil)
	end
	
	if player.gui.center.frm_effic_opt then
		player.gui.center.frm_effic_opt.destroy()
	end
	
	if open_or_close and not global.computing then
		local player_mem = global.player_mem[player.index]
		local gui1, gui2
		gui1 = player.gui.center.add({type = "frame", name = "frm_effic_opt", caption = {"effic-gui-options"}, style = "frame_effic_style"})
		gui1 = gui1.add({type = "flow", name = "flw_effic_opt", direction = "vertical", style = "flow_main_effic_style"})
		
		gui2 = gui1.add({type = "table", name = "tab_effic_opt", column_count = 2, style = "table_effic_style"})
		
		gui2.add({type = "label", name = "lbl_effic_enabled", caption = {"effic-gui-enabled"}, style = "label_effic_style"})				
		player_mem.chk_effic_enabled = gui2.add({type = "checkbox", name = "chk_effic_enabled", state = global.enabled, style = "checkbox_effic_style"})
		
		gui2.add({type = "label", name = "lbl_effic_polling", caption = {"effic-gui-polling"}, style = "label_effic_style"})				
		player_mem.txt_effic_polling = gui2.add({type = "textfield", name = "txt_effic_polling", text = global.polling_time1, style = "textfield_effic_style"})
		
		gui2.add({type = "label", caption = {"effic-gui-limits"}, style = "label_effic_style"})				
		gui2.add({type = "label", caption = "", style = "label_effic_style"})	
		
		gui2.add({type = "label", name = "lbl_effic_lim_under", caption = {"effic-gui-under"}, style = "label_effic_style"})				
		player_mem.txt_effic_lim_under = gui2.add({type = "textfield", name = "txt_effic_lim_under", text = player_mem.lim_under, style = "textfield_effic_style"})
		
		gui2.add({type = "label", name = "lbl_effic_lim_over", caption = {"effic-gui-over"}, style = "label_effic_style"})				
		player_mem.txt_effic_lim_over = gui2.add({type = "textfield", name = "txt_effic_lim_over", text = player_mem.lim_over, style = "textfield_effic_style"})
		
		gui2.add({type = "label", name = "lbl_effic_lim_lazy", caption = {"effic-gui-lazy"}, style = "label_effic_style"})				
		player_mem.txt_effic_lim_lazy = gui2.add({type = "textfield", name = "txt_effic_lim_lazy", text = global.lim_lazy, style = "textfield_effic_style"})
		
		gui2.add({type = "label", name = "lbl_effic_lim_busy", caption = {"effic-gui-busy"}, style = "label_effic_style"})				
		player_mem.txt_effic_lim_busy = gui2.add({type = "textfield", name = "txt_effic_lim_busy", text = global.lim_busy, style = "textfield_effic_style"})
		
		gui1.add({type = "button", name = "but_effic_clean", caption = {"effic-gui-clean"}, style = "button_effic_style"})
		gui1.add({type = "button", name = "but_effic_options_close", caption = {"effic-gui-close"}, tooltip = {"effic-gui-close-tt"}, style = "button_effic_style"})
	end
end

--------------------------------------------------------------------------------------
local function build_menu_recipes( player, open_or_close )
	if open_or_close == nil then
		open_or_close = (player.gui.center.frm_effic_recl == nil)
	end
	
	if player.gui.center.frm_effic_recl then
		player.gui.center.frm_effic_recl.destroy()
	end
	
	if open_or_close and not global.computing then
		local player_mem = global.player_mem[player.index]
		local gui1, gui2, gui3
		gui1 = player.gui.center.add({type = "frame", name = "frm_effic_recl", caption = {"effic-gui-rec-list"}, style = "frame_effic_style"})
		gui1 = gui1.add({type = "flow", name = "flw_effic_recl", direction = "vertical", style = "flow_main_effic_style"})
		gui1.style.minimal_height = 500
		
		gui2 = gui1.add({type = "scroll-pane", name = "scr_effic_recl", vertical_scroll_policy = "auto"}) -- , style = "scroll_pane_effic_style"
		gui2.style.maximal_height = 450
		player_mem.scr_effic_recl = gui2
		gui3 = gui2.add({type = "table", name = "tab_effic_recl1", column_count = 6, style = "table_effic_list_style"})
		
		local n = 0
		
		for name, group in pairs(global.groups) do
			gui3.add({type = "sprite-button", name = "but_effic_rlg_" .. string.format("%2d",n) .. name, sprite = "item-group/" .. name, tooltip = group.name, style = "sprite_group_effic_style"})
			n=n+1
		end
		
		gui3 = gui2.add({type = "table", name = "tab_effic_recl2", column_count = 10, style = "table_effic_list_style"})
		
		local group = global.groups[player_mem.group_sel_name]
		
		for name, recipe in pairs(player.force.recipes) do
			if recipe.group == group and not recipe.hidden then
				gui3.add({type = "sprite-button", name = "but_effic_rlr_" .. string.format("%2d",n) .. name, sprite = "recipe/" .. name, tooltip = recipe.localised_name, style = "sprite_obj_effic_style"})
				n=n+1
			end
		end
		
		gui1.add({type = "button", name = "but_effic_recl_close", caption = {"effic-gui-close"}, tooltip = {"effic-gui-close-tt"}, style = "button_effic_style"})
		player_mem.chk_effic_recl_close = gui1.add({type = "checkbox", name = "chk_effic_recl_close", caption = {"effic-gui-auto-close"}, state = player_mem.auto_close, tooltip = {"effic-gui-auto-close-tt"}, style = "checkbox_effic_style"})
	end
end

--------------------------------------------------------------------------------------
local function build_menu_objects( player, open_or_close )
	if open_or_close == nil then
		open_or_close = (player.gui.center.frm_effic_itml == nil)
	end
	
	if player.gui.center.frm_effic_itml then
		player.gui.center.frm_effic_itml.destroy()
	end
	
	if open_or_close and not global.computing then
		local player_mem = global.player_mem[player.index]
		local gui1, gui2, gui3
		gui1 = player.gui.center.add({type = "frame", name = "frm_effic_itml", caption = {"effic-gui-item-list"}, style = "frame_effic_style"})
		gui1 = gui1.add({type = "flow", name = "flw_effic_itml", direction = "vertical", style = "flow_main_effic_style"})
		gui1.style.minimal_height = 500
		
		gui2 = gui1.add({type = "scroll-pane", name = "scr_effic_itml", vertical_scroll_policy = "auto"}) -- , style = "scroll_pane_effic_style"
		gui2.style.maximal_height = 450
		player_mem.scr_effic_recl = gui2
		gui3 = gui2.add({type = "table", name = "tab_effic_itml1", column_count = 6, style = "table_effic_list_style"})
		
		local n = 0
		
		for name, group in pairs(global.groups) do
			gui3.add({type = "sprite-button", name = "but_effic_ilg_" .. string.format("%2d",n) .. name, sprite = "item-group/" .. name, tooltip = group.name, style = "sprite_group_effic_style"})
			n=n+1
		end
		
		gui3 = gui2.add({type = "table", name = "tab_effic_itml2", column_count = 10, style = "table_effic_list_style"})
		
		local group = global.groups[player_mem.group_sel_name]
		
		for name, item in pairs(game.item_prototypes) do
			if item.group == group then
				gui3.add({type = "sprite-button", name = "but_effic_ili_" .. string.format("%2d",n) .. name, sprite = "item/" .. name, tooltip = item.localised_name, style = "sprite_obj_effic_style"})
				n=n+1
			end
		end
		
		for name, item in pairs(game.fluid_prototypes) do
			if item.group == group then
				gui3.add({type = "sprite-button", name = "but_effic_ili_00" .. name, sprite = "fluid/" .. name, tooltip = item.localised_name, style = "sprite_obj_effic_style"})
			end
		end
		
		gui1.add({type = "button", name = "but_effic_itml_close", caption = {"effic-gui-close"}, tooltip = {"effic-gui-close-tt"}, style = "button_effic_style"})
		player_mem.chk_effic_itml_close = gui1.add({type = "checkbox", name = "chk_effic_itml_close", caption = {"effic-gui-auto-close"}, state = player_mem.auto_close, tooltip = {"effic-gui-auto-close-tt"}, style = "checkbox_effic_style"})
	end
end

--------------------------------------------------------------------------------------
local function build_bar( player, reset )
	if reset and player.gui.top.but_effic then
		player.gui.top.but_effic.destroy()
	end

	if player.gui.top.but_effic == nil then
		player.gui.top.add({type = "sprite-button", name = "but_effic", sprite = "sprite_main_effic", tooltip = {"effic-gui-title"}, style = "sprite_main_effic_style"})
	end
end

--------------------------------------------------------------------------------------
local function build_gui( player )
	if global.computing then return end
	
	-- debug_print("create gui player" .. player.name)
	
	local gui0, gui1, gui2, gui3, gui4
	local player_mem = global.player_mem[player.index]
	local force_mem = global.force_mem[player.force.name]
	
	if force_mem.recipes_stat == nil then 
		player.print({"effic-gui-noallowed"})
		return
	end
	
	--------------------------------------------------------------------------------------
	-- build top of window
	
	gui0 = player.gui.left.add({type = "frame", name = "frm_effic", direction = "vertical", style = "frame_effic_style"})
	gui0 = gui0.add({type = "flow", name = "flw_effic", direction = "vertical", style = "flow_main_effic_style"})

	gui2 = gui0.add({type = "flow", name = "flw_effic_buts1a", direction = "horizontal", style = "flow_line_effic_style"})
	player_mem.but_effic_power = gui2.add({type = "sprite-button", name = "but_effic_power", tooltip = {"effic-gui-title-tt"}, style = "sprite_act_effic_style"})
	if global.enabled then
		player_mem.but_effic_power.sprite = "sprite_main_ena_effic"
	else
		player_mem.but_effic_power.sprite = "sprite_main_dis_effic"
	end
	gui2.add({type = "sprite-button", name = "but_effic_prev", sprite = "sprite_prev_effic", tooltip = {"effic-gui-prev-tt"}, style = "sprite_act_effic_style"})
	gui2.add({type = "sprite-button", name = "but_effic_next", sprite = "sprite_next_effic", tooltip = {"effic-gui-next-tt"}, style = "sprite_act_effic_style"})
	gui2.add({type = "button", name = "but_effic_reset", caption = {"effic-gui-reset"}, tooltip = {"effic-gui-reset-tt"}, style = "button_effic_style"})
	gui2.add({type = "button", name = "but_effic_refresh", caption = {"effic-gui-refresh"}, tooltip = {"effic-gui-refresh-tt"}, style = "button_effic_style"})
	player_mem.chk_effic_auto_refresh = gui2.add({type = "checkbox", name = "chk_effic_auto_refresh", caption = {"effic-gui-auto"}, tooltip = {"effic-gui-auto-tt"}, state = player_mem.auto_refresh, style = "checkbox_effic_style"})
	player_mem.but_effic_map_toggle = gui2.add({type = "sprite-button", name = "but_effic_map_toggle", tooltip = {"effic-gui-map-toggle-tt"}, style = "sprite_act_effic_style"})
	update_button_on_map(force_mem)		
	gui2.add({type = "button", name = "but_effic_options", caption = {"effic-gui-options"}, style = "button_effic_style"})
	gui2.add({type = "button", name = "but_effic_help", caption = {"effic-gui-help"}, style = "button_effic_style"})
	
	gui2 = gui0.add({type = "flow", name = "flw_effic_buts1b", direction = "horizontal", style = "flow_line_effic_style"})
	player_mem.chk_effic_display_total = gui2.add({type = "checkbox", name = "chk_effic_display_total", caption = {"effic-gui-total",0}, tooltip = {"effic-gui-total-tt"}, state = player_mem.display_total, style = "checkbox_effic_style"})
	
	gui2.add({type = "label", caption = {"effic-gui-units"}, style = "label_effic_style"})				
	gui2.add({type = "button", name = "but_effic_unit_s", caption = {"effic-gui-unit-s"}, style = "button_effic_style"})
	gui2.add({type = "button", name = "but_effic_unit_m", caption = {"effic-gui-unit-m"}, style = "button_effic_style"})
	gui2.add({type = "button", name = "but_effic_unit_h", caption = {"effic-gui-unit-h"}, style = "button_effic_style"})
	
	--------------------------------------------------------------------------------------
	-- build recipe pane
	
	gui1 = gui0.add({type = "frame", name = "frm_effic_rec", direction = "vertical", style = "frame_in_effic_style"})
	player_mem.frm_effic3 = gui1
	gui2 = gui1.add({type = "flow", name = "flw_effic_rec", direction = "vertical", style = "flow_effic_style"})
	
	gui2.add({type = "label", caption = {"effic-gui-recipe", force_mem.nb_recipes}, style = "label_effic_style"})			
	gui3 = gui2.add({type = "flow", name = "flw_effic_rec_id", direction = "horizontal", style = "flow_line_effic_style"})
	player_mem.but_effic_rec = gui3.add({type = "sprite-button", name = "but_effic_rec", tooltip = {"effic-gui-rec-tt"}, style = "sprite_obj_effic_style"})
	player_mem.lbl_effic_rec = gui3.add({type = "label", name = "lbl_effic_rec" , style = "label_bold_effic_style"})			
	gui3.add({type = "sprite-button", sprite = "sprite_clock_effic", tooltip = {"effic-gui-clock-tt"}, style = "sprite_icon_effic_style"})
	player_mem.lbl_effic_energy = gui3.add({type = "label", name = "lbl_effic_energy", caption = 0, tooltip = {"effic-gui-clock-tt"}, style = "label_bold_effic_style"})	
	
	player_mem.but_effic_oma = gui3.add({type = "sprite-button", name = "but_effic_oma_00", tooltip = {"effic-gui-map-mach-tt"}, style = "sprite_act_effic_style"})
	player_mem.lbl_rec_ass = gui3.add({type = "label", tooltip = {"effic-gui-ass-tt"}, style = "label_bold_effic_style"})	

	player_mem.but_effic_res = gui3.add({type = "sprite-button", name = "but_effic_res", tooltip = {"effic-gui-res-tt"}, style = "sprite_act_effic_style"})
	player_mem.but_effic_tec = gui3.add({type = "sprite-button", name = "but_effic_tec", tooltip = {"effic-gui-tec-tt"}, style = "sprite_tec_effic_style"})
	player_mem.lbl_effic_tec = gui3.add({type = "label", name = "lbl_effic_tec", caption = "", tooltip = {"effic-gui-tec-tt"}, style = "label_bold_effic_style"})	

	player_mem.flw_effic_rec_tab = gui2.add({type = "flow", name = "flw_effic_rec_tab", direction = "vertical", style = "flow_effic_style"})

	--------------------------------------------------------------------------------------
	-- build object pane

	gui1 = gui0.add({type = "frame", name = "frm_effic_obj", direction = "vertical", style = "frame_in_effic_style"})
	gui2 = gui1.add({type = "flow", name = "flw_effic_obj", direction = "vertical", style = "flow_effic_style"})
	
	player_mem.lbl_object = gui2.add({type = "label", style = "label_effic_style"})			
	gui3 = gui2.add({type = "flow", name = "flw_effic_obj_id", direction = "horizontal", style = "flow_line_effic_style"})
	player_mem.but_effic_obj = gui3.add({type = "sprite-button", name = "but_effic_obj", tooltip = {"effic-gui-obj-tt"}, style = "sprite_obj_effic_style"})
	player_mem.lbl_effic_obj = gui3.add({type = "label", name = "lbl_effic_obj", style = "label_bold_effic_style"})			
	-- gui3.add({type = "sprite-button", name = "but_effic_bar", sprite = "sprite_barcode_effic", style = "sprite_obj_effic_style"})
	gui3.add({type = "checkbox", name = "chk_effic_unused", caption = {"effic-gui-unused"}, state = player_mem.show_unused, tooltip = {"effic-gui-unused-tt"},style = "checkbox_effic_style"})
	gui3.add({type = "checkbox", name = "chk_effic_hidden", caption = {"effic-gui-hidden"}, state = player_mem.show_hidden, tooltip = {"effic-gui-hidden-tt"},style = "checkbox_effic_style"})
	
	gui3 = gui2.add({type = "scroll-pane", name = "scr_effic_recs", vertical_scroll_policy = "auto", style = "scroll_pane_effic_style"})
	gui3.style.maximal_height = 300
	player_mem.scr_effic_recs = gui3
	
	--------------------------------------------------------------------------------------
	-- build line info
	
	player_mem.lbl_effic_info = gui0.add({type = "label", name = "lbl_effic_info", caption = "...", style = "label_effic_style"})				

	player_mem.uplist_objects = {}
	player_mem.uplist_product_links = {}
	player_mem.uplist_ingredient_links = {}
end

--------------------------------------------------------------------------------------
local function build_obj_line(gui,uplist_object,n)
	local amount = uplist_object.amount
	local object = uplist_object.object
	local name = object.name
	
	if amount > 0 then -- product
		gui.add({type = "sprite-button", sprite = "sprite_prod_effic", tooltip = {"effic-gui-prod-tt"}, style = "sprite_ingr_effic_style"})
	else -- ingredient
		gui.add({type = "sprite-button", sprite = "sprite_ingr_effic", tooltip = {"effic-gui-ingr-tt"}, style = "sprite_ingr_effic_style"})
		amount = -amount
	end
	gui.add({type = "label", caption = amount .. "x", style = "label_effic_style"})
	uplist_object.chk_sel = nil

	local gui2 = gui.add({type = "sprite-button", name = "but_effic_obj_" .. string.format("%2d",n) .. name, tooltip = {"effic-gui-open-object"}, style = "sprite_obj_effic_style"})
	if uplist_object.is_item then
		gui2.sprite = "item/" .. name
	else
		gui2.sprite = "fluid/" .. name
	end
	uplist_object.lbl_name = gui.add({type = "label", caption = object.localised_name, style = "label_effic_style"})			
	uplist_object.lbl_dp = gui.add({type = "label", style = "label_numg_effic_style"})
	uplist_object.lbl_dpt = gui.add({type = "label", style = "label_numw_effic_style"})
	uplist_object.lbl_dc = gui.add({type = "label", style = "label_numg_effic_style"})
	uplist_object.lbl_dct = gui.add({type = "label", style = "label_numw_effic_style"})
	uplist_object.lbl_ds = gui.add({type = "label", style = "label_numg_effic_style"})
	uplist_object.lbl_dst = gui.add({type = "label", style = "label_numw_effic_style"})

	uplist_object.lbl_norm = gui.add({type = "label", style = "label_numw_effic_style"})
	uplist_object.lbl_nbingr = gui.add({type = "label", caption = object.nb_recipes, style = "label_effic_style"})
end

--------------------------------------------------------------------------------------
local function update_obj_lines(uplist_objects,force_mem,player_mem,time_unit)
	for _, uplist_object in pairs(uplist_objects) do
		object = uplist_object.object
		update_object_production(force_mem.force,object)
		calculate_object(object,force_mem,player_mem)

		-- debug_print( "update_obj_line ", object.name, " ", object.produced, " ", object.consumed, " ", (object.proto ~= nil) )
		uplist_object.lbl_name.style.font_color = object.color
		uplist_object.lbl_dp.caption = format_prod_item(object.dp)
		uplist_object.lbl_dpt.caption = format_rate(object.dpt,time_unit)
		uplist_object.lbl_dc.caption = format_prod_item(object.dc)
		uplist_object.lbl_dct.caption = format_rate(object.dct,time_unit)
		uplist_object.lbl_ds.caption = format_prod_item(object.ds)
		uplist_object.lbl_dst.caption = format_rate(object.dst,time_unit)
		uplist_object.lbl_dst.style.font_color = object.color
		if uplist_object.amount ~= nil then
			if uplist_object.amount > 0 then
				uplist_object.lbl_norm.caption = format_rate(object.dpt/uplist_object.amount,time_unit)
			else
				uplist_object.lbl_norm.caption = format_rate(-object.dct/uplist_object.amount,time_unit)
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function add_recipe_line(gui,object,uplist_link,prod_or_ingr,n)
	local recipe_stat = uplist_link.recipe_stat
	local name = recipe_stat.name
	gui.add({type = "sprite-button", name = "but_effic_rec_"  .. string.format("%2d",n) .. name, sprite = "recipe/" .. name, tooltip = {"effic-gui-open-recipe"}, style = "sprite_obj_effic_style"})
	local gui2 = gui.add({type = "label", caption = recipe_stat.recipe.localised_name, style = "label_effic_style"})
	gui2.style.font_color = recipe_stat.hidden and colors.orange or (recipe_stat.used and colors.white or colors.lightgrey)
	
	uplist_link.lbl_prod = gui.add({type = "label", caption = "", style = "label_effic_style"})
	uplist_link.but_effic_oma = gui.add({type = "sprite-button", name = "but_effic_oma_" .. string.format("%2d",n) .. name, tooltip = {"effic-gui-map-mach-tt"}, style = "sprite_act_effic_style"})
	uplist_link.lbl_link_ass = gui.add({type = "label", caption = "", tooltip = {"effic-gui-ass-tt"}, style = "label_effic_style"})

	if prod_or_ingr then
		gui.add({type = "sprite-button", sprite = "sprite_prod_effic", style = "sprite_ingr_effic_style"})
	else
		gui.add({type = "sprite-button", sprite = "sprite_ingr_effic", style = "sprite_ingr_effic_style"})
	end
	if uplist_link.amount == nil then
		gui.add({type = "label", caption = "0x", style = "label_effic_style"})
	else
		gui.add({type = "label", caption = uplist_link.amount .. "x", style = "label_effic_style"})
	end
	gui2 = gui.add({type = "sprite-button", style = "sprite_obj_effic_style"})
	if object.is_item then
		gui2.sprite = "item/" .. object.name
	else
		gui2.sprite = "fluid/" .. object.name
	end
end

--------------------------------------------------------------------------------------
local function update_recipe_lines(uplist_product_links,uplist_ingredient_links,force_mem,player_mem,time_unit)
	local objects = player_mem.objects
	local force = force_mem.force

	local function update_recipe_line(uplist_link)
		local recipe_stat = uplist_link.recipe_stat
		
		local lbl_prod = uplist_link.lbl_prod
		if lbl_prod and lbl_prod.valid then
			local product_name = recipe_stat.product_name
			if product_name then
				local object = get_object(product_name,objects,force_mem)
				update_object_production(force,object)
				calculate_object(object,force_mem,player_mem)
				dpt = object.dpt
				if dpt == 0 then
					lbl_prod.caption = "-"
				else
					lbl_prod.caption = format_rate(dpt,time_unit)
				end
			else
				lbl_prod.caption = "-"
			end
		end
		
		local but_effic_oma = uplist_link.but_effic_oma
		local lbl_link_ass = uplist_link.lbl_link_ass
		if lbl_link_ass and lbl_link_ass.valid and but_effic_oma and but_effic_oma.valid then
			if recipe_stat.polling then
				but_effic_oma.sprite = "sprite_map_toggle_on_effic"
				lbl_link_ass.caption = {"effic-gui-ass",recipe_stat.nb_on,recipe_stat.nb_tot}
				lbl_link_ass.style.font_color = color_stat(recipe_stat)
			else
				but_effic_oma.sprite = "sprite_map_toggle_off_effic"
				lbl_link_ass.caption = {"effic-gui-ass","-","-"}
				lbl_link_ass.style.font_color = colors.grey
			end
		end
	end

	for _, uplist_link in pairs(uplist_product_links) do
		if uplist_link.display then
			update_recipe_line(uplist_link)
		end
	end

	for _, uplist_link in pairs(uplist_ingredient_links) do
		if uplist_link.display then
			update_recipe_line(uplist_link)
		end
	end
end

--------------------------------------------------------------------------------------
local function calculate_list_recipes(name_obj,uplist_product_links,uplist_ingredient_links,force_mem,player_mem)
	local np, ni = 0,0
	for _, recipe_stat in pairs(force_mem.recipes_stat) do
		for _, prod in pairs(recipe_stat.recipe.products) do
			if prod.name == name_obj then
				table.insert(uplist_product_links,{recipe_stat=recipe_stat,amount=prod.amount,display=false})
				np=np+1
				break
			end
		end
		for _, ingr in pairs(recipe_stat.recipe.ingredients) do
			if ingr.name == name_obj then
				table.insert(uplist_ingredient_links,{recipe_stat=recipe_stat,amount=ingr.amount,display=false})
				ni=ni+1
				break
			end
		end
	end
	player_mem.nb_product_links = np
	player_mem.nb_ingredient_links = ni
	-- debug_print("prod_of:", np, " ingr_of:", ni )
end	

--------------------------------------------------------------------------------------
local function update_gui( player, rebuild_recipe, rebuild_object )
	if player.gui.left.frm_effic == nil then return	end

	local player_mem = global.player_mem[player.index]
	local force = player.force
	local force_mem = global.force_mem[force.name]
	
	if force_mem.recipes_stat == nil then return end

	--------------------------------------------------------------------------------------
	-- update top pane
	
	local display_total = player_mem.display_total
	local show_unused = player_mem.show_unused
	local show_hidden = player_mem.show_hidden
	local time_unit = player_mem.time_unit
	update_time_diff(player_mem)
	
	local objects = player_mem.objects
	
	local gui1 = player_mem.scr_effic_count
	local s, gui2, gui3, gui4, gui5
	
	player_mem.chk_effic_display_total.caption = {"effic-gui-total", format_time(player_mem.tdiff)}
	
	--------------------------------------------------------------------------------------
	-- display recipe pane

	if player_mem.recipe_sel_name ~= nil then
		local name = player_mem.recipe_sel_name
		
		if rebuild_recipe then
			-- build recipe pane
			
			-- debug_print("rebuild recipe ", name)
			local recipe = force.recipes[name]

			if recipe == nil then
				name = "iron-plate"
				player_mem.recipe_sel_name = name
				recipe = force.recipes[name]
			end
			
			player_mem.recipe_stat_sel = force_mem.recipes_stat[name]
				
			player_mem.but_effic_rec.sprite = "recipe/" .. name
			player_mem.lbl_effic_rec.caption = recipe.localised_name
			player_mem.lbl_effic_rec.style.font_color = player_mem.recipe_stat_sel.hidden and colors.orange or (player_mem.recipe_stat_sel.used and colors.white or colors.lightgrey)
			player_mem.lbl_effic_energy.caption = recipe.energy

			local techno = player_mem.recipe_stat_sel.techno
			if techno then
				if techno.researched then
					player_mem.but_effic_res.sprite = "sprite_res_ok_effic"
				else
					player_mem.but_effic_res.sprite = "sprite_res_no_effic"
				end
				player_mem.but_effic_tec.sprite = "technology/" .. techno.name
				player_mem.lbl_effic_tec.caption = techno.localised_name
			else
				player_mem.but_effic_res.sprite = "sprite_res_ok_effic"
				player_mem.but_effic_tec.sprite = "sprite_base_effic"
				player_mem.lbl_effic_tec.caption = "base"
			end

			if player_mem.flw_effic_rec_tab.scr_effic_rec then
				player_mem.flw_effic_rec_tab.scr_effic_rec.destroy()
			end
			gui3 = player_mem.flw_effic_rec_tab.add({type = "scroll-pane", name = "scr_effic_rec", direction = "vertical", vertical_scroll_policy = "auto"})
			gui3.style.minimal_width = 400
			gui3.style.maximal_height = 250
			
			gui4 = gui3.add({type = "flow", name = "flw_effic_recs", direction = "vertical", style = "flow_effic_style"})
			gui5 = gui4.add({type="table", name = "tab_effic_reci", column_count = 12, style = "table_effic_style"})
			gui5.add({type = "label", caption = " ", style = "label_effic_style"})				
			gui5.add({type = "label", caption = " ", style = "label_effic_style"})				
			gui5.add({type = "label", caption = " ", style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-name"}, style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-prod"}, style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-dprod"}, style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-cons"}, style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-dcons"}, style = "label_effic_style"})				
			gui5.add({type = "label", caption = {"effic-gui-stock"}, style = "label_effic_style"})	
			gui5.add({type = "label", caption = {"effic-gui-dstock"}, style = "label_effic_style"})
			gui5.add({type = "label", caption = {"effic-gui-norm"}, style = "label_effic_style"})
			gui5.add({type = "label", caption = {"effic-gui-nbrecs"}, style = "label_effic_style"})
			
			player_mem.uplist_objects = {}
			local uplist_objects = player_mem.uplist_objects
			
			local n = 0
			
			for _, ingr in pairs(recipe.ingredients) do
				-- debug_print("object=", ingr.name)
				local object = get_object(ingr.name,objects,force_mem)
				local uplist_object = {object=object, is_item=(ingr.type=="item"), amount = -ingr.amount}
				build_obj_line(gui5,uplist_object,n)
				n=n+1
				table.insert(uplist_objects, uplist_object)
			end
			
			for _, prod in pairs(recipe.products) do
				local object = get_object(prod.name,objects,force_mem)
				-- local uplist_object = {object=object, is_item=(prod.type==0), amount = prod.amount}
				local uplist_object = {object=object, is_item=(prod.type=="item"), amount = prod.amount}
				build_obj_line(gui5,uplist_object,n)
				n=n+1
				table.insert(uplist_objects, uplist_object)
			end
			
			-- debug_uplist(uplist_objects)
		end
		
		-- update recipe pane
		local recipe_stat = player_mem.recipe_stat_sel
		-- debug_print(name, " ", (recipe_stat~=nil))
		if recipe_stat.polling then
			player_mem.but_effic_oma.sprite = "sprite_map_toggle_on_effic"
			player_mem.lbl_rec_ass.caption = {"effic-gui-ass",recipe_stat.nb_on,recipe_stat.nb_tot}
			player_mem.lbl_rec_ass.style.font_color = color_stat(recipe_stat)
		else
			player_mem.but_effic_oma.sprite = "sprite_map_toggle_off_effic"
			player_mem.lbl_rec_ass.caption = {"effic-gui-ass","-","-"}
			player_mem.lbl_rec_ass.style.font_color = colors.grey
		end
		
		update_obj_lines(player_mem.uplist_objects, force_mem, player_mem, time_unit)
	end
	
	--------------------------------------------------------------------------------------
	-- display object pane
	
	if player_mem.object_sel_name ~= nil then
		local name = player_mem.object_sel_name
		
		if rebuild_object then
			local object = get_object(name,objects,force_mem)
		
			if object == nil then
				name = "iron-plate"
				player_mem.object_sel_name = name
				object = get_object(name,objects,force_mem)
			end
			
			-- debug_print("rebuild object ", name)
			
			-- update object pane basics
			
			if object.is_item then
				player_mem.lbl_object.caption = {"effic-gui-item"}
				player_mem.but_effic_obj.sprite = "item/" .. name
			else
				player_mem.lbl_object.caption = {"effic-gui-fluid"}
				player_mem.but_effic_obj.sprite = "fluid/" .. name
			end
			player_mem.lbl_effic_obj.caption = object.localised_name
							
			if player_mem.scr_effic_recs.tab_effic_recs then
				player_mem.scr_effic_recs.tab_effic_recs.destroy()
			end
			
			gui4 = player_mem.scr_effic_recs.add({type="table", name = "tab_effic_recs", column_count = 8, style = "table_effic_style"})
			
			player_mem.uplist_product_links = {}
			local uplist_product_links = player_mem.uplist_product_links
			player_mem.uplist_ingredient_links = {}
			local uplist_ingredient_links = player_mem.uplist_ingredient_links
			
			calculate_list_recipes(name,uplist_product_links,uplist_ingredient_links,force_mem,player_mem)
			
			local n = 0
			
			if player_mem.nb_product_links ~= 0 then
				-- gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "sprite-button", sprite = "sprite_prod_effic", style = "sprite_ingr_effic_style"})
				gui4.add({type = "label", name = "lbl_effic_prodof", caption = {"effic-gui-prod-of",player_mem.nb_product_links}, style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-dprod"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-machs"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-nb"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-prodof"}, style = "label_effic_style"})
				
				for _, uplist_link in pairs(uplist_product_links) do
					-- debug_print(uplist_product_link.recipe.name, " ", link.recipe_stat.used )
					if (show_unused or uplist_link.recipe_stat.used) and (show_hidden or not uplist_link.recipe_stat.hidden) then
						add_recipe_line(gui4,object,uplist_link,true,n)
						uplist_link.display = true
						n=n+1
					end
				end
			end
			
			if player_mem.nb_ingredient_links ~= 0 then
				-- gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "sprite-button", sprite = "sprite_ingr_effic", style = "sprite_ingr_effic_style"})
				gui4.add({type = "label", name = "lbl_effic_ingrof", caption = {"effic-gui-ingr-of", player_mem.nb_ingredient_links}, style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-dprod"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-machs"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = "", style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-nb"}, style = "label_effic_style"})
				gui4.add({type = "label", caption = {"effic-gui-ingrof"}, style = "label_effic_style"})
				
				for _, uplist_link in pairs(uplist_ingredient_links) do
					if (show_unused or uplist_link.recipe_stat.used) and (show_hidden or not uplist_link.recipe_stat.hidden) then
						add_recipe_line(gui4,object,uplist_link,false,n)
						uplist_link.display = true
						n=n+1
					end
				end
			end
		end
		
		-- update object pane table
		update_recipe_lines(player_mem.uplist_product_links,player_mem.uplist_ingredient_links,force_mem,player_mem,time_unit)		
	end
end
	
--------------------------------------------------------------------------------------
local function update_guis()
	for _, player in pairs(game.players) do
		if player.connected then
			local player_mem = global.player_mem[player.index]
			if player_mem.auto_refresh then
				update_gui(player,false,false)
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function close_gui(player)
	-- if player.connected then
		if player.gui.left.frm_effic then
			player.gui.left.frm_effic.destroy()
		end
		if player.gui.center.frm_effic_help then
			player.gui.center.frm_effic_help.destroy()
		end
		if player.gui.center.frm_effic_opt then
			player.gui.center.frm_effic_opt.destroy()
		end
		if player.gui.center.frm_effic_recl then
			player.gui.center.frm_effic_recl.destroy()
		end
		if player.gui.center.frm_effic_itml then
			player.gui.center.frm_effic_itml.destroy()
		end
	-- end
end

--------------------------------------------------------------------------------------
local function close_guis( )
	for _, player in pairs(game.players) do
		close_gui(player)
	end
end

--------------------------------------------------------------------------------------
local function reset_data()
	-- debug_print( "reset_data" )
	
	-- debug_print( "reset_data init" )
	
	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		
		init_recipes_stat(force_mem)
		complete_techno_recipes_stat(force_mem)
		complete_prod_recipes_stat(force_mem)

		wipe_all_on_map_tags(force_mem)
		
		force_mem.show_on_map = false
	end

	-- debug_print( "reset_data init_machines" )
	init_machines()

	-- debug_print( "reset_data objects" )
	for _, player in pairs(game.players) do
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		
		player_mem.display_total = false

		player_mem.objects = {}
		update_objects_production(force_mem,player_mem)
		copy_objects_ref(player_mem)
		calculate_objects(force_mem,player_mem)
		check_used_recipes_stat(force_mem,player_mem)

		close_gui(player)
		
		player_mem.object_sel_name = "iron-plate"
		player_mem.recipe_sel_name = "iron-plate"
		player_mem.group_sel_name = "intermediate-products"
		
		player_mem.history = {}
		player_mem.history_pos = 0
	end
	
	-- debug_print( "reset_data end" )
end

--------------------------------------------------------------------------------------
script.on_load( 
	-- called just after any "load game", before the game state is started (or MP desync tested)
	-- do not touch game state, do not touch globals !.
	function()
		if debug_status then
			debug_do_raz = true
		end
	end
)

--------------------------------------------------------------------------------------
local function init_globals()
	-- initialize or update general globals of the mod
	debug_print( "init_globals " )
	
	global.ticks = global.ticks or 0
	if global.enabled == nil then global.enabled = true end
	global.force_mem = global.force_mem or {}
	global.player_mem = global.player_mem or {}
	global.technos_hidden = global.technos_hidden or {}
	global.groups = global.groups or {}  -- list of name_group, group
	
	global.lim_lazy = global.lim_lazy or 50
	global.lim_busy = global.lim_busy or 80
	
	global.polling_time1 = global.polling_time1 or default_polling
	set_polling(global.polling_time1)
	
	if global.computing == nil then global.computing = false end
end

--------------------------------------------------------------------------------------
local function init_force(force)
	if global.force_mem == nil then return end
	
	-- initialize or update per force globals of the mod
	debug_print( "init_force ", force.name )
	
	global.force_mem[force.name] = global.force_mem[force.name] or {}
	local force_mem = global.force_mem[force.name]

	force_mem.name = force.name
	force_mem.force = force
	
	force_mem.nb_recipes = force_mem.nb_recipes or 0

	if force_mem.recipes_stat == nil then
		if force == game.forces.enemy or force == game.forces.neutral then
			force_mem.recipes_stat = nil
		else
			init_recipes_stat(force_mem) -- list of name_recipe, {name,recipe,hidden,enabled,product_name,used,nb_on,nb_tot}
			complete_techno_recipes_stat(force_mem)
			complete_prod_recipes_stat(force_mem)
		
			-- if force == game.forces.player then
				-- debug_recipes(force_mem)
			-- end
		end
	end

	force_mem.assemblers = force_mem.assemblers or {}  -- list of {entity, n_on, n_tot, working, io_state, tag, dx, dy}
	force_mem.furnaces = force_mem.furnaces or {}  -- list of {entity, n_on, n_tot, working, io_state, tag, dx, dy}
	force_mem.drills = force_mem.drills or {}  -- list of {entity, n_on, n_tot, working, io_state, tag, dx, dy}

	if force_mem.show_on_map == nil then force_mem.show_on_map = false end
end

--------------------------------------------------------------------------------------
local function init_forces()
	for _, force in pairs(game.forces) do
		init_force(force)
	end
end

--------------------------------------------------------------------------------------
local function init_player(player)
	if global.player_mem == nil then return end
	
	-- initialize or update per player globals of the mod, and reset the gui
	debug_print( "init_player ", player.name, " connected=", player.connected )
	
	global.player_mem[player.index] = global.player_mem[player.index] or { player = player }
	
	local player_mem = global.player_mem[player.index]
	
	player_mem.name = player.name
	player_mem.player = player
	
	if player_mem.display_total == nil then player_mem.display_total = false end
	if player_mem.filter_checked == nil then player_mem.filter_checked = false end
	if player_mem.auto_refresh == nil then player_mem.auto_refresh = true end
	if player_mem.emit_alerts == nil then player_mem.emit_alerts = false end
	if player_mem.auto_close == nil then player_mem.auto_close = true end
	if player_mem.show_unused == nil then player_mem.show_unused = false end
	if player_mem.show_hidden== nil then player_mem.show_hidden = false end
	
	player_mem.lim_under = player_mem.lim_under or -10
	player_mem.lim_over = player_mem.lim_over or 10
	player_mem.time_unit = player_mem.time_unit or time_units.per_m
	
	player_mem.tick_ref = player_mem.tick_ref or 0
	
	if player_mem.objects == nil then -- list index object_name {p1,p2...}  (voir new_object)
		local force_mem = global.force_mem[player.force.name]
		player_mem.objects = {}
		update_objects_production(force_mem,player_mem)
		copy_objects_ref(player_mem)
		calculate_objects(force_mem,player_mem)
		check_used_recipes_stat(force_mem,player_mem)
	end

	player_mem.uplist_objects =  player_mem.uplist_objects or {} -- list of objects to refresh in gui recipe pane
	player_mem.uplist_product_links =  player_mem.uplist_product_links or {} -- list of recipes to refresh in gui object pane
	player_mem.uplist_ingredient_links =  player_mem.uplist_ingredient_links or {} -- list of recipes to refresh in gui object pane

	player_mem.object_sel_name = "iron-plate" 
	player_mem.recipe_sel_name = "iron-plate" 
	player_mem.group_sel_name = "intermediate-products"
	
	player_mem.history = player_mem.history or {}
	player_mem.history_pos = player_mem.history_pos or 0
	
	build_bar(player,false)
	
	close_gui(player)
end

--------------------------------------------------------------------------------------
local function init_players()
	for _, player in pairs(game.players) do
		init_player(player)
	end
end

--------------------------------------------------------------------------------------
local function on_init() 
	-- called once, the first time the mod is loaded on a game (new or existing game)
	debug_print( "RAZ" )
	debug_print( "on_init" )
	
	init_globals()
	
	init_forces()
	
	init_machines()
	
	init_players()
end

script.on_init(on_init)

--------------------------------------------------------------------------------------
local function on_configuration_changed(data)
	-- detect any mod or map version change
	
	if data.mod_changes ~= nil then
		local nb_mod_changes = size_list(data.mod_changes)
		local reset_data_done = false
		
		debug_print( "RAZ" )
		debug_print( "mod changes = ", nb_mod_changes )

		close_guis() -- to avoid errors
		
		local changes = data.mod_changes[debug_mod_name]
		
		if changes ~= nil then
			debug_print( "update mod: ", debug_mod_name, " ", tostring(changes.old_version), " to ", tostring(changes.new_version) )
			
			nb_mod_changes = nb_mod_changes - 1

			init_globals()
			
			if changes.old_version and older_version(changes.old_version, "1.0.24") then
				-- delete deprecated data
			
				for _, force in pairs(game.forces) do -- destroy io
					local force_mem = global.force_mem[force.name]
					if force_mem then
						for _, machine in pairs( force_mem.assemblers ) do
							if machine.io and machine.io.valid then
								machine.io.destroy()
								machine.io = nil
							end
						end
						for _, machine in pairs( force_mem.furnaces ) do
							if machine.io and machine.io.valid then
								machine.io.destroy()
								machine.io = nil
							end
						end
						wipe_all_on_map_tags(force_mem)
						force_mem.show_on_map = false
						
						force_mem.objects = nil
					end
				end
				
				for _, player in pairs(game.players) do
					-- debug_guis(player.gui.left,0)
					if player.gui.left.flw_effic ~= nil then -- delete old gui
						player.gui.left.flw_effic.destroy()
					end
					
					local player_mem = global.player_mem[player.index]
					if player_mem then
						player_mem.display_total = false
						player_mem.objects_ref = nil
						player_mem.uplist_recipes = nil
					end
				end
			end
			
			init_forces()
			
			init_players()

			if changes.old_version and older_version(changes.old_version, "1.0.28") then
				global.lim_busy = 80
			end

			if changes.old_version and older_version(changes.old_version, "1.0.40") then
				reset_data()
				reset_data_done = true
				global.polling_time1 = default_polling
				set_polling(global.polling_time1)
				message_all("EfficienSee update. Use the help button and tooltips...")
			end

			if changes.old_version and older_version(changes.old_version, "1.0.44") then
				message_all("EfficienSee: add a ALT+B hotkey to reset counter without opening interface.")
			end
		end

		-- any change mod (and potential items/recipes deletion/addition) should reset/clean some globals.
		
		debug_print( "any other mod change : reset data" )
		
		if nb_mod_changes > 0 then
			if not reset_data_done then
				reset_data()
			end
		end
	end
end

script.on_configuration_changed(on_configuration_changed)

--------------------------------------------------------------------------------------
local function on_force_created(event)
	-- called at player creation
	local force = event.force
	debug_print( "force created ", force.name )
	
	init_force( force )
end

script.on_event(defines.events.on_force_created, on_force_created )

--------------------------------------------------------------------------------------
local function on_forces_merging(event)
	-- called at player creation
	local force1 = event.source
	local force2 = event.destination
	debug_print( "force merging ", force1.name, " into ", force2.name )
	
	local force_mem1 = global.force_mem[force1.name]
	local force_mem2 = global.force_mem[force2.name]
	
	init_recipes_stat(force_mem2)
	complete_techno_recipes_stat(force_mem2)
	complete_prod_recipes_stat(force_mem2)

	wipe_all_on_map_tags(force_mem1)
	
	force_mem1.show_on_map = false
	
	for _, machine in pairs(force_mem1.assemblers) do
		table.insert(force_mem2.assemblers,machine)
		machine.target = nil
	end
	
	for _, machine in pairs(force_mem1.furnaces) do
		table.insert(force_mem2.furnaces,machine)
		machine.target = nil
	end
	
	for _, machine in pairs(force_mem1.drills) do
		table.insert(force_mem2.drills,machine)
		machine.target = nil
	end
	
	-- for name, recipe_stat1 in pairs(force_mem1.recipes_stat) do
		-- recipe_stat2 = force_mem2.recipes_stat[name]
		-- if recipe_stat2 == nil then
			-- recipe_stat2 = {nb_on = 0, nb_tot = 0}
			-- force_mem2.recipes_stat[name] = recipe_stat2
		-- end
		-- recipe_stat2.nb_on = recipe_stat1.nb_on + recipe_stat2.nb_on
		-- recipe_stat2.nb_tot = recipe_stat1.nb_tot + recipe_stat2.nb_tot
	-- end
	
	global.force_mem[force1.name] = nil
end

script.on_event(defines.events.on_forces_merging, on_forces_merging )

--------------------------------------------------------------------------------------
local function on_research_finished(event)
	local research = event.research
	local force = research.force
	local force_mem = global.force_mem[force.name]
	
	if force_mem == nil or force_mem.recipes_stat == nil then return end
	
	-- debug_print( "on_research_finished ", research.name, " force ", force.name )
	
	-- close_guis()
	
	local recipe_new = false
	local recipe_stat
	
	for _, effect in pairs(research.effects) do
		if effect.type == "unlock-recipe" then
			recipe_stat = force_mem.recipes_stat[effect.recipe]
			recipe_stat.enabled = true
			recipe_new = true
		end
	end
	
	if recipe_new then
		for _, player in pairs(game.players) do
			if player.connected and player.force == force then
				update_gui(player,true,true)
			end
		end
	end
end

script.on_event(defines.events.on_research_finished, on_research_finished )

--------------------------------------------------------------------------------------
local function on_player_created(event)
	-- called at player creation
	local player = game.players[event.player_index]
	debug_print( "player created ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_created, on_player_created )

--------------------------------------------------------------------------------------
local function on_player_joined_game(event)
	-- called in SP(once) and MP(every connect), eventually after on_player_created
	local player = game.players[event.player_index]
	debug_print( "player joined ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game )

--------------------------------------------------------------------------------------
local function on_creation( event )
	local ent = event.created_entity

	if ent.type == "assembling-machine" then
		-- debug_print( "creation ", ent.name )
		
		local force = ent.force
		local force_mem = global.force_mem[force.name]
		
		table.insert(force_mem.assemblers,new_machine(ent,machines.assembler))
		
	elseif ent.type == "furnace" then
		-- debug_print( "creation ", ent.name )
		
		local force = ent.force
		local force_mem = global.force_mem[force.name]
		
		table.insert(force_mem.furnaces,new_machine(ent,machines.furnace))
		
	elseif ent.type == "mining-drill" then
		-- debug_print( "creation ", ent.name )
		
		local force = ent.force
		local force_mem = global.force_mem[force.name]
		
		table.insert(force_mem.drills,new_machine(ent,machines.drill))
	end

end

script.on_event(defines.events.on_built_entity, on_creation )
script.on_event(defines.events.on_robot_built_entity, on_creation )

--------------------------------------------------------------------------------------
local function on_destruction( event )
	local ent = event.entity
	
	if ent.type == "assembling-machine" then
		-- debug_print( "destruction ", ent.name )
	
		local force = ent.force
		local force_mem = global.force_mem[force.name]

		for i, machine in pairs(force_mem.assemblers) do
			if machine.entity == ent then
				if machine.tag and machine.tag.valid then
					machine.tag.destroy()
				end
				table.remove( force_mem.assemblers, i )
				break
			end
		end

	elseif ent.type == "furnace" then
		-- debug_print( "destruction ", ent.name )
	
		local force = ent.force
		local force_mem = global.force_mem[force.name]

		for i, machine in pairs(force_mem.furnaces) do
			if machine.entity == ent then
				if machine.tag and machine.tag.valid then
					machine.tag.destroy()
				end
				table.remove( force_mem.furnaces, i )
				break
			end
		end

	elseif ent.type == "mining-drill" then
		-- debug_print( "destruction ", ent.name )
	
		local force = ent.force
		local force_mem = global.force_mem[force.name]

		for i, machine in pairs(force_mem.drills) do
			if machine.entity == ent then
				if machine.tag and machine.tag.valid then
					machine.tag.destroy()
				end
				table.remove( force_mem.drills, i )
				break
			end
		end
	end
end

script.on_event(defines.events.on_entity_died, on_destruction )
script.on_event(defines.events.on_robot_pre_mined, on_destruction )
script.on_event(defines.events.on_pre_player_mined_item, on_destruction )

--------------------------------------------------------------------------------------
local function on_tick(event)
	if not global.enabled then return end
	
	--------------------------------------------------------------------------------------
	if global.ticks <= 0 then 
		global.ticks = global.polling_time1

		-- compute machines stats
		-- update_machines_stat()
		
		update_machines_stat(machines.assembler)
	
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time2 then 
		-- refresh on-map infos

		for _, force in pairs(game.forces) do
			local force_mem = global.force_mem[force.name]
			
			for _, machine in pairs( force_mem.assemblers ) do
				display_on_map_tag(machine)
			end
		end
		
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time3 then 
		-- compute machines stats
		update_machines_stat(machines.furnace)
		
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time4 then 
		-- refresh on-map infos

		for _, force in pairs(game.forces) do
			local force_mem = global.force_mem[force.name]
			
			for _, machine in pairs( force_mem.furnaces ) do
				display_on_map_tag(machine)
			end
		end
		
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time5 then 
		-- compute machines stats
		update_machines_stat(machines.drill)
		
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time6 then 
		-- refresh on-map infos

		for _, force in pairs(game.forces) do
			local force_mem = global.force_mem[force.name]
			
			for _, machine in pairs( force_mem.drills ) do
				display_on_map_tag(machine)
			end
		end
		
	--------------------------------------------------------------------------------------
	elseif global.ticks == global.polling_time7 then 
		-- refresh gui windows

		-- debug_print("update_guis")
		

		update_guis()
	end
	
	--------------------------------------------------------------------------------------
	if global.ticks % global.polling_sel == 4 then
		-- check if machine selected, to display infos
		
		for _, player in pairs(game.players) do
			local player_mem = global.player_mem[player.index]
			local force_mem = global.force_mem[player.force.name]
			local selected = player.selected
			
			local ret = update_selected_machine(selected,player_mem)
			local machine = player_mem.selected_machine
			
			-- debug_print( "ret=",ret)
			
			if (ret >= 1) and machine and machine.tag then
				if player_mem.selected_machine_recipe then
					if machine.working then
						info_player(player_mem, {"effic-gui-info-employ-crafting", machine.entity.localised_name, format_employ(machine),player_mem.selected_machine_recipe.localised_name})
					else
						info_player(player_mem, {"effic-gui-info-employ-nocraft", machine.entity.localised_name, format_employ(machine),player_mem.selected_machine_recipe.localised_name})
					end
				elseif player_mem.selected_machine_object then
					if machine.working then
						info_player(player_mem, {"effic-gui-info-employ-output", machine.entity.localised_name, format_employ(machine),player_mem.selected_machine_object.localised_name})
					else
						info_player(player_mem, {"effic-gui-info-employ-nooutput", machine.entity.localised_name, format_employ(machine),player_mem.selected_machine_object.localised_name})
					end
				else
					info_player(player_mem, {"effic-gui-info-employ", machine.entity.localised_name, format_employ(machine)})
				end
			else
				player_mem.selected_machine = nil
				info_player(player_mem, {"effic-gui-recap",#force_mem.assemblers,#force_mem.furnaces,#force_mem.drills} )
			end
		end
	end
	
	global.ticks = global.ticks - 1 
end

script.on_event(defines.events.on_tick, on_tick)

--------------------------------------------------------------------------------------
local function on_hotkey_main(event)
	local player = game.players[event.player_index]
	local force_mem = global.force_mem[player.force.name]
	
	-- debug_print( "on_hotkey ", player.name, " ", event_name )
	
	local player_mem = global.player_mem[player.index]
	local selected = player.selected
	local ret = update_selected_machine(selected,player_mem)
	local rebuild = false

	if ret == 1 then return end -- no recipe nor object, then do nothing
	
	if player.gui.left.frm_effic == nil then
		build_gui(player)
		rebuild = true
	elseif not (ret >= 2) then
		close_gui(player)
	end
	
	if player.gui.left.frm_effic then
		-- debug_print("on_hotkey_main ", player_mem.recipe_sel_name,",",player_mem.object_sel_name, ",", ret)
		if (ret >= 2) then
			local recipe = player_mem.selected_machine_recipe
			if recipe then
				if #recipe.products >= 1 then
					player_mem.object_sel_name = recipe.products[1].name
				end
				player_mem.recipe_sel_name = recipe.name
				add_history(player_mem)
				update_gui(player,true,true)
			end
			local object = player_mem.selected_machine_object
			if object then
				player_mem.object_sel_name = object.name
				add_history(player_mem)
				update_gui(player,rebuild,true)
			end
		else
			update_gui(player,true,true)
		end
	end
end

script.on_event("effic_hotkey", on_hotkey_main)

--------------------------------------------------------------------------------------
local function on_hotkey_on_map(event)
	local player = game.players[event.player_index]
	local player_mem = global.player_mem[player.index]
	local force_mem = global.force_mem[player.force.name]
	
	-- debug_print( "on_hotkey ", player.name, " ", event_name )
	
	local selected = player.selected
	local ret = update_selected_machine(selected,player_mem)
	
	if (ret >= 1) then	
		if player.gui.left.frm_effic then
			update_gui(player,false,false)
		end
		force_mem.show_on_map = true
		if player_mem.selected_machine then
			if player_mem.selected_machine.tag then
				wipe_on_map_tags(force_mem,player_mem.selected_machine.type,player_mem.selected_machine_recipe,player_mem.selected_machine_object)
			else
				show_on_map_tags(force_mem,player_mem.selected_machine.type,player_mem.selected_machine_recipe,player_mem.selected_machine_object)
			end
		end
	else
		force_mem.show_on_map = not force_mem.show_on_map
		if force_mem.show_on_map then 
			show_all_on_map_tags(force_mem)
		else
			wipe_all_on_map_tags(force_mem)
		end	
	end
	update_machines_stat()
	update_button_on_map(force_mem)		
	-- update_gui(player,false,false)
	update_guis()
end

script.on_event("effic_hotkey_on_map", on_hotkey_on_map)

--------------------------------------------------------------------------------------
local function on_hotkey_reset(event)
	local player = game.players[event.player_index]
	local player_mem = global.player_mem[player.index]
	local force_mem = global.force_mem[player.force.name]
	
	-- debug_print( "on_hotkey ", player.name, " ", event_name )
	
	player_mem.display_total = false
	if player.gui.left.frm_effic then
		player_mem.chk_effic_display_total.state = false
	end
	
	for _, machine in pairs( force_mem.assemblers ) do
		machine.n_on = 0
		machine.n_tot = 0
		display_on_map_tag(machine)
	end
	
	for _, machine in pairs( force_mem.furnaces ) do
		machine.n_on = 0
		machine.n_tot = 0
		display_on_map_tag(machine)
	end
	
	for _, machine in pairs( force_mem.drills ) do
		machine.n_on = 0
		machine.n_tot = 0
		display_on_map_tag(machine)
	end
	
	update_objects_production(force_mem,player_mem)
	copy_objects_ref(player_mem)
	calculate_objects(force_mem,player_mem)
	check_used_recipes_stat(force_mem,player_mem)
	
	update_gui(player,true,true)
end

script.on_event("effic_hotkey_reset", on_hotkey_reset)

--------------------------------------------------------------------------------------
local function on_gui_text_changed(event)
	local player = game.players[event.player_index]
	local event_name = event.element.name

	-- debug_print( "on_gui_text_changed ", player.name, " ", event_name )
	
	if event_name == "txt_effic_lim_under" then
		local player_mem = global.player_mem[player.index]
		local n = tonumber(player_mem.txt_effic_lim_under.text)
		if n ~= nil then 
			if n > 100 then n = 100 end
			if n < -100 then n = -100 end
			player_mem.lim_under = n 
			update_gui(player,false,false)
		end
		
	elseif event_name == "txt_effic_lim_over" then
		local player_mem = global.player_mem[player.index]
		local n = tonumber(player_mem.txt_effic_lim_over.text)
		if n ~= nil then 
			if n > 100 then n = 100 end
			if n < -100 then n = -100 end
			player_mem.lim_over = n 
			update_gui(player,false,false)
		end
		
	elseif event_name == "txt_effic_lim_lazy" then
		local player_mem = global.player_mem[player.index]
		local n = tonumber(player_mem.txt_effic_lim_lazy.text)
		if n ~= nil then 
			if n > 100 then n = 100 end
			if n < 0 then n = 0 end
			global.lim_lazy = n 
			update_gui(player,false,false)
		end
		
	elseif event_name == "txt_effic_lim_busy" then
		local player_mem = global.player_mem[player.index]
		local n = tonumber(player_mem.txt_effic_lim_busy.text)
		if n ~= nil then 
			if n > 100 then n = 100 end
			if n < 0 then n = 0 end
			global.lim_busy = n 
			update_gui(player,false,false)
		end
		
	elseif event_name == "txt_effic_polling" then
		local player_mem = global.player_mem[player.index]
		local n = tonumber(player_mem.txt_effic_polling.text)
		if n ~= nil then 
			set_polling(math.floor(n))
		end
	end
end

script.on_event(defines.events.on_gui_text_changed,on_gui_text_changed)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
	local player = game.players[event.player_index]
	local event_name = event.element.name
	local prefix = string.sub(event_name,1,14)
	local suffix = string.sub(event_name,17) 
	
	-- debug_print( "on_gui_click ", player.name, " ", event_name )
	-- debug_print( "on_gui_click ", prefix, "/", suffix )<

	if event_name == "but_effic" then -- main bar button
		if player.gui.left.frm_effic == nil then
			build_gui(player)
			update_gui(player,true,true)
		else
			close_gui(player)
		end

	elseif event_name == "but_effic_power" or event_name == "chk_effic_enabled" then -- enable/disable mod
		local player_mem = global.player_mem[player.index]
		global.enabled = not global.enabled
		
		for _, player in pairs(game.players) do
			-- if player.connected and player.gui.left.frm_effic then
			if player.gui.left.frm_effic then
				local player_mem = global.player_mem[player.index]
				if global.enabled then
					player_mem.but_effic_power.sprite = "sprite_main_ena_effic"
				else
					player_mem.but_effic_power.sprite = "sprite_main_dis_effic"
				end
			end
		end
		
	elseif event_name == "but_effic_prev" then -- previous in history
		local player_mem = global.player_mem[player.index]
		
		if player_mem.history_pos > 1 then
			player_mem.history_pos = player_mem.history_pos - 1
			recall_history(player_mem)
			update_gui(player,true,true)
		end
		
	elseif event_name == "but_effic_next" then -- next in history
		local player_mem = global.player_mem[player.index]
		
		if player_mem.history_pos < #player_mem.history then
			player_mem.history_pos = player_mem.history_pos + 1
			recall_history(player_mem)
			update_gui(player,true,true)
		end
	
	elseif event_name == "but_effic_reset" then -- reset counter un main pane
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
	
		player_mem.display_total = false
		player_mem.chk_effic_display_total.state = false
		
		for _, machine in pairs( force_mem.assemblers ) do
			machine.n_on = 0
			machine.n_tot = 0
			display_on_map_tag(machine)
		end
		
		for _, machine in pairs( force_mem.furnaces ) do
			machine.n_on = 0
			machine.n_tot = 0
			display_on_map_tag(machine)
		end
		
		for _, machine in pairs( force_mem.drills ) do
			machine.n_on = 0
			machine.n_tot = 0
			display_on_map_tag(machine)
		end
		
		update_objects_production(force_mem,player_mem)
		copy_objects_ref(player_mem)
		calculate_objects(force_mem,player_mem)
		check_used_recipes_stat(force_mem,player_mem)
		
		update_gui(player,true,true)
		
	elseif event_name == "but_effic_refresh" then -- refresh windows and map stats
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		
		for _, machine in pairs( force_mem.assemblers ) do
			display_on_map_tag(machine)
		end
		
		for _, machine in pairs( force_mem.furnaces ) do
			display_on_map_tag(machine)
		end
		
		for _, machine in pairs( force_mem.drills ) do
			display_on_map_tag(machine)
		end
		
		update_objects_production(force_mem,player_mem)
		calculate_objects(force_mem,player_mem)
		check_used_recipes_stat(force_mem,player_mem)
		
		update_gui(player,true,true)
		
	elseif event_name == "chk_effic_auto_refresh" then -- auto refresh windows stat every 3 sec
		local player_mem = global.player_mem[player.index]
		player_mem.auto_refresh = player_mem.chk_effic_auto_refresh.state
		
	elseif event_name == "but_effic_map_toggle" then -- show/hide all assemblers/furnaces employement tags
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		force_mem.show_on_map = not force_mem.show_on_map
		if force_mem.show_on_map then
			show_all_on_map_tags(force_mem)
		else
			wipe_all_on_map_tags(force_mem)
		end
		update_machines_stat()
		update_button_on_map(force_mem)		
		-- update_gui(player,false,false)
		update_guis()

	elseif event_name == "but_effic_options" then -- toggle options window
		build_menu_options(player)
		
	elseif event_name == "but_effic_help" then -- display help
		build_menu_help(player)
		
	elseif event_name == "but_effic_help_close" then -- display help
		build_menu_help(player,false)
		
	elseif event_name == "but_effic_test" then -- test
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		
		-- debug_print("RAZ")
		-- debug_print(" groups=", #force_mem.groups, "recipes=", #force_mem.recipes_stat, " objects=", #player_mem.objects )
		-- init_recipes_stat(force_mem)
		-- complete_techno_recipes_stat(force_mem)
		-- complete_prod_recipes_stat(force_mem)
		-- debug_recipes(force_mem)
		
		init_groups(force_mem)
		debug_groups()
		
		-- debug_objects(player_mem)
		-- debug_production(force_mem)
		-- debug_print(" groups=", #force_mem.groups, "recipes=", #force_mem.recipes_stat, " objects=", #player_mem.objects )
	
	elseif event_name == "chk_effic_display_total" then -- display total/counter value
		local player_mem = global.player_mem[player.index]
		player_mem.display_total = player_mem.chk_effic_display_total.state
		update_gui(player,false,false)
		
	elseif event_name == "but_effic_unit_s" then -- change time unit
		local player_mem = global.player_mem[player.index]
		player_mem.time_unit = time_units.per_s
		update_gui(player,false,false)
			
	elseif event_name == "but_effic_unit_m" then -- change time unit
		local player_mem = global.player_mem[player.index]
		player_mem.time_unit = time_units.per_m
		update_gui(player,false,false)
			
	elseif event_name == "but_effic_unit_h" then -- change time unit
		local player_mem = global.player_mem[player.index]
		player_mem.time_unit = time_units.per_h
		update_gui(player,false,false)
		
	elseif event_name == "but_effic_rec" then -- sniff the first recipe of an item held in hand
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		local cursor_stack = player.cursor_stack
		
		if cursor_stack and cursor_stack.valid_for_read then
			local obj_name = cursor_stack.name
			local rec_name
			for _, recipe in pairs(player.force.recipes) do
				for _, prod in pairs(recipe.products) do
					if prod.name == obj_name then
						rec_name = recipe.name
						break
					end
				end
				if rec_name then break end
			end
			if rec_name then
				build_menu_recipes(player,false)
				player_mem.recipe_sel_name = rec_name
				add_history(player_mem)
				update_gui(player,true,false)
			end
		else
			build_menu_objects(player,false)
			build_menu_recipes(player)
		end
		
	elseif event_name == "but_effic_res" then -- research the techno
		local player_mem = global.player_mem[player.index]
		local force = player.force
		local force_mem = global.force_mem[player.force.name]
		local techno = player_mem.recipe_stat_sel.techno
		
		-- if not techno.researched and force.current_research == nil then
		if techno and not techno.researched then
			force.current_research = techno.name
		end

	elseif prefix == "but_effic_obj_" then -- click object in recipe ingrs/prods list
		local player_mem = global.player_mem[player.index]
		player_mem.object_sel_name = suffix
		add_history(player_mem)
		update_gui(player,false,true)
		
	elseif event_name == "but_effic_obj" then -- sniff an item held in hand
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		local cursor_stack = player.cursor_stack
		
		if cursor_stack and cursor_stack.valid_for_read then
			build_menu_objects(player,false)
			player_mem.object_sel_name = cursor_stack.name
			add_history(player_mem)
			update_gui(player,false,true)
		else
			build_menu_recipes(player,false)
			build_menu_objects(player)
		end

	elseif event_name == "chk_effic_unused" then -- show unused recipes
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		player_mem.show_unused = event.element.state
		if not player_mem.show_unused then 
			check_used_recipes_stat(force_mem,player_mem)
		end
		update_gui(player,false,true)

	elseif event_name == "chk_effic_hidden" then -- show hidden recipes
		local player_mem = global.player_mem[player.index]
		local force_mem = global.force_mem[player.force.name]
		player_mem.show_hidden = event.element.state
		update_gui(player,false,true)

	elseif prefix == "but_effic_rec_" then -- click recipe in object pane
		local player_mem = global.player_mem[player.index]
		player_mem.recipe_sel_name = suffix
		add_history(player_mem)
		update_gui(player,true,false)
		
	elseif prefix == "but_effic_oma_" then -- click a on-map icon
		local player_mem = global.player_mem[player.index]
		local force = player.force
		local force_mem = global.force_mem[force.name]
		local recipe
		
		if suffix == "" then
			if player_mem.recipe_stat_sel then
				recipe = player_mem.recipe_stat_sel.recipe
			end
		else
			recipe = force.recipes[suffix]
		end
	
		if recipe then
			force_mem.show_on_map = true
			toggle_on_map_tags(force_mem,recipe)
			update_machines_stat()
			update_button_on_map(force_mem)		
			-- update_gui(player,false,false)
			update_guis()
		end
		
	elseif event_name == "but_effic_clean" then -- clean history
		local player_mem = global.player_mem[player.index]
		player_mem.history = {}
		player_mem.history_pos = 0
		
	elseif event_name == "but_effic_options_close" then -- close options window
		build_menu_options(player,false)
		
	elseif prefix == "but_effic_rlg_" then -- click group in recipes list
		local player_mem = global.player_mem[player.index]
		-- debug_print(suffix)
		player_mem.group_sel_name = suffix
		build_menu_recipes(player,true)
		
	elseif prefix == "but_effic_rlr_" then -- click recipe in recipes list
		local player_mem = global.player_mem[player.index]
		-- debug_print(suffix)
		player_mem.recipe_sel_name = suffix
		add_history(player_mem)
		update_gui(player,true,false)
		if player_mem.auto_close then
			build_menu_recipes(player, false)
		end
		
	elseif event_name == "but_effic_recl_close" then -- close recipes window
		build_menu_recipes(player,false)
		
	elseif event_name == "chk_effic_recl_close" then -- auto close recipes window
		local player_mem = global.player_mem[player.index]
		player_mem.auto_close = player_mem.chk_effic_recl_close.state
		
	elseif prefix == "but_effic_ilg_" then -- click group in items list
		local player_mem = global.player_mem[player.index]
		-- debug_print(suffix)
		player_mem.group_sel_name = suffix
		build_menu_objects(player,true)
		
	elseif prefix == "but_effic_ili_" then -- click item in items list
		local player_mem = global.player_mem[player.index]
		-- debug_print(suffix)
		player_mem.object_sel_name = suffix
		add_history(player_mem)
		update_gui(player,false,true)
		if player_mem.auto_close then
			build_menu_objects(player, false)
		end
		
	elseif event_name == "but_effic_itml_close" then -- close recipes window
		build_menu_objects(player,false)
		
	elseif event_name == "chk_effic_itml_close" then -- auto close recipes window
		local player_mem = global.player_mem[player.index]
		player_mem.auto_close = player_mem.chk_effic_itml_close.state
	end	
end

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, on_gui_click)

--------------------------------------------------------------------------------------

local interface = {}

function interface.reset()
	debug_print( "reset" )
	
	init_globals()
	init_forces()
	init_players()
	
	for _, player in pairs(game.players) do
		build_bar(player, true)
	end

	close_guis() -- to avoid errors		

	reset_data()
end

remote.add_interface( "effi", interface )

-- /c remote.call( "effi", "reset" )