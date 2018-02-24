for _, material in ipairs(textplates.materials) do
    for _, size in ipairs(textplates.sizes) do
        local recipe = {
            type = "recipe",
            name = "textplate-" .. size .. "-" .. material,
            icon = "__textplates__/graphics/icon/" .. size .. "/" .. material .. "_blank.png",
            icon_size = 32,
            category = "crafting",
            enabled = true,
            energy_required = 0.5,
            ingredients = {{type = "item", name = material .. "-plate", amount = 1}},
            results= {{type = "item", name = "textplate-" .. size .. "-" .. material, amount = 1}},
        }
        if size == "large"  then
            recipe.ingredients[1].amount = 4
            recipe.energy_required = 1
        end
        data:extend({recipe})
    end
end
