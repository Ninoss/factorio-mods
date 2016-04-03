require "config"

data:extend({
  {
    type = "container",
    name = "gravestone",
    icon = "__gravestone-mod__/graphics/gravestone.png",
    flags = {"placeable-neutral"},
    minable = {mining_time = 1},
    max_health = 120,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.55 },
    close_sound = { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.6 },
    resistances = {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.45}, {0.5, 0.5}},

    inventory_size = 200,
    vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.65 },
    picture = {
      filename = "__gravestone-mod__/graphics/gravestone.png",
      priority = "high",
      width = 96,
      height = 34,
      shift = {0.3, 0.2}
    },
    order = "a[items]-d[gravestone]"
  }
})
