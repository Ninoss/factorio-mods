require "config"
local tile_transitions = require("util/tile-transitions")

path = "__AsphaltRoads__/graphics/terrain/"
type1_tilesets = {"asphalt-zebra-crossing"}
type2_tilesets = {"asphalt-triangle-white"}
type3_tilesets = {"asphalt-hazard-white", "asphalt-hazard-yellow", "asphalt-hazard-red", "asphalt-hazard-blue", "asphalt-hazard-green"}
type4_tilesets = {"marking-white", "marking-white-dl"}
type5_tilesets = {"marking-yellow", "marking-yellow-dl"}
mining_sound = "__base__/sound/deconstruct-bricks.ogg"
mining_result = "Arci-asphalt"
mapcolours = {{"white", asphalt_colour_marking_white}, {"yellow", asphalt_colour_marking_yellow}, {"blue", asphalt_colour_marking_blue}, {"red", asphalt_colour_marking_red}, {"green", asphalt_colour_marking_green}}
walking_sounds = {
    {
        filename = "__base__/sound/walking/concrete-01.ogg",
        volume = 1.2
    },
    {
        filename = "__base__/sound/walking/concrete-02.ogg",
        volume = 1.2
    },
    {
        filename = "__base__/sound/walking/concrete-03.ogg",
        volume = 1.2
    },
    {
        filename = "__base__/sound/walking/concrete-04.ogg",
        volume = 1.2
}}

func = {}
gOrderIndex = {}
function func.default_value(suffix)
    if suffix == "o" then cnt = 1 else cnt = 8 end   
    return {picture = path.."asphalt/asphalt-"..suffix..".png", count = cnt}
end

function func.diagonal_value(tileset, dir)
    cnt = 8   
    return {picture = path..tileset.."/"..tileset..dir.."-inner-corner.png", count = cnt}
end

function func.setMainVariant(levels, cnt, path)
    temp = {}
    for i=1, levels do
        s = math.floor(2^(i-1))
        table.insert(temp, {
                        picture = path.."-"..s..".png",
                        count = cnt[i],
                        size = s,
                    })
        if i == 2 then
            temp[i]["probability"] = 0.3
        elseif i == 3 then
            temp[i]["probability"] = 0.8
        end
    end
    return temp
end

function func.assignMapColour(tileset)
    colours = mapcolours
    for i=1, #colours do
        if string.find(tileset, colours[i][1]) ~= nil then
            return colours[i][2]
        end
    end
    return asphalt_colour_marking_white
end

function func.assignOrderPosition(subgrp)
    if gOrderIndex[subgrp] == nil then
        gOrderIndex[subgrp] = 1
    else 
        gOrderIndex[subgrp] = gOrderIndex[subgrp] + 1
    end
    return string.char(gOrderIndex[subgrp] + 96) -- get the ASCII character from numeric index (e.g. 97 = "a") 
end

function func.createTileSetB(tileset, numDirections, dirNames, mainVariants, mainVariantsCnt, diagonalTile)
    thispath = path..tileset.."/"
    
    -- part 1: tile definition
    for k=1, numDirections do
        thisdir = dirNames[k]
        nextdir = dirNames[k+1-math.floor(k/numDirections)*k]
        ic = {} -- inner-corner parameter
        tilelayer = asphalt_base_layer
        if diagonalTile ~= nil and diagonalTile == true then 
            ic = func.diagonal_value(tileset, thisdir) 
            tilelayer = asphalt_priority_layer
        else 
            ic = func.default_value("inner-corner") 
        end
        data:extend({{            
            type = "tile",
            name = "Arci-"..tileset..thisdir,
            next_direction = "Arci-"..tileset..nextdir,
            needs_correction = false,
            transition_merges_with_tile = "Arci-asphalt",
            minable = {hardness = 0.2, mining_time = 0.5, result = mining_result},
            mined_sound = { filename = mining_sound },
            collision_mask = {"ground-tile"},
            walking_speed_modifier = asphalt_walking_speed_modifier,
            layer = tilelayer,
            shift_layer_if_asphald_roads_is_present = false,
            decorative_removal_probability = 0.97,
            variants =
            {
                main = func.setMainVariant(mainVariants, mainVariantsCnt, thispath..tileset..thisdir),
                inner_corner = ic,
                outer_corner = func.default_value("outer-corner"),
                side = func.default_value("side"),
                u_transition = func.default_value("u"),
                o_transition = func.default_value("o"),
            },
            walking_sound = walking_sounds,
            map_color = func.assignMapColour(tileset),
            ageing=0,
            vehicle_friction_modifier = asphalt_vehicle_speed_modifier,
            transitions = tile_transitions.asphalt_transitions(),
            transitions_between_transitions = tile_transitions.asphalt_transitions_between_transitions()
        }})
    end
end

function func.createIRTentries(tileset, defaultDir, subgrp)
    data:extend({
    -- part 1: recipe definition
    {
        type = "recipe",
        name = "Arci-"..tileset,
        energy_required = 0.25,
        enabled = false,
        category = "crafting",
        ingredients =
        {
            {"Arci-asphalt", 10}
        },
        result= "Arci-"..tileset,
        result_count = 10
    },
    -- part 2: item definition
    {
        type = "item",
        name = "Arci-"..tileset,
        icon = "__AsphaltRoads__/graphics/icons/"..tileset..".png",
        icon_size = 32,
        flags = {"goes-to-quickbar"},
        subgroup = subgrp,
        order = func.assignOrderPosition(subgrp),
        stack_size = asphalt_stack_size,
        place_as_tile =
        {
            result = "Arci-"..tileset..defaultDir,
            condition_size = 1,
            condition = { "water-tile" }
        }
    }	         
    })
    -- part 3: tech entry
    table.insert(data.raw["technology"]["Arci-asphalt"].effects, {type = "unlock-recipe", recipe = "Arci-"..tileset})
end

for i=1, #type1_tilesets do
    func.createTileSetB(type1_tilesets[i], 2, {"-horizontal","-vertical"}, 3, {16, 4, 4})
    func.createIRTentries(type1_tilesets[i], "-vertical", "Arci-asphalt-1")
end
for i=1, #type2_tilesets do
    func.createTileSetB(type2_tilesets[i], 4, {"-up","-right","-down","-left"}, 1, {8})
    func.createIRTentries(type2_tilesets[i], "-up", "Arci-asphalt-1")
end
for i=1, #type3_tilesets do
    func.createTileSetB(type3_tilesets[i], 2, {"-right","-left"}, 3, {16, 4, 4})
    func.createIRTentries(type3_tilesets[i], "-left", "Arci-asphalt-1")
end
for i=1, #type4_tilesets do
    func.createTileSetB(type4_tilesets[i], 2, {"-straight-horizontal","-straight-vertical"}, 1, {16})
    func.createIRTentries(type4_tilesets[i].."-straight", "-vertical", "Arci-asphalt-2")
    func.createTileSetB(type4_tilesets[i], 2, {"-diagonal-left","-diagonal-right"}, 1, {16}, true)
    func.createIRTentries(type4_tilesets[i].."-diagonal", "-right", "Arci-asphalt-2")    
    func.createTileSetB(type4_tilesets[i], 4, {"-right-turn-up","-right-turn-right","-right-turn-down","-right-turn-left"}, 1, {16})
    func.createIRTentries(type4_tilesets[i].."-right-turn", "-up", "Arci-asphalt-2")
    func.createTileSetB(type4_tilesets[i], 4, {"-left-turn-up","-left-turn-right","-left-turn-down","-left-turn-left"}, 1, {16})
    func.createIRTentries(type4_tilesets[i].."-left-turn", "-up", "Arci-asphalt-2")
end
for i=1, #type5_tilesets do
    func.createTileSetB(type5_tilesets[i], 2, {"-straight-horizontal","-straight-vertical"}, 1, {16})
    func.createIRTentries(type5_tilesets[i].."-straight", "-vertical", "Arci-asphalt-3")
    func.createTileSetB(type5_tilesets[i], 2, {"-diagonal-left","-diagonal-right"}, 1, {16}, true)
    func.createIRTentries(type5_tilesets[i].."-diagonal", "-right", "Arci-asphalt-3")    
    func.createTileSetB(type5_tilesets[i], 4, {"-right-turn-up","-right-turn-right","-right-turn-down","-right-turn-left"}, 1, {16})
    func.createIRTentries(type5_tilesets[i].."-right-turn", "-up", "Arci-asphalt-3")
    func.createTileSetB(type5_tilesets[i], 4, {"-left-turn-up","-left-turn-right","-left-turn-down","-left-turn-left"}, 1, {16})
    func.createIRTentries(type5_tilesets[i].."-left-turn", "-up", "Arci-asphalt-3")
end
