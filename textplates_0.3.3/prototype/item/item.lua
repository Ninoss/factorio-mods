local count = 0
for _, material in ipairs(textplates.materials) do
    for _, size in ipairs(textplates.sizes) do
        for _, symbol in ipairs(textplates.symbols) do
            count = count + 1
            local item = {
                type = "item",
                name = "textplate-" .. size .. "-" .. material .. "-" .. symbol,
                icon = "__textplates__/graphics/icon/"..size.."/"..material.."_"..symbol..".png",
                icon_size = 32,
                flags = {"goes-to-quickbar", "hidden"},
                subgroup = "terrain",
                order = "e[tileplates]-"..string.format( "%03d", count ),
                stack_size = 100,
                place_result = "textplate-"..size.."-"..material,
                localised_name = { "item-name.textplate", { "textplates."..size }, {"textplates.".. material } }
            }
            if symbol == "blank" then
                item.name = "textplate-" .. size .. "-" .. material
            end
            data:extend({ item })

            if textplates_legacy then
                item = {
                    type = "item",
                    name = size .. "-" .. material .. "-" .. symbol,
                    icon = "__textplates__/graphics/icon/"..size.."/"..material.."_"..symbol..".png",
                    icon_size = 32,
                    flags = {"goes-to-quickbar", "hidden"},
                    subgroup = "terrain",
                    order = "e[tileplates]-"..string.format( "%03d", count ).."-legacy",
                    stack_size = 100,
                    place_result = size.."-"..material.."-"..symbol,
                    localised_name = { "item-name.textplate-legacy", { "textplates."..size }, {"textplates.".. material }, { "textplates."..symbol } }
                }
                data:extend({ item })
            end
        end
    end
end
