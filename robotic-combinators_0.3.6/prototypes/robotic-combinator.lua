data:extend( {
  {
    type = "item",
    name = "robotic-network-combinator",
    icon = "__robotic-combinators__/graphics/icon-robotic-combinator.png",
    flags = {"goes-to-quickbar"},
    subgroup = "circuit-network",
    place_result="robotic-network-combinator",
    order = "b[combinators]-e[robotic-network-combinator]",
    stack_size = 50,
  },
  {
    type = "recipe",
    name = "robotic-network-combinator",
    enabled = "false",
    ingredients =
    {
      {"constant-combinator", 1},
      {"iron-plate",2},
      {"advanced-circuit", 1},
    },
    result="robotic-network-combinator",
  },
  {
    type = "constant-combinator",
    name = "robotic-network-combinator",
    icon = "__robotic-combinators__/graphics/robotic-combinator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "robotic-network-combinator"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 10,

    sprite =
    {
      filename = "__robotic-combinators__/graphics/robotic-combinator.png",
      width = 53,
      height = 44,
      shift = {0.2, 0},
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.125625, 0.418125},
        green = {0.668125, 0.418125},
      },
      wire =
      {
        red = {-0.244375, 0.020625},
        green = {0.248125, 0.020625},
      }
    },
    circuit_wire_max_distance = 7.5
  },


})

table.insert(data.raw["technology"]["logistic-robotics"].effects,{type="unlock-recipe",recipe="robotic-network-combinator"})
table.insert(data.raw["technology"]["construction-robotics"].effects,{type="unlock-recipe",recipe="robotic-network-combinator"})