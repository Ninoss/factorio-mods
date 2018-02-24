data:extend(
{
  {
    type = "technology",
    name = "solar-energy-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/solar-energy.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "elite-solar"
      }
    },
    prerequisites = {"solar-energy-2"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1}
      },
      time = 60
    },
    order = "a-h-c",
  }
}
)
