data:extend({
  {
    type = "item",
    name = "alien-biomass",
    icon = "__AlienWall__/graphics/icons/biomass/alien-artifacts.png",
	icon_size = 32,
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-resource",
    order = "f[alien-biomass]",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "alien-bioconstruct",
	--icon = '__AlienWall__/graphics/icons/biomass/alien-bioconstruct.png',
	--icon_size = 32,
	flags = {"goes-to-main-inventory"},
    subgroup = "materials",
    order = "a[alien-bioconstruct]-a",
    category = "crafting",
    enabled = "false",
    ingredients = {{"alien-biomass", 5}},
    result = "alien-bioconstruct"
  },
  
    {
    type = "item",
    name = "alien-bioconstruct",
    icon = "__AlienWall__/graphics/icons/biomass/alien-bioconstruct.png",
	icon_size = 32,
    flags = {"goes-to-main-inventory"},
    subgroup = "materials",
    order = "a[exo-skeleton]-a",
    stack_size = 50,
	durability = 1,
  }
  --Future stuff
  --[[,

  {
      type = "recipe",
      name = "alien-fragments",
      enabled = "false",
      ingredients = {
        {'alien-bioconstruct', 1},
        {'iron-plate', 1}
      },
      result = "alien-fragments"
  },
  
  {
    type = "tool",
    name = "alien-fragments",
    icon = "__AlienWall__/graphics/icons/biomass/alien-fragments.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "materials",
    order = "a[exo-skeleton]-a",
    stack_size = 50,
	durability = 1,
  },

  {
      type = "recipe",
      name = "endo-skeleton",
      enabled = "false",
      ingredients = {
        {'alien-bioconstruct', 2},
        {'steel-plate', 3},
		{'alien-fragments', 1}
      },
      result = "endo-skeleton"
  },
  
  {
    type = "tool",
    name = "endo-skeleton",
    icon = "__AlienWall__/graphics/icons/biomass/endo-skeleton.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "materials",
    order = "a[exo-skeleton]-b",
    stack_size = 50,
	durability = 1,
  },
  
  {
      type = "recipe",
      name = "exo-skeleton",
      enabled = "false",
      ingredients = {
        {'endo-skeleton', 1},
        {'alien-fragments', 2}
      },
      result = "exo-skeleton"
  },

  {
    type = "tool",
    name = "exo-skeleton",
    icon = "__AlienWall__/graphics/icons/biomass/exo-skeleton.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "materials",
    order = "a[exo-skeleton]-c",
    stack_size = 50,
	durability = 1,
  },
]]--
})