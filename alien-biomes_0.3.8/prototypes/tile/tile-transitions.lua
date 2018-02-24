local transitions = {}
transitions.beach_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__alien-biomes__/graphics/terrain/water-transitions/sr/beach.png",
      "__alien-biomes__/graphics/terrain/water-transitions/hr/beach.png",
      {
        o_transition_tall = false,
        u_transition_tall = false,
        side_tall = false,
        inner_corner_tall = false,
        outer_corner_tall = false,
        u_transition_count = 4,
        o_transition_count = 8,
        base = { background_layer_offset = -1 }
      }
  ),
}

transitions.beach_transitions_between_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__alien-biomes__/graphics/terrain/water-transitions/sr/beach-transition.png",
      "__alien-biomes__/graphics/terrain/water-transitions/hr/beach-transition.png",
      {
        side_tall = false,
        inner_corner_tall = false,
        outer_corner_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
      }
  ),
}

transitions.cliff_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__alien-biomes__/graphics/terrain/water-transitions/sr/cliff.png",
      "__alien-biomes__/graphics/terrain/water-transitions/hr/cliff.png",
      {
        o_transition_tall = false,
        u_transition_count = 2,
        o_transition_count = 4,
        side_count = 8,
        outer_corner_count = 8,
        inner_corner_count = 8,
      }
  ),
}

transitions.cliff_transitions_between_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__alien-biomes__/graphics/terrain/water-transitions/sr/cliff-transition.png",
      "__alien-biomes__/graphics/terrain/water-transitions/hr/cliff-transition.png",
      {
        o_transition_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
      }
  ),
}


return transitions
