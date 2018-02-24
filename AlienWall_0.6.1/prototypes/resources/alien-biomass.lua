data:extend(
{
  {
    type = "noise-layer",
    name = "alien-biomass"
  },
  {
    type = "autoplace-control",
    name = "alien-biomass",
    richness = true,
    order = "b-e",
	category = "resource"
  },
  {
    type = "resource",
    name = "alien-biomass",
    icon = "__AlienWall__/graphics/icons/biomass/alien-artifacts.png",
	icon_size = 32,
    flags = {"placeable-neutral"},
    order="a-b-a",
    minimum = 10,
    normal = 100,

    minable =
    {
      hardness = 0.9,
      mining_particle = "copper-ore-particle",
      mining_time = 2,
      result = "alien-biomass"
    },
    collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      control = "alien-biomass",
      sharpness = 1,
      richness_multiplier = 1500,
      richness_base = 50,
      size_control_multiplier = 0.06,
      peaks = {
        {
          influence = 0.2,
          starting_area_weight_optimal = 0,
          starting_area_weight_range = 0,
          starting_area_weight_max_range = 2,
        },
        {
          influence = 0.3,
          starting_area_weight_optimal = 1,
          starting_area_weight_range = 0,
          starting_area_weight_max_range = 2,
        },
        {
          influence = 0.3,
          noise_layer = "alien-biomass",
          noise_octaves_difference = -2.3,
          noise_persistence = 0.4,
          starting_area_weight_optimal = 0.5,
          starting_area_weight_range = 0,
          starting_area_weight_max_range = 1,
        },
        {
          influence = -0.2,
          max_influence = 0,
          noise_layer = "iron-ore",
          noise_octaves_difference = -2.3,
          noise_persistence = 0.45,
        },
        {
          influence = -0.2,
          max_influence = 0,
          noise_layer = "coal",
          noise_octaves_difference = -2.3,
          noise_persistence = 0.45,
        },
        {
          influence = -0.2,
          max_influence = 0,
          noise_layer = "stone",
          noise_octaves_difference = -3,
          noise_persistence = 0.45,
        },
      },
    },
    stage_counts = {1000, 600, 400, 200, 100, 50, 20, 1},
    stages =
	{
		sheet = 
		{
			filename = "__AlienWall__/graphics/entity/biomass/alien-artifacts.png",
		priority = "extra-high",
		width = 38,
		height = 38,
		frame_count = 4,
		variation_count = 8
		},
    },
    map_color = {r=128, g=26, b=188}
  },
})
