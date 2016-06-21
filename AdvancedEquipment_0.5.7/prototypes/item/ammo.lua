data:extend(
{
  
  {
    type = "ammo-category",
    name = "minigun-bullet"
  },
    {
    type = "ammo-category",
    name = "minigun-energy-bullet"
  },
  
  
 {
    type = "ammo",
    name = "minigun-bullet-magazine",
    icon = "__AdvancedEquipment__/graphics/icons/minigun-bullet-magazine.png",
    flags = {"goes-to-main-inventory"},
    ammo_type =
    {
      category = "minigun-bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
              type = "create-explosion",
              entity_name = "explosion-gunshot"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 20 , type = "physical"}
            }
          }
        }
      }
    },
    magazine_size = 600,
    subgroup = "ammo",
    order = "a[basic-clips]-c[minigun-bullet-magazine]",
    stack_size = 10
  },
 {
    type = "ammo",
    name = "minigun-piercing-bullet-magazine",
    icon = "__AdvancedEquipment__/graphics/icons/minigun-piercing-bullet-magazine.png",
    flags = {"goes-to-main-inventory"},
    ammo_type =
    {
      category = "minigun-bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
              type = "create-explosion",
              entity_name = "explosion-gunshot"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 40 , type = "physical"}
            }
          }
        }
      }
    },
    magazine_size = 600,
    subgroup = "ammo",
    order = "a[basic-clips]-d[minigun-piercing-bullet-magazine]",
    stack_size = 10
  },
   {
    type = "ammo",
    name = "minigun-uranium-bullet-magazine",
    icon = "__AdvancedEquipment__/graphics/icons/minigun-uranium-bullet-magazine.png",
    flags = {"goes-to-main-inventory"},
    ammo_type =
    {
      category = "minigun-bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
              type = "create-explosion",
              entity_name = "explosion-gunshot"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 80 , type = "physical"}
            }
          }
        }
      }
    },
    magazine_size = 600,
    subgroup = "ammo",
    order = "a[basic-clips]-e[minigun-piercing-bullet-magazine]",
    stack_size = 10
  },
  
  
      {
    type = "ammo",
    name = "li-ion-battery",
    icon = "__AdvancedEquipment__/graphics/icons/li-ion-battery.png",
    flags = {"goes-to-main-inventory"},
    ammo_type =
    {
      type = "projectile",
	  category = "minigun-energy-bullet",
      action =
      {
          type = "direct",
          --repeat_count = 12,
          action_delivery =
          {
            type = "projectile",
            projectile = "blue-laser",
            starting_speed = 1,
            direction_deviation = 0.3,
            range_deviation = 0.3,
            max_range = 35,
			target_effects =
				{
				type = "damage",
				projectile = "blue-laser",
				damage = { amount = 100, type="laser"}
				}
			
          }
      }
    },
    magazine_size = 500,
    subgroup = "ammo",
    order = "a[basic-clips]-f[minigun-piercing-bullet-magazine]",
    stack_size = 10
  },
  
 
  --[[
        {
    type = "ammo",
    name = "li-ion-battery",
    icon = "__AdvancedEquipment__/graphics/icons/li-ion-battery.png",
    flags = {"goes-to-main-inventory"},
    ammo_type =
    {
      type = "projectile",
	  category = "minigun-energy-bullet",
      action =
      {
        type = "direct",
		action_delivery =
			{
			type="projectile",
			projectile = "blue-laser",
			starting_speed = 1,
			target_effects =
				{
				type = "damage",
				projectile = "blue-laser",
				damage = { amount = 100, type="laser"}
				}
			}
      }
    },
    magazine_size = 500,
    subgroup = "ammo",
    order = "a[basic-clips]-d[minigun-piercing-bullet-magazine]",
    stack_size = 100
  },
  
  --]]
  
  
  
  
  
  

}
)