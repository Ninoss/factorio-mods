function fillIceOreConfig()

	config["ice-ore"] = {
		type="resource-ore",
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=20, max=30},
		min_amount=500,
    
		starting={richness=8000, size=25, probability=1}
	}
end