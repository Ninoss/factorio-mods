require "util"
require "defines"
require "config"

--[[ Made by Hazzard & BiG_MEECH ]]--
-- GPLv2 --

script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  if entity.type ~= "player" then return end

  local pos = entity.surface.find_non_colliding_position(
    "gravestone", entity.position, 8, 1)
  if not pos then return end

  local grave = entity.surface.create_entity{
    name="gravestone", position=pos, force=entity.force}
  if protective_mode then
	grave.destructible = false
  end
  local grave_inv = grave.get_inventory(defines.inventory.chest)

  local count = 0
  for i, id in ipairs{
      defines.inventory.player_guns,
      defines.inventory.player_tools,
      defines.inventory.player_ammo,
      defines.inventory.player_armor,
      defines.inventory.player_quickbar,
      defines.inventory.player_main,
      defines.inventory.player_trash} do
    local inv = entity.get_inventory(id)
    for j = 1, #inv do
      if inv[j].valid_for_read then
        count = count + 1
        if count > #grave_inv then return end
        grave_inv[count].set_stack(inv[j])
      end
    end
  end
end)