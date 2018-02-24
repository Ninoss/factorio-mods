require "config"

data:extend(
{
    {
        type = "item",
        name = "Arci-asphalt",
        icon = "__AsphaltRoads__/graphics/icons/asphalt.png",
        icon_size = 32,
        flags = {"goes-to-main-inventory"},
        subgroup = "Arci-asphalt-1",
        order = "a",
        stack_size = asphalt_stack_size,
        place_as_tile =
        {
            result = "Arci-asphalt",
            condition_size = 1,
            condition = { "water-tile" }
        }
    }
}
)  
	
	
	


