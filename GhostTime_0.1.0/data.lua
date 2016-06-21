data:extend(
{
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
        modifier = 60 * 60 * 5--10mins total
      }
    },
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
    name = "ghost-time-2",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 5--15mins total
      }
    },
    prerequisites = {"ghost-time"},
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
    name = "ghost-time-3",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 5--20mins total
      }
    },
    prerequisites = {"ghost-time-2"},
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
  },
  {
    type = "technology",
    name = "ghost-time-4",
    icon = "__GhostTime__/graphics/GhostTime.png",
    effects =
    {
      {
        type = "ghost-time-to-live",
        modifier = 60 * 60 * 10--30mins total
      }
    },
    prerequisites = {"ghost-time-3"},
    unit =
    {
      count = 600,
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 4}
      },
      time = 120
    },
    upgrade = true,
    order = "c-k-a",
  }
})
