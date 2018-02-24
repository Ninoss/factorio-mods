data:extend({
    {
        type = "technology",
        name = "beltplanner",
        order = "c-k-b-a",
        icon = "__beltplanner__/graphics/technology/beltplanner.png",
        icon_size = 128,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "beltplanner"
            },
        },
        prerequisites =
        {
            "logistics",
        },
        unit =
        {
            count = 100,
            ingredients =
            {
                {"science-pack-1", 1},
                {"science-pack-2", 1},
            },
            time = 30,
        },
    },
})
