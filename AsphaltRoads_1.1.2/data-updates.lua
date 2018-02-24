require "config"
tile_layer_correction = require("util/tile-layer-correction")

-- if Bio_Industries is present:
if use_BioIndustries_items and data.raw["item"]["stone-crushed"] then
	data.raw["recipe"]["Arci-asphalt"].ingredients[3] = {type="item", name="stone-crushed", amount=8}
else 
    data.raw["recipe"]["Arci-asphalt"].ingredients[3] = {type="item", name="stone-brick", amount=4}
end 

-- asphalt has a lower layer than stone or other tilesets. The following function increases the layer of all tilesets accordingly.
tile_layer_correction.shift_tile_layer(asphalt_base_layer, 2) 