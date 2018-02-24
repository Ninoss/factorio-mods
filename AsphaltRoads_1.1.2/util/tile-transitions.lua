-- this set of functions is derived from functions found in "__base__/prototypes/tile/tiles.lua"

tile_transitions = {}

function tile_transitions.water_transition_template(to_tiles, normal_res_transition, high_res_transition, options)
  local function make_transition_variation(src_x, src_y, cnt_, line_len_, is_tall)
    return
    {
      picture = normal_res_transition,
      count = cnt_,
      line_length = line_len_,
      x = src_x,
      y = src_y,
      tall = is_tall,
      hr_version=
      {
        picture = high_res_transition,
        count = cnt_,
        line_length = line_len_,
        x = 2 * src_x,
        y = 2 * (src_y or 0),
        tall = is_tall,
        scale = 0.5,
      }
    }
  end

  local t = options.base or {}
  t.to_tiles = to_tiles
  local default_count = options.count or 16
  for k,y in pairs({inner_corner = 0, outer_corner = 288, side = 576, u_transition = 864, o_transition = 1152}) do
    local count = options[k .. "_count"] or default_count
    if count > 0 and type(y) == "number" then
      local line_length = options[k .. "_line_length"] or count
      local is_tall = true
      if (options[k .. "_tall"] == false) then
        is_tall = false
      end
      t[k] = make_transition_variation(0, y, count, line_length, is_tall)
      t[k .. "_background"] = make_transition_variation(544, y, count, line_length, is_tall)
      t[k .. "_mask"] = make_transition_variation(1088, y, count, line_length)
    end
  end

  return t
end

function tile_transitions.asphalt_transitions() -- === stone_path_transitions
    return {
      tile_transitions.water_transition_template
      (
          water_tile_type_names,
          "__base__/graphics/terrain/water-transitions/stone-path.png",
          "__base__/graphics/terrain/water-transitions/hr-stone-path.png",
          {
            o_transition_tall = false,
            u_transition_count = 4,
            o_transition_count = 4,
            side_count = 8,
            outer_corner_count = 8,
            inner_corner_count = 8,
            --base = { layer = 40 }
          }
      ),
    }
end

function tile_transitions.asphalt_transitions_between_transitions() -- === stone_path_transitions_between_transitions
    return {
      tile_transitions.water_transition_template
      (
          water_tile_type_names,
          "__base__/graphics/terrain/water-transitions/stone-path-transitions.png",
          "__base__/graphics/terrain/water-transitions/hr-stone-path-transitions.png",
          {
            inner_corner_tall = true,
            inner_corner_count = 3,
            outer_corner_count = 3,
            side_count = 3,
            u_transition_count = 1,
            o_transition_count = 0,
          }
      ),
    }
end

return tile_transitions
