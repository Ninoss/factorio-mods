data:extend(
{  
--[[	
  {
    type = "explosion",
    name = "explosion_green",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/explosion/explosion-1g.png",
        priority = "extra-high",
        width = 64,
        height = 59,
        frame_count = 16
      },
      {
        filename = "__AdvancedEquipment__/graphics/entity/explosion/explosion-2g.png",
        priority = "extra-high",
        width = 64,
        height = 57,
        frame_count = 16
      },
      {
        filename = "__AdvancedEquipment__/graphics/entity/explosion/explosion-3g.png",
        priority = "extra-high",
        width = 64,
        height = 49,
        frame_count = 16
      },
      {
        filename = "__AdvancedEquipment__/graphics/entity/explosion/explosion-4g.png",
        priority = "extra-high",
        width = 64,
        height = 51,
        frame_count = 16
      }
    },
    light = {intensity = 1, size = 20},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/explosion1.wav",
        volume = 0.8
      },
      {
        filename = "__base__/sound/explosion2.wav",
        volume = 0.8
      }
    }
  },      

  {
    type = "explosion",
    name = "heal-effect",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/healxsmall.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 20
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/explosion1.wav",
        volume = 0.8
      },
      {
        filename = "__base__/sound/explosion2.wav",
        volume = 0.8
      }
    }
  },

  {
    type = "explosion",
    name = "heal-effect_start",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/healstartsmall.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 7
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/explosion1.wav",
        volume = 0.8
      },
      {
        filename = "__base__/sound/explosion2.wav",
        volume = 0.8
      }
    }
  },
  {
    type = "explosion",
    name = "heal-effect_mid",
	flags = {"placeable-off-grid"},
    animation_speed = 0.1,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/healmidallsmallsrnk.png",
        priority = "extra-high",
        width = 48,
        height = 96,
        frame_count = 10
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/explosion1.wav",
        volume = 0.8
      },
      {
        filename = "__base__/sound/explosion2.wav",
        volume = 0.8
      }
    }
  },
  {
    type = "explosion",
    name = "heal-effect_end",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/healendsmall.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 8
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/explosion1.wav",
        volume = 0.8
      },
      {
        filename = "__base__/sound/explosion2.wav",
        volume = 0.8
      }
    }
  },





--]]


--[[ Nowy type explosion w 0.11.x
  {
    type = "explosion",
    name = "laser-bubble",
    flags = {"not-on-map"},
    animation_speed = 1,
    animations =
    {
      {
        filename = "__base__/graphics/entity/laser-bubble/laser-bubble.png",
        priority = "extra-high",
        width = 8,
        height = 8,
        frame_count = 5
      }
    },
    light = {intensity = 1, size = 10},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1
  },]]--

--[[

  {
    type = "explosion",
    name = "heal-effect-1",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/1.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-2",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/2.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-3",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/3.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-4",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/4.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-5",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/5.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-6",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/6.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-7",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/7.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-8",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/8.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-9",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/9.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-10",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/10.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-11",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/11.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-12",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/12.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-13",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/13.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-14",
	flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/14.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-15",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/15.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-16",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/16.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-17",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/17.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-18",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/18.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-19",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/19.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },
  {
    type = "explosion",
    name = "heal-effect-20",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/heal/20.png",
        priority = "extra-high",
        width = 96,
        height = 96,
        frame_count = 2
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  },

  --]]
  
--[[
  {
    type = "explosion",
    name = "cros",
    flags = {"placeable-off-grid"},
    animation_speed = 2,
    animations =
    {
      {
        filename = "__AdvancedEquipment__/graphics/entity/cros.png",
        priority = "extra-high",
        width = 64,
        height = 64,
        frame_count = 1
      }
    },
    light = {intensity = 0, size = 0},
    smoke = "smoke-fast",
    smoke_count = 0,
    smoke_slow_down_factor = 1,

  }
--]]

}
)
