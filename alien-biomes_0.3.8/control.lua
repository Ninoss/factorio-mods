local function save_mod_settings()
  global.saved_settings = {}
  for _, setting in pairs(settings.startup) do
    if string.find(_, "alien%-biomes") then
      global.saved_settings[_] = setting
    end
  end
end

local function show_changed_settings()

  local text = "The current Alien Biomes mod settings for map generation do not match the settings that were used to create this map. \n\n"
  text = text .. "If you continue with the current settings and do not regenerate the terrain, then new terrain chunks will be created with the current settings and will not match the old terrain. \n\n"
  text = text .. "If you click Regenerate, then the existing terrain will be completely rebuilt to match the new terrain. (Some areas will be missing decoratives.) \n\n"
  text = text .. "This RESETS large sections of the map, you will probably lose some progress so don't overwrite your old save.\n\n"
  text = text .. "The regeneration process can take a long time. \n\n"
  text = text .. "To restore the original settings of this map, exit this map without saving, then in the Factorio main menu go to \n"
  text = text .. "Options > Mod Settings > Startup > Alien Biomes \n"
  text = text .. "and restore the original settings as shown below: "

  local settings_text = ""
  for _, setting in pairs(global.saved_settings) do
    if string.len(settings_text) > 0 then
       settings_text = settings_text .. ",\n"
    end
    local value = setting.value
    if value == true or value == false then
      value = value and "true" or "false"
    end
    settings_text = settings_text .. '"'.. _ .. '": { "value": ' .. value .. " }"
  end

  for _, player in pairs(game.connected_players) do
    player.gui.center.add{type = "frame", name="alien_biomes_settings_frame", style="alien-biomes-frame", direction="vertical", caption="Terrain Setting Mismatch"}
    player.gui.center.alien_biomes_settings_frame.add{type = "scroll-pane", name="alien_biomes_scroll", style="alien-biomes-scroll-pane", direction="vertical"}
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{
      type = "label",
      name="alien_biomes_settings_label",
      caption = text,
      style = "alien-biomes-label-multiline"
    }
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{
      type = "text-box",
      name="alien_biomes_settings_textbox",
      text = settings_text,
      style = "alien-biomes-textbox"
    }
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{
      type = "label",
      name="alien_biomes_settings_label2",
      caption = "If you know how to edit your mod-settings.json file you can  paste the above settings in the \"startup\" section.",
      style = "alien-biomes-label-multiline"
    }
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{type = "button", name="alien_biomes_settings_regenerate", caption="Regenerate Terrain"}
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{type = "button", name="alien_biomes_settings_close", caption="Do Not Regenerate"}
  end

end

local function offer_regenerate()

  local text = "Alien Biomes has been added to you map. If you continue and do not regenerate the terrain, then new terrain chunks generated will not match the existing terrain. \n\n"
  text = text .. "If you click Regenerate, then the existing terrain will be completely rebuilt to match the new terrain. (Some areas will be missing decoratives.) \n\n"
  text = text .. "This RESETS large sections of the map, you will probably lose some progress so don't overwrite your old save.\n\n"
  text = text .. "The regeneration process can take a long time."

  for _, player in pairs(game.connected_players) do
    player.gui.center.add{type = "frame", name="alien_biomes_settings_frame", style="alien-biomes-frame", direction="vertical", caption="Terrain Setting Mismatch"}
    player.gui.center.alien_biomes_settings_frame.add{type = "scroll-pane", name="alien_biomes_scroll", style="alien-biomes-scroll-pane", direction="vertical"}
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{
      type = "label",
      name="alien_biomes_settings_label",
      caption = text,
      style = "alien-biomes-label-multiline"
    }
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{type = "button", name="alien_biomes_settings_regenerate", caption="Regenerate Terrain"}
    player.gui.center.alien_biomes_settings_frame.alien_biomes_scroll.add{type = "button", name="alien_biomes_settings_close", caption="Do Not Regenerate"}
  end

end

local function assert_settings()

  if not global.saved_settings then return end

  for _, setting in pairs(settings.startup) do
    if string.find(_, "alien%-biomes") and global.saved_settings[_] then
      if setting.value ~= global.saved_settings[_].value then
        show_changed_settings()
        return
      end
    end
  end

end

local function rebuild_nauvis()

  local nauvis_name = "nauvis"
  local nauvis_copy_name = "nauvis-copy"
  local chunksize = 32

  if not game.surfaces[nauvis_copy_name] then
    game.create_surface(nauvis_copy_name)
  end

  local nauvis = game.surfaces[nauvis_name]
  local nauvis_copy = game.surfaces[nauvis_copy_name]

  local chunks = {}
  for chunk in nauvis.get_chunks() do
    table.insert(chunks, {x = chunk.x, y = chunk.y})
  end

  -- make the new chunks
  for _, chunk in pairs(chunks) do
    local count = 0
    count = nauvis.count_entities_filtered{
        area = {{chunk.x * 32, chunk.y * 32}, {chunk.x * 32 + 32, chunk.y * 32 + 32}},
        force = game.forces["player"],
        limit = 1
      }
    if count > 0 then
      -- there are forces here so copy tiles
      nauvis_copy.request_to_generate_chunks({x = chunk.x * chunksize, y = chunk.y * chunksize}, 0)
    else
      -- no forces, just delete and remake
      nauvis.delete_chunk(chunk)
      chunks[_] = nil
    end
  end
  nauvis_copy.force_generate_chunk_requests()

  local tiles = {}
  for _, chunk in pairs(chunks) do
    for y = 0, 31, 1 do
      for x = 0, 31, 1 do
        local position = {
          x = chunk.x * chunksize + x,
          y = chunk.y * chunksize + y
        }
        local tile_name = nauvis_copy.get_tile(position.x, position.y).name
        table.insert(tiles, {name = tile_name, position = position})
      end
    end
  end
  nauvis.set_tiles(tiles, true)

  -- nauvis.regenerate_decorative() -- does not work properly, everything is at highest density

  game.delete_surface(nauvis_copy)

  game.print("Nauvis Regeneration Complete")
end

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "alien_biomes_settings_close" then
    game.players[event.player_index].gui.center.alien_biomes_settings_frame.destroy()
  elseif event.element.name == "alien_biomes_settings_regenerate" then
    game.players[event.player_index].gui.center.alien_biomes_settings_frame.destroy()
    rebuild_nauvis()
  end
end)


-- mod has changed or mod setting has changed
script.on_configuration_changed(function()

  assert_settings()

end)


script.on_event(defines.events.on_tick, function(event)
  if not global.saved_settings then

    save_mod_settings()
    if game.tick > 1 then
      -- alien biomes added to existing map,
      offer_regenerate()
    end
  end

end)
