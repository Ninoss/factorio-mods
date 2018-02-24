data:extend({
    {
        type = "recipe",
        name = "beltplanner",
        subgroup = "tool",
        order = "c[automated-construction]-c[beltplanner]",
        enabled = false,
        energy_required = 1,
        ingredients =
        {
            {"electronic-circuit", 1},
            {"iron-gear-wheel", 1},
            {"copper-cable", 2},
        },
        result = "beltplanner"
    },
})
