
fm.viewer = {}

-- Taken with modification from YARM.
function fm.viewer(event, coords, goBack)
    if not global.player_data[event.player_index] then
        global.player_data[event.player_index] = {}
    end

    local player = game.players[event.player_index]
    local player_data = global.player_data[event.player_index]
    goBack = not not goBack

    -- Don't bodyswap too often, Factorio hates it when you do that.
    if player_data.last_bodyswap and player_data.last_bodyswap + 10 > event.tick then
        player.print({"warn-body-swap"})
        return
    end
    player_data.last_bodyswap = event.tick

    if (player_data.viewing and goBack) then
        -- returning to our home body
        if player_data.real_character == nil or not player_data.real_character.valid then
            player.print({"warn-no-return-possible"})
            return
        end

        player.character = player_data.real_character
        player_data.remote_viewer.destroy()

        player_data.real_character = nil
        player_data.remote_viewer = nil
        player_data.viewing = false
    elseif (player_data.viewing and not goBack) then
        -- Moving our viewer somewhere else. Take a shortcut and just teleport it. :p
        player_data.remote_viewer.teleport(coords)
    elseif not player_data.viewing and not goBack then
        -- stepping out to a remote viewer: first, be sure you remember your old body
        if not player_data.real_character or not player_data.real_character.valid then
            -- Abort if the "real" character is missing (e.g., god mode) or isn't a player!
            -- NB: this might happen if you use something like The Fat Controller or Command Control
            -- and you do NOT want to get stuck not being able to return from those
            if not player.character or player.character.name ~= "player" then
                player.print({"warn-not-in-real-body"})
                return
            end

            player_data.real_character = player.character
        end
        player_data.viewing = true

        -- make us a viewer and put us in it
        local viewer = player.surface.create_entity({name="FactorioMaps_remote-viewer", position=coords, force=player.force})
        viewer.destructible = false
        player.character = viewer

        -- don't leave an old one behind
        -- With the teleport check this shouldn't be needed but never too safe.
        if player_data.remote_viewer then
            player_data.remote_viewer.destroy()
        end
        player_data.remote_viewer = viewer
    else
        -- What are you trying to pull here?
        -- goBack to what? You aren't viewing anything.
        player.print("FACTORIOMAPS_DEBUG: But...But...You aren't viewing anything?\nTrying to pull one over on me?")
    end
end
