function fillDyWorldConfig()
	
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,
	}
	
	config["silver-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,

		starting={richness=4000, size=12, probability=1},
	}
	
	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=10, max=20},
		min_amount = 4000,
		
		starting={richness=8000, size=15, probability=1},
	}
	
	config["tin-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=10, max=20},
		min_amount = 4500,
		
		starting={richness=8000, size=15, probability=1},
	}

	config["chromium-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,

		starting={richness=4000, size=12, probability=1},
	}
	
	config["zinc-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,
		
		starting={richness=4000, size=12, probability=1},
	}
	
	config["tungsten-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,
	}	
	
	config["aluminium-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,
	}	
	
	config["nickel-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 2500,
	}	

end