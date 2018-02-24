data:extend({
  {
    type = "technology",
    name= "crafting-speed-upgrade-1",
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "3",
    order = "c-k-f-a"
  },
  {
    type = "technology",
    name= "crafting-speed-upgrade-4",
    prerequisites = {"crafting-speed-upgrade-1"},
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "7",
    order = "c-k-f-a"
  },
  {
    type = "technology",
    name= "crafting-speed-upgrade-8",
    prerequisites = {"crafting-speed-upgrade-4"},
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "11",
    order = "c-k-f-a"
  },
  {
    type = "technology",
    name= "crafting-speed-upgrade-12",
    prerequisites = {"crafting-speed-upgrade-8"},
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "15",
    order = "c-k-f-a"
  },
  {
    type = "technology",
    name= "crafting-speed-upgrade-16",
    prerequisites = {"crafting-speed-upgrade-12"},
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "19",
    order = "c-k-f-a"
  },
  {
    type = "technology",
    name= "crafting-speed-upgrade-20",
    prerequisites = {"crafting-speed-upgrade-16"},
    icon = "__Crafting_Speed_Research__/crafting-speed-research.png",
    icon_size = 64,
    effects =
    {
      {
        type = "character-crafting-speed",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "50*(L^1.2)",
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    max_level = "infinite",
    order = "c-k-f-a"
  },
})

data.raw["utility-sprites"].default.character_crafting_speed_modifier_icon = {
  filename = "__Crafting_Speed_Research__/crafting-speed-research.png",
  priority = "medium",
  width = 64,
  height = 64,
  flags = {"icon"}
}
