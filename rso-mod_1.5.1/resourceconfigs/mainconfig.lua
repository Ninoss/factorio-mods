require("resourceconfigs.vanilla")  -- vanilla ore/liquids (no enemies)
require("resourceconfigs.vanilla_enemies")
require("resourceconfigs.roadworks")
require("resourceconfigs.dytech")
require("resourceconfigs.bobores")
require("resourceconfigs.bobenemies")
require("resourceconfigs.peacemod")
require("resourceconfigs.yuoki_industries")
require("resourceconfigs.mopower")
require("resourceconfigs.replicators")
require("resourceconfigs.uraniumpower")
require("resourceconfigs.homeworld")
require("resourceconfigs.groundsulfur")
require("resourceconfigs.evolution")
require("resourceconfigs.replicators")
require("resourceconfigs.darkmatter")
require("resourceconfigs.springwater")
require("resourceconfigs.sulfuricacid")
require("resourceconfigs.naturalgas")
require("resourceconfigs.deepores")
require("resourceconfigs.angelsores")


function loadResourceConfig()
	
	config={}
	
	fillVanillaConfig()
	
	--[[ MODS SUPPORT ]]--
	if not game.entity_prototypes["alien-ore"] or useEnemiesInPeaceMod then  -- if the user has peacemod installed he probably doesn't want that RSO spawns them either. remote.interfaces["peacemod"]
		if game.entity_prototypes["bob-big-explosive-worm-turret"] and game.entity_prototypes["bob-big-fire-worm-turret"] and game.entity_prototypes["bob-big-poison-worm-turret"] then
			fillBobEnemies()
		else
			fillEnemies()
		end
	end
	
	-- Roadworks mod
	if game.entity_prototypes["RW_limestone"] then
		fillRoadworksConfig()
	end
	
	-- DyTech
	-- i moved everything even the checks there, i think it's cleaner this way
	fillDytechConfig()
	
	-- BobOres
	if game.entity_prototypes["rutile-ore"] then
		fillBoboresConfig()
	end
	
	-- peace mod
	if game.entity_prototypes["alien-ore"] then
		fillPeaceConfig()
	end  
	
	--yuoki industries mod
	if game.entity_prototypes["y-res1"] then
		fillYuokiConfig()
	end
	
	--mopower mod
	if game.entity_prototypes["uranium-ore"] then
		fillMopowerConfig()
	end
	
	--replicators mod
	if game.entity_prototypes["rare-earth"] then
		fillReplicatorsConfig()
	end
	
	--uranium power mod
	if game.entity_prototypes["uraninite"] then
		fillUraniumpowerConfig()
	end

	-- ground sulfur
	if game.entity_prototypes["sulfur"] then
		fillGroundSulfurConfig()
	end
	
	-- evolution
	if game.entity_prototypes["alien-artifacts"] then
		fillEvolutionConfig()
	end
	
	-- replicators
	if game.entity_prototypes["creatine"] then
		fillReplicatorsConfig()
	end
	
	-- homeworld
	if game.entity_prototypes["sand-source"] then
		fillHomeworldConfig()
	end
	
	-- dark matter replicators
	if game.entity_prototypes["tenemut"] then
		fillDarkMatterConfig()
	end

	-- spring water
	if game.entity_prototypes["spring-water"] then
		fillSpringWaterConfig()
	end
	
	-- sulfruric acid
	if game.entity_prototypes["sulfuric-acid"] then
		fillSulfuricAcidConfig()
	end

	-- natural gas
	if game.entity_prototypes["natural-gas"] then
		fillNaturalGasConfig()
	end

	-- deep ores
	if game.entity_prototypes["deep-copper-ore"] and game.entity_prototypes["deep-iron-ore"] then
		fillDeepOresConfig()
	end
	
	-- angels ores
	if game.entity_prototypes["angels-ore1"] then
		fillAngelsOresConfig()
		-- remove no longer needed ores
		config["copper-ore"] = nil
		config["iron-ore"] = nil
		config["stone"] = nil
	end

	return config
end