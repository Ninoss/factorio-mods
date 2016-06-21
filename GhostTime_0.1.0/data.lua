data:extend(
{
--[-----------------------------------------------------------------------------------]
--DELETE FROM HERE UP TO ADDEDRESEARCH TO JUST GET AN ADDED VALUE ONTOP OF THE DEFAULTS
--[-----------------------------------------------------------------------------------]
  {
    type = "technology",
    name = "automated-construction",
    icon = "__base__/graphics/technology/automated-construction.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "blueprint"
      },
      {
        type = "unlock-recipe",
        recipe = "deconstruction-planner"
      },
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 1--change from default +5 mins to +1 min
      }
    },
    prerequisites = {"construction-robotics"},
    unit =
    {
      count = 75,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 30
    },
    order = "c-k-b",
  },
  {
    type = "technology",
    name = "construction-robotics",
    icon = "__base__/graphics/technology/construction-robotics.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "roboport"
      },
      {
        type = "unlock-recipe",
        recipe = "logistic-chest-passive-provider"
      },
      {
        type = "unlock-recipe",
        recipe = "logistic-chest-storage"
      },
      {
        type = "unlock-recipe",
        recipe = "construction-robot"
      },
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 1--change from default 5 mins to 1 min
      }
    },
    prerequisites = {"robotics", "flying"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 30
    },
    order = "c-k-a",
  },
  
  
  
  
  
  
  
--[------------]
--ADDED RESEARCH
--[------------]
  {
    type = "technology",
    name = "ghost-time",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 3--5mins total
      }
    },
    prerequisites = {"automated-construction"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-a",
  },
  {
    type = "technology",
    name = "ghost-time-2",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 5--10mins total
      }
    },
    prerequisites = {"ghost-time"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-a",
  },
  {
    type = "technology",
    name = "ghost-time-3",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 5--15mins total
      }
    },
    prerequisites = {"ghost-time-2"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 1}
      },
      time = 60
    },
    upgrade = true,
    order = "c-k-a",
  },
  {
    type = "technology",
    name = "ghost-time-4",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 5--20mins total
      }
    },
    prerequisites = {"ghost-time-3"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 4}
      },
      time = 90
    },
    upgrade = true,
    order = "c-k-a",
  }
})