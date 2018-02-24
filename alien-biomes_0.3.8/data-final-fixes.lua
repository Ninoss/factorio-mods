local data_util = require('data-util')
local fallback_tile = "landfill"

-- now that terrains can be larger spread out resources
for _, resource in pairs(data.raw.resource) do
  if resource.coverage then
    resource.coverage = resource.coverage / 2
  end
  if resource.richness_multiplier_distance_bonus then
    resource.richness_multiplier_distance_bonus = 1 + (resource.richness_multiplier_distance_bonus - 1) / 2
  end
end

-- it may be tempting to completely remove all vegetation entities from the game for this
-- but that would be bad becuase it would affect existing chunks and break mods
if settings.startup["alien-biomes-disable-vegetation"].value then
  for _, prototype in pairs(data.raw['tree']) do
    prototype.autoplace = nil
  end
  for _, prototype in pairs(data.raw['tile']) do
    if string.find(prototype.name, "grass") then
      prototype.autoplace = nil
    end
  end
  for _, prototype in pairs(data.raw['tile']) do
    if string.find(prototype.name, "grass") then
      prototype.autoplace = nil
    end
  end
  local block_decorative_words = {"grass", "asterisk", "fluff", "garballo", "bush", "croton", "pita", "cane"}
  for _, prototype in pairs(data.raw['optimized-decorative']) do
    for _, word in pairs(block_decorative_words) do
      if string.find(prototype.name, word) then
        prototype.autoplace = nil
      end
    end
  end
  data.raw['fish']['fish'].autoplace = nil
end

-- landfill
local landfill = table.deepcopy(data.raw.tile["mineral-grey-dirt-4"])
landfill.name = "landfill"
landfill.autoplace = nil
landfill.ageing = 0
landfill.localised_name = nil
data:extend({
  landfill
})

data.raw.item.landfill.place_as_tile.result = "landfill"
data.raw.item.landfill.icon = "__alien-biomes__/graphics/icon/landfill.png"


for _, tile in pairs(data.raw.tile) do
  if tile.name == "water" or tile.name == "deepwater" then
    tile.ageing = 0.0002
  elseif tile.ageing ~= 0.0001 then
    tile.ageing = 0
  end
end

local function swap_tile_restriction(prototypes, old_name, new_name)
  for _, prototype in pairs(prototypes) do
    if prototype.autoplace and prototype.autoplace.tile_restriction then
      for _, restriction in pairs(prototype.autoplace.tile_restriction) do
        if restriction == old_name then
            prototype.autoplace.tile_restriction[_] = new_name
        end
      end
    end
  end
end


local function swap_tile_restrictions(old_name, new_name)

  -- decoratives on tiles
  swap_tile_restriction(data.raw["optimized-decorative"], old_name, new_name)

  -- simple-entities on tiles
  swap_tile_restriction(data.raw["simple-entity"], old_name, new_name)

  -- trees on tiles
  swap_tile_restriction(data.raw["tree"], old_name, new_name)

end

local function remove_from_transitions(remove_tile)
  for _, tile in pairs(data.raw.tile) do
    if tile.transitions then
      for _, transition in pairs(tile.transitions) do
        if transition.to_tiles then
          for _, to_tile in pairs(transition.to_tiles) do
            if to_tile == remove_tile then
              transition.to_tiles[_] = nil
            end
          end
        end
      end
    end
  end
end

local function remove_tile(tile_name)
  data.raw.tile[tile_name] = nil
  remove_from_transitions(tile_name)
  swap_tile_restrictions(tile_name, nil)
end

local function replace_tile_with_tile(old_name, new_name)

  -- items that place tiles
  for _, prototype in pairs(data.raw["item"]) do
    if prototype.place_as_tile and prototype.place_as_tile.result == old_name then
        prototype.place_as_tile.result = new_name
    end
  end

  remove_from_transitions(old_name)

  swap_tile_restrictions(old_name, new_name)

end

-- make things use the alien biomes tile if possible.
for old_name, new_name in pairs(alien_biomes.tile_alias) do
  replace_tile_with_tile(old_name, new_name)
end




local disable_unused_tiles = function()
  for old_name, new_name in pairs(alien_biomes.tile_alias) do
    -- grass 1 is often used by other mods as a template so keep it
    if old_name ~= "grass-1" then
      remove_tile(old_name)
    end
  end
  remove_tile("water-green")
  remove_tile("deepwater-green")
end

if settings.startup["alien-biomes-remove-obsolete-tiles"].value then
  disable_unused_tiles()
end


local function count_tiles()
  local tile_count = 0
  for _, tile in pairs(data.raw.tile) do
    tile_count = tile_count + 1
  end
  return tile_count
end

-- if there are more than 255 tiles the game will not load.
-- remove tiles over the 255 limit so people can at least get to the menu and change settings
-- plaecable tiles (floors) are less important than terrain, becuase you can fix floors later
-- but if terrain is messed up your save is broken!
local function force_game_load()
  local tile_count = count_tiles()

  if tile_count > 255 then
    log( "More than 255 tiles are defined, the game will not load unless some are removed." )
    local sorted_tiles = {} -- vanilla critical
    sorted_tiles[1] = {} -- vanilla critical
    sorted_tiles[2] = {} -- AB critical
    sorted_tiles[3] = {} -- alien_biomes_priority_tiles (priority modded tiles)
    sorted_tiles[4] = {} -- others
    local priority_tiles = {
      "out-of-map", "deepwater", "deepwater-green", "water", "water-green", "grass-1",
      "stone-path", "lab-dark-1", "lab-dark-2", "lab-white", "concrete", "hazard-concrete-left", "hazard-concrete-right",
      "landfill", "building-platform",
      "space", "air-1", "air-2", "air-3", "air-4",
      "space-platform-underlay", "space-platform-underlay-l", "space-platform-underlay-r", "space-platform-scaffold", "space-platform-plating"

    }
    for _, tile in pairs(data.raw.tile) do

      local priority = nil

      -- check priority 1
      for _, name in pairs(priority_tiles) do
        if tile.name == name then
          priority = 1 break
        end
      end

        -- check priority 2
      if not priority then
        for _, name in pairs(alien_biomes.list_tiles(alien_biomes.all_tiles())) do
          if tile.name == name then
            priority = 1 break
          end
        end
      end

      -- check priority 3 from alien_biomes_priority_tiles (other mods can push names)
      alien_biomes_priority_tiles = alien_biomes_priority_tiles or {}
      if not priority then
        for _, name in pairs(alien_biomes_priority_tiles) do
          if tile.name == name then
            priority = 3 break
          end
        end
      end

      if not priority then priority = 4 end

      data.raw.tile[tile.name] = nil
      table.insert(sorted_tiles[priority], tile)
    end

    local tile_count2 = 0
    -- all tiles are removed, put back in by priority
    for _, tile in pairs(sorted_tiles[1]) do
      log( "Tile "..tile_count2.." included: ".. tile.name)
      tile_count2 = tile_count2 + 1
      data.raw.tile[tile.name] = tile
    end
    for _, tile in pairs(sorted_tiles[2]) do
      log( "Tile "..tile_count2.." included: ".. tile.name)
      tile_count2 = tile_count2 + 1
      data.raw.tile[tile.name] = tile
    end

    for _, tile in pairs(sorted_tiles[3]) do
      tile_count2 = tile_count2 + 1
      if tile_count2 <= 255 then
        log( "Tile "..tile_count2.." included: ".. tile.name)
        -- add the tile back in
        data.raw.tile[tile.name] = tile
      else
        log( "Tile "..tile_count2.." excluded: ".. tile.name)
        replace_tile_with_tile(tile.name, fallback_tile)
      end
    end

    for _, tile in pairs(sorted_tiles[4]) do
      tile_count2 = tile_count2 + 1
      if tile_count2 <= 255 then
        log( "Tile "..tile_count2.." included: ".. tile.name)
        -- add the tile back in
        data.raw.tile[tile.name] = tile
      else
        log( "Tile "..tile_count2.." excluded: ".. tile.name)
        replace_tile_with_tile(tile.name, fallback_tile)
      end
    end

  end

end
force_game_load()

local function set_decals_to_layer(decal_layer)
  log("Setting decals to layer " .. decal_layer)
  for _, decal in pairs(data.raw['optimized-decorative']) do
    if decal.tile_layer == default_decal_layer then
      decal.tile_layer = decal_layer
    end
  end
end

-- there are lots of terrain layers now
-- most constructed tiles / flooring do not expect that and have a layer that is too low
-- sort the layers
local function sort_tile_layers()
  local ab_by_name = {}
  for _, name in pairs(alien_biomes.list_tiles(alien_biomes.all_tiles())) do
    ab_by_name[name] = name
  end
  local exclusions = {"water","deepwater","water-green","deepwater-green", "landfill"}
  local ab_layers = {}
  local other_layers = {}
  for _, tile in pairs(data.raw.tile) do
    local exclude = false
    for _, name in pairs(exclusions) do
      if name == tile.name then exclude = true end
    end
    if not exclude then
      local layer = tile.layer or 1
      if ab_by_name[tile.name] then
        ab_layers[layer] = ab_layers[layer] or {}
        table.insert(ab_layers[layer], tile)
      else
        other_layers[layer] = other_layers[layer] or {}
        table.insert(other_layers[layer], tile)
      end
    end
  end

  -- water
  data.raw.tile["water"].layer = 1
  data.raw.tile["deepwater"].layer = 2
  if data.raw.tile["water-green"] then data.raw.tile["water-green"].layer = 1 end
  if data.raw.tile["deepwater-green"] then data.raw.tile["deepwater-green"].layer = 2 end

  -- then terrain
  local next_layer = 3
  for _, layer_group in pairs(ab_layers) do
      for _, tile in pairs(layer_group) do
          tile.layer = next_layer
          next_layer = next_layer + 1
      end
  end

  -- then landfill
  data.raw.tile["landfill"].layer = next_layer
  next_layer = next_layer + 1

  local decal_layer = next_layer -1

  -- then floors
  for _, layer_group in pairs(other_layers) do
      for _, tile in pairs(layer_group) do
          tile.layer = next_layer
          next_layer = next_layer + 1
      end
  end

  -- set decals to final terrain layer
  set_decals_to_layer(decal_layer)
end
sort_tile_layers()

local function log_tiles()
  log("logging tile layers")
  local log_data = {}
  for _, tile in pairs(data.raw.tile) do
    log_data["layer " .. tile.layer] = tile.name
  end
  log( serpent.block( log_data, {comment = false, numformat = '%1.8g' } ) )
end
log_tiles()


--log( serpent.block( alien_biomes.all_tiles(), {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['puberty-decal'], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['light-mud-decal'], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['stone-decal-tan'], {comment = false, numformat = '%1.8g' } ) )
