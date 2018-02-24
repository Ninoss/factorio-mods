data:extend(
{
  {
    type = "technology",
    name = "solar-energy-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/solar-energy.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-solar"
      }
    },
    prerequisites = {"solar-energy"},
    unit =
    {
      count = 350,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1}
      },
      time = 45
    },
    order = "a-h-c",
  }
}
)
