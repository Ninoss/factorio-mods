require("resourceconfigs.vanilla")  -- vanilla ore/liquids (no enemies)
require("resourceconfigs.vanilla_enemies")
require("resourceconfigs.roadworks")
require("resourceconfigs.dytech")
require("resourceconfigs.bobores")
require("resourceconfigs.bobenemies")
require("resourceconfigs.peacemod")
require("resourceconfigs.yuoki_industries")
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
require("resourceconfigs.hardcrafting")
require("resourceconfigs.5dimores")
require("resourceconfigs.thunderstone")
require("resourceconfigs.reactor")
require("resourceconfigs.narmod")
require("resourceconfigs.alienwall")
require("resourceconfigs.senpais")
require("resourceconfigs.beyond")
require("resourceconfigs.andrew")
require("resourceconfigs.bukket")
require("resourceconfigs.infinium")
require("resourceconfigs.anonymods")
require("resourceconfigs.sulfurmod")
require("resourceconfigs.primordialooze")
require("resourceconfigs.omnimatter")
require("resourceconfigs.portalresearch")
require("resourceconfigs.sigmaonenuclear")
require("resourceconfigs.xander")
require("resourceconfigs.darkstar")
require("resourceconfigs.dyworld")
require("resourceconfigs.pyfusion")
require("resourceconfigs.druglab")
require("resourceconfigs.hydraulicpumpjacks")
require("resourceconfigs.napus")
require("resourceconfigs.fpp")
require("resourceconfigs.iceore")
-- require("resourceconfigs.yaiom")


function loadResourceConfig()
	
	config={}
	
	fillVanillaConfig()
	
	--[[ MODS SUPPORT ]]--
	if game.active_mods["fpp"] then
		fillFppConfig()
	end
	
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
	
	-- Andrew's mods (ores)
	if game.active_mods["andrew-ore"] then
		fillAndrewConfig()
	end
	
	if game.entity_prototypes["natural-gas"] then
		fillNaturalGasConfig()
	end

	-- BobOres
	if game.active_mods["bobores"] and game.entity_prototypes["rutile-ore"] then
		fillBoboresConfig()
	elseif game.active_mods["5dim_ores"] then
		fill5dimConfig()
	end
	
	-- peace mod
	if game.entity_prototypes["alien-ore"] then
		fillPeaceConfig()
	end  
	
	--yuoki industries mod
	if game.entity_prototypes["y-res1"] then
		fillYuokiConfig()
	end
	
	--replicators mod
	if game.entity_prototypes["rare-earth"] then
		fillReplicatorsConfig()
	end
	
	--uranium power mod
	if game.entity_prototypes["uraninite"] then
		fillUraniumpowerConfig()
	end

	-- ground sulfur, need to check for autoplace since bob's mods use same ore name
	if game.entity_prototypes["sulfur"] and game.entity_prototypes["sulfur"].autoplace_specification ~= nil then
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

	-- deep ores
	if game.entity_prototypes["deep-copper-ore"] and game.entity_prototypes["deep-iron-ore"] then
		fillDeepOresConfig()
	end
	
	-- hard crafting
	if game.entity_prototypes["rich-copper-ore"] then
		if game.active_mods["BukketMod"] then
			fillBukketConfig()
		else
			fillHardCraftingConfig()
		end
	end
	
	-- angels ores
	if game.entity_prototypes["angels-ore1"] then
		fillAngelsOresConfig()
		-- remove no longer needed ores
		config["copper-ore"] = nil
		config["iron-ore"] = nil
		config["stone"] = nil
	end
	
	if game.entity_prototypes["monazite-ore"] then
		fillThunderStoneConfig()
	end
	
	if game.entity_prototypes["nuclear-ores"] then
--		fillReactorConfig()
	end
	
	-- NARMod
	if game.entity_prototypes["brine-pool"] then
		fillNARModConfig()
	end
	
	if game.entity_prototypes["alien-biomass"] then
		fillAlienWallConfig()
	end
	
	if game.active_mods["SenpaisOverhall"] then
		fillSenpaisConfig()
	end
	
	if game.active_mods["Beyond"] then
		fillBeyondConfig()
	end
	
	if game.active_mods["infinium-ore"] then
		fillInfiniumConfig()
	end

	if game.active_mods["AnonyMods"] then
		fillAnonyModsConfig()
	end

	if game.active_mods["cncs_Sulfur_Mod"] then
		fillSulfurConfig()
	end
	
	if game.active_mods["PrimordialOoze"] then
		fillPrimordialOozeConfig()
	end

	if game.active_mods["omnimatter"] then
		fillOmnimatterConfig()
	end

	if game.active_mods["portal-research"] then
		fillPortalResearchConfig()
	end

	if game.active_mods["SigmaOne_Nuclear"] then
		fillSigmaOneNuclearConfig()
	end

	if game.active_mods["xander-mod"] then
		fillXanderConfig()
	end

	if game.active_mods["Darkstar_utilities"] then
		fillDarkstarConfig()
	end

	if game.active_mods["DyWorld"] then
		fillDyWorldConfig()
	end

	if game.active_mods["pyfusionenergy"] then
		fillPyFusionConfig()
	end

	if game.active_mods["druglab"] then
		fillDrugLabConfig()
	end

	if game.active_mods["HydraulicPumpjacks"] then
		fillHydraulicPumpjacksConfig()
	end
	
	if game.active_mods["NapusMod"] then
		fillNapusConfig()
	end
	
	if game.active_mods["IceOre"] then
		fillIceOreConfig()
	end

	if game.active_mods["yaiom"] then
--		fillYaiomConfig()
	end

	return config
end