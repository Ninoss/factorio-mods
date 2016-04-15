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

-- This seems to get called twice, so the multipied value here should
-- be the sqrt of what you really want. I.e. * 2 gives you 4x the stack
-- size.
function increase_stack(val)
	-- We need the < 10000, because some items seem to have really
	-- huge default stack values (MAX_INT?), and multiplying them by
	-- 4 causes everything to break.
	if val.stack_size and val.stack_size > 1 and val.stack_size < 10000 then
		val.stack_size = val.stack_size * 2
	end
end

--print(pretty(data.raw))
for _,dat in pairs(data.raw) do
   for _,items in pairs(dat) do
		increase_stack(items)
		--print(pretty(items))
		--print(items.stack_size)
         --items.stack_size = items.stack_size * 4
		 --print(items.stack_size)
   end
end
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
