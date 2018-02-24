data:extend(
{
  {
    type = "technology",
    name = "electric-energy-accumulators-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/electric-energy-acumulators.png",
localised_name = {"technology-name.electric-energy-accumulators-2"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-accumulator"
      }
    },
    prerequisites = {"electric-energy-accumulators-1"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1}
      },
      time = 45
    },
    order = "c-e-b",
  }
}
)
