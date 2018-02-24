data:extend(
{
  {
    type = "technology",
    name = "electric-energy-accumulators-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/electric-energy-acumulators.png",
localised_name = {"technology-name.electric-energy-accumulators-3"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "elite-accumulator"
      }
    },
    prerequisites = {"electric-energy-accumulators-2"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1}
      },
      time = 60
    },
    order = "c-e-c",
  }
}
)
