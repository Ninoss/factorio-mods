local function generateIcon(entity)
  if entity.icons then
    local icons = table.deepcopy(entity.icons)
    table.insert(icons, { icon = "__LightedPolesPlus__/graphics/icons/lighted.png", tint = {r=1, g=1, b=1, a=0.85} })
    return icons
  elseif entity.icon then
    local icons =
    {
      { icon = entity.icon,
        tint = {r=1, g=1, b=1, a=1}
      },
      { icon = "__LightedPolesPlus__/graphics/icons/lighted.png",
        tint = {r=1, g=1, b=1, a=0.85}
      },
    }
    return icons
  else
    --log(entity.name.." didn't contain an icon.")
    return nil
  end
end

local items = {}
local lightedPoles = {}

-- look through items for electric-poles should save looking through recipes and entities
for _,item in pairs (data.raw["item"]) do
  -- look through all item.place_result in case item and recipe names don't match entity name
  if item.place_result and data.raw["electric-pole"][item.place_result] then
    log("[LEP+] found pole "..item.place_result.." in item "..item.name)
    local pole = data.raw["electric-pole"][item.place_result]
    if pole.minable and pole.minable.result and pole.minable.result == item.name then -- only generate lighted pole if item and entity properly reference another
			pole.fast_replaceable_group = pole.fast_replaceable_group or "electric-pole"

			local newName = "lighted-"..pole.name

      log("[LEP+] copying entity "..tostring(pole.name).." to "..tostring(newName))
      local newPole = table.deepcopy(pole)
      newPole.name = newName
      newPole.minable.result = newName
      newPole.icon = nil
      newPole.icons = generateIcon(pole)
      newPole.localised_name = {"entity-name.lighted-pole", {"entity-name." .. pole.name}}

      log("[LEP+] copying item "..tostring(item.name).." to "..tostring(newName))
      items[item.name] = newName --save items for technology lookup
      local newItem = table.deepcopy(item)
      newItem.name = newName
      newItem.place_result = newName
      newItem.icon = nil
      newItem.icons = generateIcon(item)
      newItem.localised_name = newPole.localised_name

      newPole.icons = newPole.icons or newItem.icons -- use item icon for lighted pole in case base pole entity had none

      local recipe =
      {
        type = "recipe",
        name = newName,
        enabled = "false",
        ingredients =
        {
          {item.name, 1},
          {"small-lamp", 1}
        },
        result = newName
      }

      -- temporary store generated pole, will be added to data after generation is complete
      table.insert(lightedPoles, newPole)
      table.insert(lightedPoles, newItem)
      table.insert(lightedPoles, recipe)
    end
  end

end
data:extend(lightedPoles)

 -- add to technology
for _, tech in pairs(data.raw["technology"]) do
  if tech.effects then
    for _, effect in pairs(tech.effects) do
      if effect.recipe and data.raw["recipe"][effect.recipe] then
        local recres = data.raw["recipe"][effect.recipe].result
        if recres and items[recres] then
          log("[LEP+] found original recipe result "..recres..", inserting "..items[recres].." into technology "..tech.name)
          table.insert(data.raw["technology"][tech.name].effects, {type="unlock-recipe",recipe=items[recres]})
        end
      end
    end
  end
end

if data.raw["recipe"]["lighted-small-electric-pole"] then table.insert(data.raw["technology"]["optics"].effects,{type="unlock-recipe",recipe="lighted-small-electric-pole"}) end
