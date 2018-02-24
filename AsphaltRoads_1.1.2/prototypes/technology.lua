local easy_research = settings.startup["AR-easy-research"].value

data:extend(
{
    {
        type = "technology",
        name = "Arci-asphalt",
        icon = "__AsphaltRoads__/graphics/technology/tech-asphalt.png",
        icon_size = 128,
        prerequisites = {"concrete"},
        unit =
        {
            count = easy_research and 250 or 300,
            ingredients = easy_research and
            {
                {"science-pack-1", 1},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            } or {
                {"science-pack-1", 1},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
                {"production-science-pack", 1}
            },
        time = 45
        },
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "Arci-asphalt"
            }
        },
        order = "c-c-d"	
    } 
}
)	

	  
	  