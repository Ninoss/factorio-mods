data:extend(
{
  {
    type = 'technology',
    name='alien-bioengineering',
    icon = '__AlienWall__/graphics/icons/tech/alien-bioconstruct.png',
	icon_size = 128,
    effects = {{type = 'unlock-recipe', recipe='alien-bioconstruct'}},
    prerequisites = {},
    unit =
	{
      count = 50,
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 1},
      },
      time = 15
    },
    order='a-e-a',
  },
  {
    type = "technology",
    name="alien-hybridization1",
    icon = "__AlienWall__/graphics/icons/wall/hybrid-wall.png",
	icon_size = 32,
    effects = {{type = "unlock-recipe", recipe="hybridized-wall"}},
    prerequisites = {"stone-walls", 'alien-bioengineering'},
	unit =
    {
      count = 100,
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 1},
		{"military-science-pack", 1},
      },
      time = 30
    },
    order="a-e-b",
  },
  {
    type = "technology",
    name="alien-hybridization2",
    icon = "__AlienWall__/graphics/icons/gate/hybrid-gate.png",
	icon_size = 32,
    effects = {{type = "unlock-recipe", recipe="hybridized-gate"}},
    prerequisites = {"alien-hybridization1", "gates"},
	unit =
    {
      count = 200,
      ingredients =
      {
        {"science-pack-1", 3},
        {"science-pack-2", 2},
		{"military-science-pack", 1},
      },
      time = 60
    },
    order="a-e-c",
  },
  {
    type = "technology",
    name="alien-hybrid-upgrade1",
    icon = "__AlienWall__/graphics/icons/wall/hybrid-wall.png",
	icon_size = 32,
    prerequisites = {"alien-hybridization2"},
	unit =
    {
      count = 100,
      ingredients =
      {
        {"science-pack-1", 3},
        {"science-pack-2", 2},
      },
      time = 20
    },
    order="a-f-a",
  },
  {
    type = "technology",
    name="alien-hybrid-upgrade2",
    icon = "__AlienWall__/graphics/icons/wall/hybrid-wall.png",
	icon_size = 32,
    prerequisites = {"alien-hybrid-upgrade1"},
	unit =
    {
      count = 200,
      ingredients =
      {
        {"science-pack-1", 3},
        {"science-pack-2", 2},
		{"military-science-pack", 1},
      },
      time = 30
    },
    order="a-f-b",
	upgrade = "true",
  },
  {
    type = "technology",
    name="alien-hybrid-upgrade3",
    icon = "__AlienWall__/graphics/icons/wall/hybrid-wall.png",
	icon_size = 32,
    prerequisites = {"alien-hybrid-upgrade2"},
	unit =
    {
      count = 200,
      ingredients =
      {
        {"science-pack-1", 3},
        {"science-pack-2", 3},
		{"science-pack-3", 2},
		      },
      time = 60
    },
    order="a-f-c",
	upgrade = "true",
  },
  {
    type = "technology",
    name="alien-hybrid-upgrade4",
    icon = "__AlienWall__/graphics/icons/wall/hybrid-wall.png",
	icon_size = 32,
    prerequisites = {"alien-hybrid-upgrade3"},
	unit =
    {
      count = 350,
      ingredients =
      {
        {"science-pack-1", 3},
        {"science-pack-2", 3},
		{"science-pack-3", 2},
		{"military-science-pack", 2},
		      },
      time = 60
    },
    order="a-f-d",
	upgrade = "true",
  }
})