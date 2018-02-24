
data:extend(
{
	-- 
	{
		type = "recipe",
		name = "yir_emdf7a_mn_recipe",
		category = "yir_rc_wsl", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 5.00,
		ingredients = {			
			{ type = "item", name = "yir_coin" , amount = 80.0, },
		},
		results = {
			{ type = "item", name = "yir_emdf7a_mn", amount = 1, },
		},		
		order = "lsw1", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_emdf7a_mn", icon="__z_yira_american__/graphics/yir_emdf7a_mn_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="d3",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_emdf7a_mn", 
	},

	{
		type = "locomotive",
		name = "yir_emdf7a_mn",
		icon = "__z_yira_american__/graphics/yir_emdf7a_mn_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		minable = {mining_time = 1, result = "yir_emdf7a_mn"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 1500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",

		collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
		selection_box = {{-1, -3}, {1, 3}},
		drawing_box = {{-1, -4}, {1, 3}},
		connection_distance = 3, joint_distance = 4,		

		weight = 2000,
		max_speed = 0.60,
		max_power = "1100kW",
		reversing_power_modifier = 0.6,
		braking_force = 14,
		friction_force = 0.00225,
		-- this is a percentage of current speed that will be subtracted
		air_resistance = 0.00225,
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 5,
		resistances =
		{
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
		},
		burner =
		{
			fuel_category = "chemical",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "train-smoke",
					deviation = {0.3, 0.3},
					frequency = 100,
					position = {0, 0},
					starting_frame = 0,
					starting_frame_deviation = 60,
					height = 2,
					height_deviation = 0.5,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.1,
				}
			}
		},		
		--[[
		energy_source =
		{
			type = "burner",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "smoke",
					deviation = {0.1, 0.1},
					frequency = 30,
					position = {0, 1},
					slow_down_factor = 15,
					starting_frame = 1,
					starting_frame_deviation = 5,
					starting_frame_speed = 0,
					starting_frame_speed_deviation = 1,
					height = 1,
					height_deviation = 0.2,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.06,
				}
			}
		},
		]]
		front_light =
		{
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {-0.6, -16},
				size = 2,
				intensity = 0.8
			},
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {0.6, -16},
				size = 2,
				intensity = 0.8
			}
		},
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__z_yira_american__/graphics/emd_f7a_mn_sheet-0.png",
				"__z_yira_american__/graphics/emd_f7a_mn_sheet-1.png",
			},
			line_length = 8,
			lines_per_file = 8,
			shift = {0.20, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",

		stop_trigger =
		{
			-- left side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the left
				speed = {-0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
			},
			-- right side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the right
				speed = {0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
			},
			{
				type = "play-sound",
				sound =
				{
					{
						filename = "__base__/sound/train-breaks.ogg",
						volume = 0.6
					},
				}
			},
		},
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-engine.ogg",
				volume = 0.5
			},
			match_speed_to_activity = true,
		},
		open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
		close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
		sound_minimum_speed = 0.2;
	},
	
	{
		type = "recipe",
		name = "yir_emdf7b_mn_recipe",
		category = "yir_rc_wsl", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 5.00,
		ingredients = {			
			{ type = "item", name = "yir_coin" , amount = 80.0, },
		},
		results = {
			{ type = "item", name = "yir_emdf7b_mn", amount = 1, },
		},		
		order = "lsw1", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_emdf7b_mn", icon="__z_yira_american__/graphics/yir_emdf7b_mn_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="d3",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_emdf7b_mn", 
	},

	{
		type = "locomotive",
		name = "yir_emdf7b_mn",
		icon = "__z_yira_american__/graphics/yir_emdf7b_mn_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		minable = {mining_time = 1, result = "yir_emdf7b_mn"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 1500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",

		collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
		selection_box = {{-1, -3}, {1, 3}},
		drawing_box = {{-1, -4}, {1, 3}},
		connection_distance = 3, joint_distance = 4,		

		weight = 2000,
		max_speed = 0.60,
		max_power = "1100kW",
		reversing_power_modifier = 0.6,
		braking_force = 14,
		friction_force = 0.00225,
		-- this is a percentage of current speed that will be subtracted
		air_resistance = 0.00225,
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 5,
		resistances =
		{
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
		},
		burner =
		{
			fuel_category = "chemical",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "train-smoke",
					deviation = {0.3, 0.3},
					frequency = 100,
					position = {0, 0},
					starting_frame = 0,
					starting_frame_deviation = 60,
					height = 2,
					height_deviation = 0.5,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.1,
				}
			}
		},	
		--[[	
		energy_source =
		{
			type = "burner",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "smoke",
					deviation = {0.1, 0.1},
					frequency = 30,
					position = {0, 1},
					slow_down_factor = 15,
					starting_frame = 1,
					starting_frame_deviation = 5,
					starting_frame_speed = 0,
					starting_frame_speed_deviation = 1,
					height = 1,
					height_deviation = 0.2,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.06,
				}
			}
		},
		]]
		front_light =
		{
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {-0.6, -16},
				size = 2,
				intensity = 0.8
			},
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {0.6, -16},
				size = 2,
				intensity = 0.8
			}
		},
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__z_yira_american__/graphics/emd_f7b_mn_sheet-0.png",
				"__z_yira_american__/graphics/emd_f7b_mn_sheet-1.png",
			},
			line_length = 8,
			lines_per_file = 8,
			shift = {0.42, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",

		stop_trigger =
		{
			-- left side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the left
				speed = {-0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
			},
			-- right side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the right
				speed = {0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
			},
			{
				type = "play-sound",
				sound =
				{
					{
						filename = "__base__/sound/train-breaks.ogg",
						volume = 0.6
					},
				}
			},
		},
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-engine.ogg",
				volume = 0.5
			},
			match_speed_to_activity = true,
		},
		open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
		close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
		sound_minimum_speed = 0.2;
	},
	
	{
		type = "recipe",
		name = "yir_emdf7a_cr_recipe",
		category = "yir_rc_wsl", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 5.00,
		ingredients = {			
			{ type = "item", name = "yir_coin" , amount = 100.0, },
		},
		results = {
			{ type = "item", name = "yir_emdf7a_cr", amount = 1, },
		},		
		order = "lsw1", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_emdf7a_cr", icon="__z_yira_american__/graphics/yir_emdf7a_cr_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="d3",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_emdf7a_cr", 
	},

	{
		type = "locomotive",
		name = "yir_emdf7a_cr",
		icon = "__z_yira_american__/graphics/yir_emdf7a_cr_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		minable = {mining_time = 1, result = "yir_emdf7a_cr"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 1500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",

		collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
		selection_box = {{-1, -3}, {1, 3}},
		drawing_box = {{-1, -4}, {1, 3}},
		connection_distance = 3, joint_distance = 4,		

		weight = 2000,
		max_speed = 0.60,
		max_power = "1100kW",
		reversing_power_modifier = 0.6,
		braking_force = 14,
		friction_force = 0.00225,
		-- this is a percentage of current speed that will be subtracted
		air_resistance = 0.00225,
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 5,
		resistances =
		{
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
		},
		burner =
		{
			fuel_category = "chemical",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "train-smoke",
					deviation = {0.3, 0.3},
					frequency = 100,
					position = {0, 0},
					starting_frame = 0,
					starting_frame_deviation = 60,
					height = 2,
					height_deviation = 0.5,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.1,
				}
			}
		},		
		--[[
		energy_source =
		{
			type = "burner",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "smoke",
					deviation = {0.1, 0.1},
					frequency = 30,
					position = {0, 0},
					slow_down_factor = 15,
					starting_frame = 1,
					starting_frame_deviation = 5,
					starting_frame_speed = 0,
					starting_frame_speed_deviation = 1,
					height = 1,
					height_deviation = 0.2,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.06,
				}
			}
		},
		]]
		front_light =
		{
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {-0.6, -16},
				size = 2,
				intensity = 0.8
			},
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {0.6, -16},
				size = 2,
				intensity = 0.8
			}
		},
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__z_yira_american__/graphics/emd_f7a_cr_sheet-0.png",
				"__z_yira_american__/graphics/emd_f7a_cr_sheet-1.png",
			},
			line_length = 8,
			lines_per_file = 8,
			shift = {0.2, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",

		stop_trigger =
		{
			-- left side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the left
				speed = {-0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
			},
			-- right side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the right
				speed = {0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
			},
			{
				type = "play-sound",
				sound =
				{
					{
						filename = "__base__/sound/train-breaks.ogg",
						volume = 0.6
					},
				}
			},
		},
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-engine.ogg",
				volume = 0.5
			},
			match_speed_to_activity = true,
		},
		open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
		close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
		sound_minimum_speed = 0.2;
	},
	
	{
		type = "recipe",
		name = "yir_emdf7b_cr_recipe",
		category = "yir_rc_wsl", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 5.00,
		ingredients = {			
			{ type = "item", name = "yir_coin" , amount = 100.0, },
		},
		results = {
			{ type = "item", name = "yir_emdf7b_cr", amount = 1, },
		},		
		order = "lsw1", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_emdf7b_cr", icon="__z_yira_american__/graphics/yir_emdf7b_cr_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="d3",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_emdf7b_cr", 
	},

	{
		type = "locomotive",
		name = "yir_emdf7b_cr",
		icon = "__z_yira_american__/graphics/yir_emdf7b_cr_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		minable = {mining_time = 1, result = "yir_emdf7b_cr"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 1500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		
		collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
		selection_box = {{-1, -3}, {1, 3}},
		drawing_box = {{-1, -4}, {1, 3}},
		connection_distance = 3, joint_distance = 4,		

		weight = 2000,
		max_speed = 0.60,
		max_power = "1100kW",
		reversing_power_modifier = 0.6,
		braking_force = 14,
		friction_force = 0.00225,
		-- this is a percentage of current speed that will be subtracted
		air_resistance = 0.00225,
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 5,
		resistances =
		{
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
		},
		burner =
		{
			fuel_category = "chemical",
			effectivity = 1,
			fuel_inventory_size = 3,
			smoke =
			{
				{
					name = "train-smoke",
					deviation = {0.3, 0.3},
					frequency = 100,
					position = {0, 0},
					starting_frame = 0,
					starting_frame_deviation = 60,
					height = 2,
					height_deviation = 0.5,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.1,
				}
			}
		},		
		--[[
		energy_source =
		{
			type = "burner",
			effectivity = 1,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "smoke",
					deviation = {0.1, 0.1},
					frequency = 30,
					position = {0, 0},
					slow_down_factor = 15,
					starting_frame = 1,
					starting_frame_deviation = 5,
					starting_frame_speed = 0,
					starting_frame_speed_deviation = 1,
					height = 1,
					height_deviation = 0.2,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.06,
				}
			}
		},
		]]
		front_light =
		{
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {-0.6, -16},
				size = 2,
				intensity = 0.8
			},
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {0.6, -16},
				size = 2,
				intensity = 0.8
			}
		},
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__z_yira_american__/graphics/emd_f7b_cr_sheet-0.png",
				"__z_yira_american__/graphics/emd_f7b_cr_sheet-1.png",
			},
			line_length = 8,
			lines_per_file = 8,
			shift = {0.4, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",

		stop_trigger =
		{
			-- left side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the left
				speed = {-0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
			},
			-- right side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the right
				speed = {0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
			},
			{
				type = "play-sound",
				sound =
				{
					{
						filename = "__base__/sound/train-breaks.ogg",
						volume = 0.6
					},
				}
			},
		},
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-engine.ogg",
				volume = 0.5
			},
			match_speed_to_activity = true,
		},
		open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
		close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
		sound_minimum_speed = 0.2;
	},

	{
		type = "recipe",
		name = "yir_es44cr_recipe",
		category = "yir_rc_wsl", -- Workshop for Locomotives
		enabled = "true",
		energy_required = 5.00,
		ingredients = {			
			{ type = "item", name = "yir_frame_loco_diesel" , amount = 2.0, },
			{ type = "item", name = "yir_radsatz_locos" , amount = 6.0, },
			{ type = "item", name = "yir_color_red" , amount = 12.0, },
			{ type = "item", name = "yir_color_white" , amount = 2.0, },
			{ type = "item", name = "yir_coin" , amount = 20.0, },
		},
		results = {
			{ type = "item", name = "yir_es44cr", amount = 1, },
		},		
		order = "cr1", group = "yuoki_railway", subgroup = "yir_americans",
	},	

	{
		type="item", name="yir_es44cr", icon="__z_yira_american__/graphics/ES44AC_icon.png", flags={"goes-to-quickbar"}, 
		group="yuoki_railway", subgroup="yir_americans", order="cr1",  
		stack_size = 10, default_request_amount = 5, icon_size = 32,
		place_result="yir_es44cr", 
	},

	{
		type = "locomotive",
		name = "yir_es44cr",
		icon = "__z_yira_american__/graphics/ES44AC_icon.png",icon_size = 32,
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		minable = {mining_time = 1, result = "yir_es44cr"},
		mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
		max_health = 1500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
	
		collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
		selection_box = {{-1, -3}, {1, 3}},
		drawing_box = {{-1, -4}, {1, 3}},
		connection_distance = 3, joint_distance = 4,		

		weight = 2000,
		max_speed = 0.75,
		max_power = "1500kW",
		reversing_power_modifier = 0.6,
		braking_force = 14,
		friction_force = 0.00225,
		-- this is a percentage of current speed that will be subtracted
		air_resistance = 0.00225,
		vertical_selection_shift = -0.5,
		energy_per_hit_point = 5,
		resistances =
		{
			{type = "physical", decrease = 15, percent = 30 },
			{type = "impact",decrease = 50,percent = 60},
		},
		burner =
		{
			fuel_category = "chemical",
			effectivity = 1.25,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "train-smoke",
					deviation = {0.3, 0.3},
					frequency = 100,
					position = {0, 0},
					starting_frame = 0,
					starting_frame_deviation = 60,
					height = 2,
					height_deviation = 0.5,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.1,
				}
			}
		},		
		--[[
		energy_source =
		{
			type = "burner",
			effectivity = 1.25,
			fuel_inventory_size = 2,
			smoke =
			{
				{
					name = "smoke",
					deviation = {0.1, 0.1},
					frequency = 30,
					position = {0, 0},
					slow_down_factor = 15,
					starting_frame = 1,
					starting_frame_deviation = 5,
					starting_frame_speed = 0,
					starting_frame_speed_deviation = 1,
					height = 1,
					height_deviation = 0.2,
					starting_vertical_speed = 0.2,
					starting_vertical_speed_deviation = 0.06,
				}
			}
		},
		]]
		front_light =
		{
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {-0.6, -16},
				size = 2,
				intensity = 0.8
			},
			{
				type = "oriented",
				minimum_darkness = 0.3,
				picture =
				{
					filename = "__core__/graphics/light-cone.png",
					priority = "medium",
					scale = 2,
					width = 200,
					height = 200
				},
				shift = {0.6, -16},
				size = 2,
				intensity = 0.8
			}
		},
		--back_light = rolling_stock_back_light(),
		--stand_by_light = rolling_stock_stand_by_light(),
		pictures =
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__z_yira_american__/graphics/ES44AC_sheet-0.png",
				"__z_yira_american__/graphics/ES44AC_sheet-1.png",
			},
			line_length = 8,
			lines_per_file = 8,
			shift = {0.4, -1.125}
		},
		wheels = standard_train_wheels,
		rail_category = "regular",

		stop_trigger =
		{
			-- left side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the left
				speed = {-0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
			},
			-- right side
			{
				type = "create-trivial-smoke",
				repeat_count = 75,
				smoke_name = "smoke-train-stop",
				initial_height = 0,
				-- smoke goes to the right
				speed = {0.03, 0},
				speed_multiplier = 0.75,
				speed_multiplier_deviation = 1.1,
				offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
			},
			{
				type = "play-sound",
				sound =
				{
					{
						filename = "__base__/sound/train-breaks.ogg",
						volume = 0.6
					},
				}
			},
		},
		drive_over_tie_trigger = drive_over_tie(),
		tie_distance = 50,
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound =
			{
				filename = "__base__/sound/train-engine.ogg",
				volume = 0.5
			},
			match_speed_to_activity = true,
		},
		open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
		close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
		sound_minimum_speed = 0.2;
	},	
	
})