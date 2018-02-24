function beltplanner_arrow(direction, ground)
    return {
        type = "simple-entity",
        name = "beltplanner-arrow-"..(ground and "ground-" or "")..direction,
        collision_box = {{-.45, -.45}, {.45, .45}},
        collision_mask = {"object-layer", "water-tile", "ghost-layer"},
        selection_box = {{-.5, -.5}, {.5, .5}},
        pictures =
        {
            {
                filename = "__core__/graphics/arrows/hint-orange-arrow-"..direction..".png",
                width = ({down=71, left=43, right=38, up=62})[direction], --nothing can ever be easy...
                height = ({down=35, left=73, right=73, up=37})[direction],
                tint = ground and {r=1.0, g=0.0, b=0.0, a=1.0},
                scale = .5,
            },
        },
        render_layer = "floor",
        minable =
        {
            mining_time = 1,
            hardness = .5,
        },
        flags = {"not-blueprintable", "not-deconstructable"},
    }
end

data:extend({
    {
        type = "simple-entity",
        name = "beltplanner",
        collision_box = {{-.45, -.45}, {.45, .45}},
        collision_mask = {"object-layer", "water-tile", "ghost-layer"},
        selection_box = {{-.5, -.5}, {.5, .5}},
        pictures =
        {
            {
                filename = "__beltplanner__/graphics/entity/beltplanner.png",
                width = 95,
                height = 58,
                shift = {0.775, -0.3},
                scale = .9,
                hr_version = {
                    filename = "__beltplanner__/graphics/entity/hr-beltplanner.png",
                    width = 188,
                    height = 111,
                    shift = {0.775, -0.3},
                    scale = .45,
                },
            },
        },
        render_layer = "object",
        minable =
        {
            mining_time = 1,
            hardness = .5,
        },
        flags = {"not-blueprintable", "not-deconstructable"},
    },
    {
        type = "simple-entity",
        name = "beltplanner-resourcefinder",
        collision_box = {{-.45, -.45}, {.45, .45}},
        collision_mask = {"object-layer", "water-tile", "ghost-layer", "resource-layer"},
        pictures =
        {
            filename = "__beltplanner__/graphics/entity/beltplanner.png",
            width = 0,
            height = 0,
        },
    },
    --[[DEBUG_MARKER
    {
        type = "simple-entity",
        name = "beltplanner-debug-open",
        collision_box = {{-.45, -.45}, {.45, .45}},
        collision_mask = {},
        selection_box = {{-.5, -.5}, {.5, .5}},
        pictures =
        {
            {
                filename = "__beltplanner__/graphics/beltplanner-debug-open.png",
                width = 32,
                height = 32,
            },
        },
        render_layer = "decorative",
        flags = {"not-blueprintable", "not-deconstructable"},
    },
    {
        type = "simple-entity",
        name = "beltplanner-debug-closed",
        collision_box = {{-.45, -.45}, {.45, .45}},
        collision_mask = {},
        selection_box = {{-.5, -.5}, {.5, .5}},
        pictures =
        {
            {
                filename = "__beltplanner__/graphics/beltplanner-debug-closed.png",
                width = 32,
                height = 32,
            },
        },
        render_layer = "decorative",
        flags = {"not-blueprintable", "not-deconstructable"},
    },
    --]]
    beltplanner_arrow("down"),
    beltplanner_arrow("left"),
    beltplanner_arrow("right"),
    beltplanner_arrow("up"),
    beltplanner_arrow("down", true),
    beltplanner_arrow("left", true),
    beltplanner_arrow("right", true),
    beltplanner_arrow("up", true),
})
