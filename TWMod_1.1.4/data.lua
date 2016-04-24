local StackSize = 1000
local MagSize = 500
print("HI")
function pretty(value,htchar,lfchar,indent)
  local str
  if htchar == nil then htchar = "\t" end
  if lfchar == nil then lfchar = "\n" end
  if indent == nil then indent = 0 end
  if type(value)=="table" then
    str = {}
    for key,v in pairs(value) do
      table.insert(str, string.format(
        "%s%s%s:%s",
        lfchar,
        string.rep(htchar,indent+1),
        string.format("%q", key):gsub("\\\n", "\\n"),
        pretty(value[key],htchar,lfchar,indent+1)))
    end
    return string.format("{%s%s%s}",table.concat(str,","),lfchar,string.rep(htchar,indent))
  elseif type(value)=="nil" then
    return "nil"
  elseif type(value)=="boolean" then
    if value then return "true" else return "false" end
  elseif type(value)=="string" then
    return string.format("%q", value):gsub("\\\n", "\\n")
  else
    return tostring(value)
  end
end

-- All items and 2x default stack sizes.
-- stone-brick: 200
-- raw-wood: 100
-- coal: 100
-- stone: 100
-- iron-ore: 100
-- copper-ore: 100
-- wood: 100
-- iron-plate: 200
-- copper-plate: 200
-- iron-stick: 200
-- iron-gear-wheel: 200
-- copper-cable: 400
-- electronic-circuit: 400
-- wooden-chest: 100
-- stone-furnace: 100
-- burner-mining-drill: 100
-- basic-mining-drill: 100
-- basic-transport-belt: 100
-- burner-inserter: 100
-- basic-inserter: 100
-- offshore-pump: 40
-- pipe: 100
-- boiler: 100
-- steam-engine: 20
-- small-electric-pole: 100
-- radar: 100
-- computer: 1
-- small-plane: 1
-- small-lamp: 100
-- alien-artifact: 1000
-- pipe-to-ground: 100
-- assembling-machine-1: 100
-- red-wire: 400
-- green-wire: 400
-- stone-wall: 100
-- gun-turret: 100
-- solar-panel-equipment: 40
-- fusion-reactor-equipment: 40
-- energy-shield-equipment: 100
-- energy-shield-mk2-equipment: 100
-- battery-equipment: 100
-- battery-mk2-equipment: 100
-- basic-laser-defense-equipment: 40
-- basic-electric-discharge-defense-equipment: 40
-- basic-exoskeleton-equipment: 20
-- personal-roboport-equipment: 10
-- night-vision-equipment: 40
-- land-mine: 40
-- iron-chest: 100
-- steel-chest: 100
-- smart-chest: 100
-- fast-transport-belt: 100
-- express-transport-belt: 100
-- long-handed-inserter: 100
-- fast-inserter: 100
-- smart-inserter: 100
-- assembling-machine-2: 100
-- assembling-machine-3: 100
-- solar-panel: 100
-- diesel-locomotive: 10
-- cargo-wagon: 10
-- straight-rail: 200
-- curved-rail: 100
-- player-port: 100
-- gate: 100
-- car: 1
-- tank: 1
-- lab: 20
-- train-stop: 20
-- rail-signal: 100
-- rail-chain-signal: 100
-- steel-plate: 200
-- basic-transport-belt-to-ground: 100
-- fast-transport-belt-to-ground: 100
-- express-transport-belt-to-ground: 100
-- basic-splitter: 100
-- fast-splitter: 100
-- express-splitter: 100
-- advanced-circuit: 400
-- processing-unit: 200
-- logistic-robot: 100
-- construction-robot: 100
-- logistic-chest-passive-provider: 100
-- logistic-chest-active-provider: 100
-- logistic-chest-storage: 100
-- logistic-chest-requester: 100
-- rocket-silo: 1
-- roboport: 10
-- coin: 100000
-- big-electric-pole: 100
-- medium-electric-pole: 100
-- substation: 100
-- basic-accumulator: 100
-- steel-furnace: 100
-- electric-furnace: 100
-- basic-beacon: 20
-- storage-tank: 100
-- small-pump: 100
-- pumpjack: 40
-- oil-refinery: 20
-- chemical-plant: 20
-- sulfur: 100
-- empty-barrel: 20
-- crude-oil-barrel: 20
-- solid-fuel: 100
-- plastic-bar: 200
-- engine-unit: 100
-- electric-engine-unit: 100
-- explosives: 100
-- battery: 400
-- flying-robot-frame: 100
-- arithmetic-combinator: 100
-- decider-combinator: 100
-- constant-combinator: 100
-- low-density-structure: 20
-- rocket-fuel: 20
-- rocket-control-unit: 20
-- rocket-part: 10
-- satellite: 1
-- concrete: 200
-- laser-turret: 100
-- gunship: 1
-- water-barrel: 20
-- sulfuric-acid-barrel: 20
-- lubricant-barrel: 20
-- petroleum-gas-barrel: 20
-- light-oil-barrel: 20
-- heavy-oil-barrel: 20
-- landfill2by2: 512
-- landfill4by4: 512
-- water-be-gone: 128
-- water-bomb: 128
-- letter-uc-a: 60
-- letter-uc-b: 60
-- letter-uc-c: 60
-- letter-uc-d: 60
-- letter-uc-e: 60
-- letter-uc-f: 60
-- letter-uc-g: 60
-- letter-uc-h: 60
-- letter-uc-i: 60
-- letter-uc-j: 60
-- letter-uc-k: 60
-- letter-uc-l: 60
-- letter-uc-m: 60
-- letter-uc-n: 60
-- letter-uc-o: 60
-- letter-uc-p: 60
-- letter-uc-q: 60
-- letter-uc-r: 60
-- letter-uc-s: 60
-- letter-uc-t: 60
-- letter-uc-u: 60
-- letter-uc-v: 60
-- letter-uc-w: 60
-- letter-uc-x: 60
-- letter-uc-y: 60
-- letter-uc-z: 60
-- letter-lc-a: 60
-- letter-lc-b: 60
-- letter-lc-c: 60
-- letter-lc-d: 60
-- letter-lc-e: 60
-- letter-lc-f: 60
-- letter-lc-g: 60
-- letter-lc-h: 60
-- letter-lc-i: 60
-- letter-lc-j: 60
-- letter-lc-k: 60
-- letter-lc-l: 60
-- letter-lc-m: 60
-- letter-lc-n: 60
-- letter-lc-o: 60
-- letter-lc-p: 60
-- letter-lc-q: 60
-- letter-lc-r: 60
-- letter-lc-s: 60
-- letter-lc-t: 60
-- letter-lc-u: 60
-- letter-lc-v: 60
-- letter-lc-w: 60
-- letter-lc-x: 60
-- letter-lc-y: 60
-- letter-lc-z: 60
-- letter-s-0: 60
-- letter-s-1: 60
-- letter-s-2: 60
-- letter-s-3: 60
-- letter-s-4: 60
-- letter-s-5: 60
-- letter-s-6: 60
-- letter-s-7: 60
-- letter-s-8: 60
-- letter-s-9: 60
-- letter-s-and: 60
-- letter-s-equal: 60
-- letter-s-exclamation: 60
-- letter-s-op: 60
-- letter-s-plate: 60
-- letter-s-plus: 60
-- letter-s-question: 60
-- letter-s-slash: 60
-- reverse-factory: 20
-- robotic-network-combinator: 100
-- TeleporterCore: 32
-- Teleporter_Tier01: 4
-- Teleporter_Tier02: 4
-- Teleporter_Tier03: 4
-- Teleporter_Tier04: 4
-- Teleporter_Tier05: 4
-- Teleporter_Tier06: 4
-- Teleporter_Tier07: 4
-- Teleporter_Tier08: 4
-- Teleporter_Tier09: 4
-- Teleporter_Tier10: 4
-- Teleporter_Upgrade_02: 4
-- Teleporter_Upgrade_03: 4
-- Teleporter_Upgrade_04: 4
-- Teleporter_Upgrade_05: 4
-- Teleporter_Upgrade_06: 4
-- Teleporter_Upgrade_07: 4
-- Teleporter_Upgrade_08: 4
-- Teleporter_Upgrade_09: 4
-- Teleporter_Upgrade_10: 4
-- smart-train-stop: 20
-- smart-train-stop-proxy: 100
-- smart-train-stop-proxy-cargo: 100
-- stainless-steel-wagon: 10
-- stainless-steel-plate: 200

function increase_stack(val)
	-- We need the < 10000, because some items seem to have really
	-- huge default stack values (MAX_INT?), and multiplying them by
	-- 2 causes everything to break.
	if val.stack_size and val.stack_size > 1 and val.stack_size < 10000 then
		val.stack_size = val.stack_size * 2
	end
end

--local before = io.open("before.txt", "w")
--before:write(pretty(data.raw))
--before:close()
--print("BEFORE CHANGES")
--print(pretty(data.raw))
--print("END BEFORE")
-- for ent_type, dat in pairs(data.raw) do
--    for item_type, items in pairs(dat) do
-- 	   print(ent_type .. "." .. item_type .. ": " .. (items.stack_size or "nil"))
-- 		--increase_stack(items)
-- 		--print(pretty(items))
-- 		--print(items.stack_size)
--          --items.stack_size = items.stack_size * 4
-- 		 --print(items.stack_size)
--    end
-- end
for item_name, item in pairs(data.raw.item) do
	-- calling increase_stack here seems to cause desyncs, so let's try
	-- just manually setting the sizes of a few items, below.
	--increase_stack(item)
	print(item_name .. ": " .. (item.stack_size or "nil"))
		--increase_stack(items)
		--print(pretty(items))
		--print(items.stack_size)
         --items.stack_size = items.stack_size * 4
		 --print(items.stack_size)
end
-- data.raw.item['basic-transport-belt-to-ground'].stack_size = 500
-- data.raw.item['iron-plate'].stack_size = 500
-- data.raw.item['copper-plate'].stack_size = 500

--print("AFTER CHANGES")
--print(pretty(data.raw))
--print("END AFTER")
--local after = io.open("after.txt", "w")
--after:write(pretty(data.raw))
--after:close()

--for i, ammo in pairs(data.raw.ammo) do
--	increase_stack(ammo)
	--if ammo.stack_size and ammo.stack_size>1 then
--	-ammo.stack_size = math.max(ammo.stack_size * 4, 1)
	--end
	--if ammo.magazine_size then
	--ammo.magazine_size = ammo.magazine_size * 4
	-- end
--end
--for i, mod in pairs(data.raw["module"]) do
--	increase_stack(mod)
--end
--for i, cap in pairs(data.raw["capsule"]) do
--	increase_stack(cap)
--end

--Special thanks to Dysoch (DyTech) for this fix!

--[[ Old Stackcode
--Special thanks to Dysoch (DyTech) for this fix!
StackSize = 1000
   for k, v in pairs(data.raw.item) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw.ammo) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw.gun) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw["repair-tool"]) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw.tool) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw["capsule"]) do
      v.stack_size = StackSize
   end
   for k, v in pairs(data.raw["module"]) do
      v.stack_size = StackSize
   end
--]]

--Changes the inventory size from 60 to 120
-- data.raw["player"]["player"].inventory_size = 120

--Changes the player health
-- data.raw.player.player.max_health=1000

-- Fuel changes
--data.raw.item["coal"].fuel_value = "120MJ"
--data.raw.item["wood"].fuel_value = "10MJ"
--data.raw.item["raw-wood"].fuel_value = "40MJ"

-- Steel axe settings
--data.raw["mining-tool"]["steel-axe"].speed = 60
--data.raw["mining-tool"]["steel-axe"].durability = 200000

-- Iton axe settings
--data.raw["mining-tool"]["iron-axe"].speed = 35
--data.raw["mining-tool"]["iron-axe"].durability = 10000


-- Repairpack tweaks
--data.raw["repair-tool"]["repair-pack"].durability = 500000
--data.raw["repair-tool"]["repair-pack"].speed = 50000

-- Mining speed on drills
--data.raw["mining-drill"]["basic-mining-drill"].mining_speed = 6
--data.raw["mining-drill"]["burner-mining-drill"].mining_speed = 3

-- Furnace tweaks
--data.raw.furnace["electric-furnace"].crafting_speed = 10
--data.raw.furnace["steel-furnace"].crafting_speed = 6
--data.raw.furnace["stone-furnace"].crafting_speed = 3
--Steel and stone furnace won't work with modules.. yet.
--data.raw.furnace["steel-furnace"].module_slots = 2
--data.raw.furnace["stone-furnace"].module_slots = 1
--data.raw.furnace["electric-furnace"].module_slots = 4

--Resource modifiers
--data.raw.resource["copper-ore"].autoplace.richness_base = 8000
--data.raw.resource["coal"].autoplace.richness_base = 8000
--data.raw.resource["iron-ore"].autoplace.richness_base = 8000
--data.raw.resource["crude-oil"].autoplace.richness_base = 35000
--data.raw.resource["stone"].autoplace.richness_base = 8000

--data.raw.resource["copper-ore"].autoplace.richness_multiplier = 15000
--data.raw.resource["coal"].autoplace.richness_multiplier = 15000
--data.raw.resource["iron-ore"].autoplace.richness_multiplier = 15000
--data.raw.resource["crude-oil"].autoplace.richness_multiplier = 50000
--data.raw.resource["stone"].autoplace.richness_multiplier = 15000
