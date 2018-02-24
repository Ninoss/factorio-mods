-- note: planet temperature controls could be controlled by altering noise-expression parameters

local biomes = {}

local split_dimensions = false
local dimension_influence = nil
local noise_influence = 0.02 -- 0.05
local base_influence = nil

biomes.transitions = require("prototypes/tile/tile-transitions")
biomes.sounds = require("prototypes/tile/tile-sounds")
biomes.colors = require("prototypes/tile/tile-colors")
biomes.tile_alias = require("prototypes/tile/tile-alias")
biomes.axes = require("prototypes/biome/biome-axes")
biomes.spec = require("prototypes/biome/biome-spec")

biomes.tiles_all = {} -- populate with biomes

biomes.all_tiles = function()
  return table.deepcopy(biomes.tiles_all)
end

biomes.add_tag = function(tile, tag)
  tile.tags[tag] = tag
end

-- biomes.require_tag((biomes.require_tag(biomes.all_tiles(), {"dirt", "sand"}), {"aubergine", "purple", "violet", "mauve"})
-- require ONE of many tags
biomes.require_tag = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    valid = false
    for _, tag in pairs(tags) do
      if tile.tags[tag] then valid = true break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

-- require ALL of many tags
biomes.require_tags = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    valid = true
    for _, tag in pairs(tags) do
      if not tile.tags[tag] then valid = false break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

-- require NONE of many tags
biomes.exclude_tags = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    valid = true
    for _, tag in pairs(tags) do
      if tile.tags[tag] then valid = false break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

biomes.list_tiles = function(tiles)
  local list = {}
  for tile_key, tile in pairs(tiles) do
    table.insert(list, tile_key)
  end
  return list
end

-- control entity and decorative placement using 'allowed tiles'.
local function noise_layer_peak(noise_name, influence, scale)
  if not data.raw['noise-layer'][noise_name] then
    data:extend({{
      type = "noise-layer",
      name = noise_name
    }})
  end
  return {
    influence = noise_influence * influence,
    noise_layer = noise_name,
    noise_persistence = 0.65,
    octaves_difference = -6,
    noise_scale = 1 * (scale or 1)
  }
end

biomes.dimension_autoplace = function(dimension_peaks, axis, point_a, point_b)

  r_point_a = point_a
  r_point_b = point_b
  if biomes.axes[axis].reverse then
    r_point_a = 1 - point_a
    r_point_b = 1 - point_b
  end
  local point_l = math.min(r_point_a, r_point_b)
  local point_h = math.max(r_point_a, r_point_b)

  local dimension = biomes.axes[axis].dimension
  --if dimension == "aux" then return end
  local low = biomes.axes[axis].low
  local high = biomes.axes[axis].high
  local d_point_a = low + (high - low) * point_l
  local d_point_b = low + (high - low) * point_h

  local key = 1
  if split_dimensions then key = dimension end
  if not dimension_peaks[key] then dimension_peaks[key] = {} end
  local peak = dimension_peaks[key]
  peak[dimension .. "_optimal"] = (d_point_a + d_point_b) / 2
  peak[dimension .. "_range"] = math.abs(d_point_a - d_point_b) * 0.5
  --peak[dimension .. "_max_range"] = math.abs(d_point_a - d_point_b) * 0.55
  peak[dimension .. "_max_range"] = math.abs(d_point_a - d_point_b) + 1
  if dimension == "temperature" then
    peak[dimension .. "_max_range"] = math.abs(d_point_a - d_point_b) + 100
  end

  if dimension_influence then
    peak.influence = dimension_influence * (peak.influence or 1)
  end

end


biomes.collapse = function ()
  local collapsed = {}
  for group_name, group in pairs(biomes.spec) do
    if group.axes then
      for axis_name, axis in pairs(group.axes) do
        for variant_name, variant in pairs(group.variants) do
          if variant.limit_axes then
            local pass = false
            for _, allowed in pairs(variant.limit_axes) do
              if axis_name == allowed then pass = true end
            end
            if pass == false then break end
          end
          local dimension_peaks = {}
          for dimension_name, dimension in pairs(group.dimensions) do
            biomes.dimension_autoplace( dimension_peaks, dimension_name, dimension[1], dimension[2])
          end
          for dimension_name, dimension in pairs(axis.dimensions) do
            biomes.dimension_autoplace( dimension_peaks, dimension_name, dimension[1], dimension[2])
          end
          if variant.dimensions then
            for dimension_name, dimension in pairs(variant.dimensions) do
              biomes.dimension_autoplace( dimension_peaks, dimension_name, dimension[1], dimension[2])
            end
          end
          local biome = {peaks = table.deepcopy(variant.peaks or {})}
          for _, dimension_peak in pairs(dimension_peaks) do
            table.insert(biome.peaks, dimension_peak)
          end
          if base_influence then table.insert(biome.peaks, {influence = base_influence}) end
          biome.group = variant.group or group_name
          biome.axis = axis_name
          biome.variant = variant_name
          biome.transition = variant.transition
          biome.no_noise = variant.no_noise
          biome.tags = variant.tags or {}
          collapsed[group_name .. "-" .. axis_name .. "-" .. variant_name] = biome
        end
      end
    else
      for variant_name, variant in pairs(group.variants) do
        local dimension_peaks = {}
        for dimension_name, dimension in pairs(group.dimensions) do
          biomes.dimension_autoplace( dimension_peaks, dimension_name, dimension[1], dimension[2])
        end
        if variant.dimensions then
          for dimension_name, dimension in pairs(variant.dimensions) do
            biomes.dimension_autoplace( dimension_peaks, dimension_name, dimension[1], dimension[2])
          end
        end
        local biome = {peaks = table.deepcopy(variant.peaks or {})}
        for _, dimension_peak in pairs(dimension_peaks) do
          table.insert(biome.peaks, dimension_peak)
        end
        if base_influence then table.insert(biome.peaks, {influence = base_influence}) end
        biome.group = variant.group or group_name
        biome.variant = variant_name
        biome.transition = variant.transition
        biome.no_noise = variant.no_noise
        biome.tags = variant.tags or {}
        collapsed[group_name .. "-" .. variant_name] = biome
      end
    end
  end
  biomes.collapsed = collapsed
end

biomes.collapse()

function tile_variations_template(normal_res_picture, normal_res_transition, high_res_picture, high_res_transition, options)
  local use_hr = high_res_picture ~= nil
  local function main_variation(size_)
    local y_ = ((size_ == 1) and 0) or ((size_ == 2) and 64) or ((size_ == 4) and 160) or 320
    local ret = {
      picture = normal_res_picture,
      count = 16,
      size = size_,
      y = y_,
      line_length = (size_ == 8) and 8 or 16
    }
    if use_hr then
      ret.hr_version =
      {
        picture = high_res_picture,
        count = 16,
        size = size_,
        y = 2 * y_,
        line_length = (size_ == 8) and 8 or 16,
        scale = 0.5
      }
    end

    if options[size_] then
      for k, v in pairs(options[size_]) do
        ret[k] = v
        if high_res_picture then
          ret.hr_version[k] = v
        end
      end
    end

    return ret
  end

  local function make_transition_variation(x_, line_len_, cnt_)
    local ret = {
      picture = normal_res_transition,
      count = cnt_ or 8,
      line_length = line_len_ or 8,
      x = x_,
    }
    if use_hr then
      ret.hr_version=
      {
        picture = high_res_transition,
        count = cnt_ or 8,
        line_length = line_len_ or 8,
        x = 2 * x_,
        scale = 0.5,
      }
    end
    return ret
  end

  local main_ =
  {
    main_variation(1),
    main_variation(2),
    main_variation(4),
  }
  if (options.max_size == 8) then
    table.insert(main_, main_variation(8))
  end

  return
  {
    main = main_,
    inner_corner_mask = make_transition_variation(0),
    outer_corner_mask = make_transition_variation(288),
    side_mask         = make_transition_variation(576),
    u_transition_mask = make_transition_variation(864, 1, 1),
    o_transition_mask = make_transition_variation(1152, 2, 1),
  }
end

biomes.build_tiles = function ()
  for _, tile in pairs(data.raw.tile) do
    if _ ~= "water" and _ ~= "deepwater" then
      data.raw.tile[_].autoplace = nil
    end
  end
  local layer = 0
  for biome_name, biome in pairs(biomes.collapsed) do
    layer = layer + 1
    local control = biome.group
    if biome.axis then control = control .. "-" .. biome.axis end
    local autoplace = { control = control, peaks = table.deepcopy(biome.peaks)}
    local tile = {
      name = biome_name,
      tags = {}
    }
    for _, tag in pairs(biome.tags) do
      biomes.add_tag(tile, tag)
    end
    biomes.add_tag(tile, biome.group)
    if biome.axis then biomes.add_tag(tile, biome.axis) end
    biomes.add_tag(tile, biome.variant)
    biomes.tiles_all[biome_name] = tile
    if not biome.no_noise then
      if noise_influence then table.insert(autoplace.peaks, noise_layer_peak(biome_name, 1)) end
      data:extend({
        {
          type = "noise-layer",
          name = biome_name
        }
      })
    end
    if control and not data.raw['autoplace-control'][control] then
      data:extend({
        {
          type = "autoplace-control",
          name = control,
          order = "g",
          category = "terrain",
        }
      })
    end
    local tile_data = {
      type = "tile",
      name = biome_name,
      collision_mask = {"ground-tile"},
      autoplace = autoplace,
      layer = layer,
      --layer = 190 - layer,
      variants = tile_variations_template(
        "__alien-biomes__/graphics/terrain/sr/"..biome_name..".png",
        "__base__/graphics/terrain/masks/transition-3.png",
        alien_biomes_hr_terrain and "__alien-biomes-hr-terrain__/graphics/terrain/hr/"..biome_name..".png" or nil,
        "__base__/graphics/terrain/masks/hr-transition-3.png",
        {
          max_size = 4,
          [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
          [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
          [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
          --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} },
        }
      ),
      transitions = biomes.transitions[biome.transition .. "_transitions"],
      transitions_between_transitions = biomes.transitions[biome.transition .. "_transitions_between_transitions"],

      walking_sound = table.deepcopy(biomes.sounds.dirt),
      map_color = biomes.colors[biome_name],
      ageing=0.0001,
      walking_speed_modifier = 1,
      vehicle_friction_modifier = 1,
    }
    if biome.axis then
      tile_data.localised_name = { "tile-name.tile_colored", { "alien-biomes."..biome.axis }, { "alien-biomes."..biome.variant } }
    else
      tile_data.localised_name = { "tile-name.tile_single", { "alien-biomes."..biome.variant } }
    end
    if biome.group == "grass" then
      tile_data.walking_sound = table.deepcopy(biomes.sounds.grass)
      tile_data.walking_speed_modifier = 1
      tile_data.vehicle_friction_modifier = 2
    elseif biome.group == "dirt" then
      tile_data.walking_sound = table.deepcopy(biomes.sounds.dirt)
      tile_data.walking_speed_modifier = 1
      tile_data.vehicle_friction_modifier = 0.9
    elseif biome.group == "sand" then
      tile_data.walking_sound = table.deepcopy(biomes.sounds.sand)
      tile_data.walking_speed_modifier = 0.7
      tile_data.vehicle_friction_modifier = 4
    elseif biome.group == "frozen" then
      tile_data.walking_sound = table.deepcopy(biomes.sounds.snow)
      tile_data.walking_speed_modifier = 0.8
      tile_data.vehicle_friction_modifier = 8
      if biome.variant == "snow-5"
      or biome.variant == "snow-6"
      or biome.variant == "snow-7"
      or biome.variant == "snow-9" then -- ice
        tile_data.walking_sound = table.deepcopy(biomes.sounds.ice)
      end
    elseif biome.group == "volcanic" then
      tile_data.walking_sound = table.deepcopy(biomes.sounds.dirt)
      if biome.variant == "heat-1" then
        tile_data.walking_speed_modifier = 1
        tile_data.vehicle_friction_modifier = 2
      elseif biome.variant == "heat-2" then
        tile_data.walking_speed_modifier = 0.9
        tile_data.vehicle_friction_modifier = 4
      elseif biome.variant == "heat-3" then
        tile_data.walking_speed_modifier = 0.7
        tile_data.vehicle_friction_modifier = 8
      elseif biome.variant == "heat-4" then
        tile_data.walking_speed_modifier = 0.4
        tile_data.vehicle_friction_modifier = 32
      end
    end

    data:extend({
      tile_data
    })
  end
end
biomes.build_tiles()

local autoplaces = {}
for _, tile in pairs(data.raw.tile) do
  if tile.autoplace then
    autoplaces[_] = tile.autoplace
  end
end

return biomes
