local vehiclesnap_amount = 16.0
-- snap amount is the amount of different angles car can drive on,
-- (360 / vehiclesnap_amount) is the difference between 2 axis
-- car will slowly turn towards such angle axis

script.on_event("VehicleSnap-toggle", 
    function(event)
        global.players[event.player_index].snap = not global.players[event.player_index].snap
    end
)

--This is ran everytime the game is changed (adding mods upgrading etc) and installed.
local function run_install()
    global.tick = global.tick or 40
    global.players = global.players or {}
    for i in (pairs(game.players)) do
        global.players[i] = global.players[i] or {
            snap = true,
            player_ticks = 0,
            last_orientation = 0
        }
    end
end

script.on_init(run_install)
script.on_configuration_changed(run_install)

-- Any time a new player is created run this.
script.on_event(defines.events.on_player_created, function(event)
        global.players[event.player_index] = {
            -- snap, player_ticks, last_orientation = true, 0, 0
            snap = true,
            player_ticks = 0,
            last_orientation = 0
        }
    end
)

script.on_event(defines.events.on_tick,
    function()
        global.tick = global.tick - 1
        if global.tick <= 0 then
            -- If no-one is in vehicles, take longer delay to do this whole check
            global.tick = 40
            for _, player in pairs(game.connected_players) do
                local pdata = global.players[player.index]
                if pdata.snap and player.vehicle then
                    local v = player.vehicle.type
                    if v == "car" or v == "tank" then
                        global.tick = 2
                        if player.vehicle.speed > 0.1 then
                            local o = player.vehicle.orientation
                            if math.abs(o - pdata.last_orientation) < 0.001 then
                                if pdata.player_ticks > 1 then
                                    local snap_o = math.floor(o * vehiclesnap_amount + 0.5) / vehiclesnap_amount
                                    -- Interpolate with 80% current and 20% target orientation
                                    o = (o * 4.0 + snap_o) * 0.2
                                    player.vehicle.orientation = o
                                else
                                    pdata.player_ticks = pdata.player_ticks + 1
                                end
                            else
                                pdata.player_ticks = 0
                            end
                            pdata.last_orientation = o;
                        end
                    end
                end
            end
        end
    end
)