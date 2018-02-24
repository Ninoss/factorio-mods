
data:extend(
{

	{
		type = "recipe",
		name = "yir_4a_container_crrecipe",
		category = "yir_rc_wsw", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 3.00,
		ingredients = {			
			{ type = "item", name = "yir_frame_waggon" , amount = 1.0, },			
			{ type = "item", name = "yir_radsatz_waggon" , amount = 2.0, },			
			{ type = "item", name = "yir_color_red" , amount = 8.0, },			
			{ type = "item", name = "yir_color_white" , amount = 2.0, },			
			{ type = "item", name = "yir_coin" , amount = 4.0, },					
		},
		results = {
			{ type = "item", name = "yir_4a_container_cr", amount = 1, },
		},		
		order = "cr3", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_4a_container_cr", icon="__z_yira_american__/graphics/4a_container_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="cr3",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_4a_container_cr", 
	},

	{
		type = "recipe",
		name = "yir_4a_clean_cr_recipe",
		category = "yir_rc_wsw", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 3.00,
		ingredients = {			
			{ type = "item", name = "yir_frame_waggon" , amount = 1.0, },			
			{ type = "item", name = "yir_radsatz_waggon" , amount = 2.0, },			
			{ type = "item", name = "yir_color_red" , amount = 8.0, },			
			{ type = "item", name = "yir_color_white" , amount = 2.0, },			
			{ type = "item", name = "yir_coin" , amount = 4.0, },					
		},
		results = {
			{ type = "item", name = "yir_4a_clean_cr", amount = 1, },
		},		
		order = "cr4", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_4a_clean_cr", icon="__z_yira_american__/graphics/4a_cr_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="cr4",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_4a_clean_cr", 
	},

	{
		type = "cargo-wagon",
		name = "yir_4a_container_cr",
		icon = "__z_yira_american__/graphics/4a_container_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		inventory_size = 30,
		minable = {mining_time = 1, result = "yir_4a_container_cr"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 600,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-0.6, -2.4}, {0.6, 2.4}},
		selection_box = {{-1.0, -2.7}, {1, 3.2}},		
		connection_distance = 3, joint_distance = 4,
		weight = 1500,
		max_speed = 1.2,
		braking_force = 2,
		friction_force = 0.0015,
		air_resistance = 0.002,
		energy_per_hit_point = 5,    
		resistances =
		{
			{type = "fire", decrease = 15, percent = 50 },
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
			{type = "explosion",decrease = 15,percent = 30},
			{type = "acid",decrease = 10,percent = 20}
		},
		vertical_selection_shift = -0.5,
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			back_equals_front = true,
			direction_count = 64,
			filename = "__z_yira_american__/graphics/4a_container_sheet.png",      
			line_length = 8,
			lines_per_file = 8,
			shift = {0.42, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-wheels.ogg",
				volume = 0.5
			},
			match_volume_to_activity = true,
		},
		crash_trigger = crash_trigger(),
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		sound_minimum_speed = 0.5;
		vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
	},  
	
	{
		type = "cargo-wagon",
		name = "yir_4a_clean_cr",
		icon = "__z_yira_american__/graphics/4a_cr_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		inventory_size = 30,
		minable = {mining_time = 1, result = "yir_4a_clean_cr"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 600,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-0.6, -2.4}, {0.6, 2.4}},
		selection_box = {{-1.0, -2.7}, {1, 3.2}},		
		connection_distance = 3, joint_distance = 4,
		weight = 1500,
		max_speed = 1.2,
		braking_force = 2,
		friction_force = 0.0015,
		air_resistance = 0.002,
		energy_per_hit_point = 5,    
		resistances =
		{
			{type = "fire", decrease = 15, percent = 50 },
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
			{type = "explosion",decrease = 15,percent = 30},
			{type = "acid",decrease = 10,percent = 20}
		},
		vertical_selection_shift = -0.5,
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			back_equals_front = true,
			direction_count = 64,
			filename = "__z_yira_american__/graphics/4a_cr_sheet.png",      
			line_length = 8,
			lines_per_file = 8,
			shift = {0.42, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-wheels.ogg",
				volume = 0.5
			},
			match_volume_to_activity = true,
		},
		crash_trigger = crash_trigger(),
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		sound_minimum_speed = 0.5;
		vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
	},  
	
})