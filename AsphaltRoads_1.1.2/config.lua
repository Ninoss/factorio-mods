-- This value modifies the bonus speed the player will experience if they walk on this tiles
asphalt_walking_speed_modifier = 1.4 -- concrete: 1.4

-- This value modifies the vehicle friction: Lower values increase acceleration and top-speed. This affects wheeled vehicles the most.
asphalt_vehicle_speed_modifier = 0.5 -- concrete: 0.8 

-- Set this values ingame in Setting/Mods/AsphaltRoads/Startup
use_BioIndustries_items = settings.startup["AR-use-items-from-bioindustries"].value
asphalt_stack_size = settings.startup["AR-asphalt-stack-size"].value
-- WIP: merge_transitions_of_asphalt_tiles = settings.startup["AR-merge-transitions-of-asphalt-tiles"].value

-- The following values represent the minimap colours of asphalt tiles:
asphalt_colour =                 {r=34, g=31, b=28}

asphalt_colour_marking_white =   {r=60, g=60, b=60}

asphalt_colour_marking_yellow =  {r=60, g=60, b=40}

asphalt_colour_marking_blue =    {r=40, g=40, b=49}

asphalt_colour_marking_red =     {r=49, g=40, b=40}

asphalt_colour_marking_green =   {r=40, g=49, b=40}

-- layer of all asphalt tiles except those with diagonal lines
asphalt_base_layer = 60 

-- layer of diagonal line tiles
asphalt_priority_layer = asphalt_base_layer + 1

-- WIP: asphalt_merge_tile = "Arci-asphalt"