data:extend({
	{
		type = "container",
		name = "tomb-stone",
		icon = "__TombStones__/graphics/tomb-stone.png",
		icon_size = 32,
		order = "-k[tomb-stone]-a[small]",
		flags = {"placeable-neutral", "not-repairable"},
		minable = {mining_time = 15.0},
		max_health = 2000,
		corpse = "small-remnants",
		resistances = 
		{
			{
				type = "physical",
				decrease = 3,
				percent = 20
			},
			{
				type = "impact",
				decrease = 45,
				percent = 60
			},
			{
				type = "explosion",
				decrease = 10,
				percent = 30
			},
			{
				type = "fire",
				percent = 100
			},
			{
				type = "laser",
				percent = 70
			}
		},
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.45}, {0.5, 0.5}},
		inventory_size = 1200,
		vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.8 },
		picture =
		{
			filename = "__TombStones__/graphics/tomb-stone.png",
			priority = "high",
			width = 48,
			height = 34,
			shift = {0.3, -0.1}
		},
	},	
	{
		type = "simple-entity",
		name = "memorial-stone",
		flags = {"placeable-neutral", "not-repairable"},
		icon = "__TombStones__/graphics/tomb-stone.png",
		icon_size = 32,
		subgroup = "grass",
		order = "b[decorative]-k[memorial-stone]-a[small]",
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.45}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.8 },
		minable = 
		{
			mining_particle = "stone-particle",
			mining_time = 20,
			result = "stone",
			count = 20
		},
		loot =
		{
			{item = "stone", probability = 1, count_min = 5, count_max = 10}
		},
		mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
		render_layer = "object",
		max_health = 1200,
		resistances = 
		{
			{
				type = "physical",
				decrease = 3,
				percent = 20
			},
			{
				type = "impact",
				decrease = 45,
				percent = 60
			},
			{
				type = "explosion",
				decrease = 10,
				percent = 30
			},
			{
				type = "fire",
				percent = 100
			},
			{
				type = "laser",
				percent = 70
			}
		},
		pictures =
		{
			filename = "__TombStones__/graphics/tomb-stone.png",
			width = 48,
			height = 34,
			shift = {0.3, -0.1}
		}
	}
})