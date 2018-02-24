require("stdlib/table")
require("stdlib/string")

-- constants
local version = 000401 -- 0.4.1
local turret_y_offset = 0.1
local programmable_identifier = "programmable"
local composite_suffix = "-_-" -- used to filter out sub-units (i.e. "-" would break most units)

local starting_items = {{name = "unit-remote-control", count = 1}}
local unit_target_search_interval = 60
local hauler_transfer_interval = 60
local hauler_transfer_range = 6
local warden_transfer_range = 25
local depot_transfer_interval = 60
local depot_transfer_range = 7
local vehicle_acceleration_multiplier = math.sqrt(10/3)/600 -- 0.003042903097
local navigator_minimum_range = 4.5
local move_to_acceptable_range = 0.1
local construction_denial_range = 50 -- bobs sniper turret is 35
local default_follow_distance = 5
local follow_max_selection_box = 4

local util = require("util") -- keep seperate for sharing

-- locals
local min = util.min
local transfer_burner = util.transfer_burner
local transfer_inventory = util.transfer_inventory
local transfer_inventory_filters = util.transfer_inventory_filters
local transfer_equipment_grid = util.transfer_equipment_grid
local array_to_vector = util.array_to_vector
local vectors_delta = util.vectors_delta
local vector_length = util.vector_length
local orientation_from_to = util.orientation_from_to
local orientation_to_vector = util.orientation_to_vector
local vectors_add = util.vectors_add
local move_to = util.move_to
local vector_to_orientation_xy = util.vector_to_orientation_xy
local signal_to_string = util.signal_to_string
local signal_container_add = util.signal_container_add
local string_to_number = util.string_to_number

local high_fuel_item = "rocket-fuel"
--Consume fuel from a list of fuels generated on init and changed
local fuel, trunk = defines.inventory.fuel, defines.inventory.car_trunk
local inv_nums = {fuel, trunk}

local vehicle_deployer_type = {
    name = "vehicle-deployer",
    struct_main = "vehicle-deployer",
    struct_overlay = "vehicle-deployer-overlay",
    struct_belt = "vehicle-deployer-belt",
    struct_reserved = "vehicle-deployer-reserved",
    struct_combinator = "vehicle-deployer-combinator",
    deploy_start_offset = 0,
    deploy_end_offset = 6,
    deploy_time = 3 * 60, -- 2 seconds
    deployer_overlay_offset = 3.9,
    deployer_chest_offset = 0,
    deployer_belt_offset = -2,
    deployer_combinator_offset = {x = 3.7, y = 4.3},
}

--[[
TODO:
Add unit waypoint system.

Add buttons to remote controller:

Stop. Selected units stop.
Single Commands. Replace current commands.
Queue Commands. Follow commands in sequence.
Loop Commands. Follow commands in sequence then loop.
Commands are added to temporary Order Set.

Unit controller ability to set Order Set.
Order Set has a number: Order Set 0.
Order Sets have a set of commands that are performed in sequence
Order Sets loop by default, if loop is disabled then the unit stays on the final command
If a different command is activated then the unit goas back to an order set the unit restarts the order set from the beginning.
  i.e. they don't remember where there were in the set if the sequence is broken.

Additional signals required:
  Order Set Signal
  Set Command Signal
  Order Set Commands Signal
  Loop signal: loop the Order Set: positive = forwards, negative = backwards
  Stop Signal: Do not loop the Order Set: Stop at the end of the loop. Also use on a unit to stop.

Waypoint beacons:
A structure (constant combinator) with a waypoint beacon id and xy coordinates.
When placed a waypoint beacon is given an id based on an incrementing sequence.
You can change a waypoint beacon's id.
If multiple beacons have the same id the once placed first functions.
You can specify waypoint beacons in vehicle and order set commands, the vehicle moves to the waypoint position.

]]--

--[[
CUSTOM EVENTS SENT

on_entity_replaced
raise_event implementation: raise_event('on_entity_revived', {new_entity = LuaEntity, new_entity_unit_number = uint, old_entity = LuaEntity?, old_entity_unit_number = uint})
on_event implementation: remote.add_interface("mymod", { on_entity_replaced = function(data) return myfunction(data.new_entity, data.new_entity_unit_number, ...) end})

on_entity_deployed
raise_event implementation: raise_event('on_entity_deployed', {entity = LuaEntity, signals = {signaltype={signalname={signal="", count=#}}}})
on_event implementation: remote.add_interface("mymod", { on_entity_deployed = function(data) return myfunction(data.entity, data.signals) end})

on_unit_given_order
raise_event implementation: raise_event('on_unit_given_order', {unit = AAIUnit table, order=AAIOrder table})
on_event implementation: remote.add_interface("mymod", { on_unit_given_order = function(data) return myfunction(data.unit, data.order) end})

on_unit_change_state
raise_event implementation: raise_event('on_unit_change_mode', {unit = AAIUnit table, new_mode=String, old_mode=String})
on_event implementation: remote.add_interface("mymod", { on_unit_change_mode = function(data) return myfunction(data.unit, data.new_mode, data.old_mode) end})

Data Alter hooks

hauler_types implementation: remote.add_interface("mymod", { hauler_types = function(data) return {'hauler-entity-name-1', 'hauler-entity-name-2', ...} end})

]]--

local function raise_event(event_name, event_data)
    local responses = {}
    for interface_name, interface_functions in pairs(remote.interfaces) do
        if interface_functions[event_name] then
            responses[interface_name] = remote.call(interface_name, event_name, event_data)
        end
    end
    return responses
end

local get_fuel = {
    --Build a table of fuel items, index as fuel name, value as table with name, fuel_value
    build = function()
        return table.map(game.item_prototypes,
            function(item, name)
                local fuel_item = {}
                if item.fuel_value and item.fuel_value > 0 then
                    fuel_item.fuel_value = item.fuel_value
                    fuel_item.name = name
                end
                --Return: index as item_name, value as fuel_value
                return fuel_item.name and fuel_item or nil
            end
        )
    end,

    --Return a fuel item table if a fuel item is in the contents.
    item = function(contents)
        local fuel_items = global.fuel_items
        for name in pairs(contents) do
            if fuel_items[name] then
                return fuel_items[name]
            end
        end
    end
}

-- control-unit-unit_type

local function unit_template()
    return {
        unit_id = 0, -- Uint, static
        unit_type = "type-name", -- String
        unit_type_id = 0, -- index within unit_type array, dynamic
        mode = "passive", -- String: drive, vehicle, unit
        vehicle_whole = nil, -- Entity
        vehicle_solid = nil, -- Entity
        vehicle_ghost = nil, -- Entity
        navigator = nil, -- Entity (Unit)
        driver = nil, -- Entity (Player)
        position_last = nil, -- Position
        position = nil, -- Position
        speed = 0, -- Float
        health = 0, -- Float
        -- internal energy stored after consuming a unit of fuel or being charged. burn from fuel can exceed capacity.
        -- use vehicles actual energy as a buffer. try to prevent the actual vehicle from consuming fuel
        weapon = nil, -- see unit_load_ammo()
        -- a loaded packaged weapon with ammo type, attacks stats, multipliers, rounds left, etc.
        -- updated on fire and loading new ammo
        data = {}, -- counts for various types of signal data stores as [type][name] = {signal = signal, count = count}
        -- use signal_container_add and signal_container_get
        -- should be the same format as structure inputs and outputs
        target_angle = nil, -- Float
        target_speed = 0, -- Float
        target_position = nil, -- Position (as ints for tile) -- used for move_to, prevents constant commands to same tile
        attack_target = nil, -- Entity
        attack_last_tick = 0, -- Uint
        target_last_tick = 0, -- Uint
        order_last_tick = 0, -- Uint
        move_last_tick = 0, -- Uint
        move_to_last_tick = 0, -- Uint
        active_state = "auto_active", -- "active", "inactive", "auto_active", "auto_inactive"
        stunned_until = nil,
    }
end

local function unit_type_tree_damage(vehiclePrototype)
    local damage_multiplier = 0.5 -- / vehiclePrototype.energy_per_hit_point
    local weight = vehiclePrototype.weight
    if string.find(vehiclePrototype.name, "tank", 1, true) then
        damage_multiplier = 2
    end
    if string.find(vehiclePrototype.name, "tumbler", 1, true) then
        damage_multiplier = 50
        weight = weight + 1000
    end
    local tree_damage = math.max(0.25, weight * damage_multiplier / 200)
    return tree_damage
end

local function unit_setup_vehicle(vp) -- vehicle prototype
    -- not data-raw consumtion of 180k is prototype.consumtion of 3000
    local unit_type = {
        name = vp.name,
        vehicle_whole = vp.name,
        vehicle_whole_prototype = vp,
        vehicle_solid = vp.name .. composite_suffix .. "solid",
        vehicle_ghost = vp.name .. composite_suffix .. "ghost",
        navigator = vp.name .. composite_suffix .. "navigator",
        driver = vp.name .. composite_suffix .. "driver",
        buffer = vp.name .. composite_suffix .. "buffer",
        signal = {type = "virtual", name = vp.name .. composite_suffix .. "signal"},
        effectivity = vp.effectivity or 1,
        acceleration = math.sqrt(vp.consumption * 60 * vp.effectivity / vp.weight) * vehicle_acceleration_multiplier, -- boost vehicle speed a bit
        friction = vp.friction_force, --friction = vehicle.friction,
        weight = vp.weight,
        -- TODO: energy_per_hit_point = vehicle.energy_per_hit_point or 1, -- not ready yet
        tree_damage = unit_type_tree_damage(vp),
        rotation_speed = vp.rotation_speed,
        collides_with_ground = false, -- is_boat
        is_flying = false,
        is_hauler = false,
        is_miner = false,
        radius = math.max(
          -vp.collision_box.left_top.x,
          -vp.collision_box.left_top.y,
          vp.collision_box.right_bottom.x,
          vp.collision_box.right_bottom.y),
        ai_driving_modifier = 1,
    }

    if vp.name == "vehicle-chaingunner" then
      unit_type.ai_driving_modifier = 1.25
      unit_type.acceleration = unit_type.acceleration * 1.25
    end
    if vp.name == "vehicle-warden" then
      unit_type.ai_driving_modifier = 0.8
      unit_type.acceleration = unit_type.acceleration * 0.8
    end

    -- note: effectivity does not affect brake, only consumption
    unit_type.brake = math.max(unit_type.acceleration, math.sqrt(string_to_number(vp.braking_force) / vp.weight) * vehicle_acceleration_multiplier)
    unit_type.brake = math.max(120000, unit_type.brake)

    if vp.collision_mask then
        local is_flying = true
        for _, layer in pairs(vp.collision_mask) do
            if layer == 'ground-tile' then
                unit_type.collides_with_ground = true
            end
            if layer ~= 'ghost-layer' then
                is_flying = false
            end
        end
        if is_flying then
            unit_type.is_flying = true
        end
    end
    if not (vp.tank_driving and vp.tank_driving == true) then
        unit_type.rotation_speed = unit_type.rotation_speed / 2
    end

    -- prompt any required ammo categories for inflation
    if vp.guns then
      for _, gun in pairs(vp.guns) do
        unit_type.gun = gun
        break
      end
    end

    if global.hauler_types[vp.name] then
        unit_type.is_hauler = true
        --send_message(vehicle.name .. " is hauler")
    end

    if string.find(unit_type.name, "vehicle-miner", 1, true) then
        unit_type.is_miner = true
    end

    global.unit_types[unit_type.name] = unit_type
    global.unit_types_by_signal[signal_to_string(unit_type.signal)] = unit_type
end

local function unit_is_active(unit)
  if unit.active_state == "inactive" or unit.active_state == "auto_inactive" then
    return false
  elseif unit.active_state == "active" or unit.active_state == "auto_active" then
    return true
  else
    unit.active_state = "auto_active"
    return true
  end
end

local function unit_set_active_state_auto(unit)
  if unit and unit.vehicle and unit.vehicle.get_driver() and unit.vehicle.get_driver().player then
    unit.active_state = "auto_inactive"
  else
    unit.active_state = "auto_active"
  end
end

local function unit_load_prototypes()

    -- prototypes are loadable, clear old data
    global.unit_types = {}
    global.unit_types_by_signal = {}
    global.unit_mineable_resources = {}
    global.hauler_types = {}
    global.hauler_types["vehicle-hauler"] = "vehicle-hauler"
    global.hauler_types["vehicle-warden"] = "vehicle-warden"
    global.hauler_types["cargo-plane"] = "cargo-plane"

    for _, response_types in pairs(raise_event('hauler_types', nil)) do
        for _, response_type in pairs(response_types) do
            global.hauler_types[response_type] = response_type
        end
    end

    for _, prototype in pairs(game.entity_prototypes) do
        -- only cars, exclude attachments, exclude non-programmable
        if prototype.type == "car" and not string.find(prototype.name, composite_suffix, 1, true)
          and prototype.order and string.find(prototype.order, programmable_identifier, 1, true) then
            unit_setup_vehicle(prototype)
        end

        if prototype.type == "resource" and prototype.mineable_properties and prototype.mineable_properties.products then
          for _, product in pairs(prototype.mineable_properties.products) do
            if product.type == "item" then
                global.unit_mineable_resources[product.name] = product.name
            end
          end
        end
    end

end

local function unit_get_type(unit)
    return global.unit_types[unit.unit_type]
end

local function unit_get_energy(unit)
    if unit.vehicle and unit.vehicle.valid and unit.vehicle.burner then
      return unit.vehicle.burner.remaining_burning_fuel
    end
    return 0
end

local function unit_on_destroy_entity(entity)
    if entity.valid and entity.unit_number then
        global.unit.unit_numbers[entity.unit_number] = nil
    end
end

local function destroy_entity(entity)
    if entity.valid then
        unit_on_destroy_entity(entity)
        entity.destroy()
    end
    return nil
end

local function unit_find_from_entity(entity)
    local unit_id = global.unit.unit_numbers[entity.unit_number]
    if unit_id then
        return global.unit.units[unit_id]
    end
    return nil
end

local function unit_by_type_and_index(unit_type, index)
    if global.unit.unit_types[unit_type] and #global.unit.unit_types[unit_type] > 0 then
        --index = unit_loop_index(unit_type, index)
        if index > 0 and index <= #global.unit.unit_types[unit_type] then
            return global.unit.unit_types[unit_type][index]
        elseif index < 0 and -index <= #global.unit.unit_types[unit_type] then
            return global.unit.unit_types[unit_type][#global.unit.unit_types[unit_type] + index + 1]
        end
    end
end

local function unit_by_unit_id(unit_id)
    return global.unit.units[unit_id]
end

local function unit_by_unit_number(unit_number)
    return global.unit.unit_numbers[unit_number]
end

local function unit_find_from_signal(data)
    --data = {signal = SignalID, count = count} returns unit
    local signal_count = data
    if signal_count and signal_count.signal and signal_count.count then
        if signal_count.signal.name == "signal-id" then
            local unit = unit_by_unit_id(signal_count.count)
            if unit and unit.vehicle and unit.vehicle.valid then
                unit.unit_type_snapshot = unit_get_type(unit)
                return unit
            end
        else
            local unit_type = global.unit_types_by_signal[signal_to_string(signal_count.signal)]
            if unit_type then
                local unit = unit_by_type_and_index(unit_type.name, signal_count.count)
                if unit and unit.vehicle and unit.vehicle.valid then
                    unit.unit_type_snapshot = unit_get_type(unit)
                    return unit
                end
            end
        end
    end
end

local function unit_get_count_by_type(unit_type)
    if global.unit.unit_types[unit_type] then
        return #global.unit.unit_types[unit_type]
    end
end

local function unit_set_data(data)
    local unit_id = data.unit_id
    local signal_data = data.data or {}
    if unit_id and global.unit.units[unit_id] and global.unit.units[unit_id].vehicle
    and global.unit.units[unit_id].vehicle.valid then
        global.unit.units[unit_id].data = signal_data
    end
end

local function unit_check_navigator_stop(unit, target_position, distance_to_target)
    return unit_get_energy(unit) <= 0 or target_position == nil or distance_to_target < navigator_minimum_range or (unit.navigator and unit.navigator.valid and unit.navigator.has_command() == false)
end

local function unit_stuck_time(unit)
  return game.tick - (unit.stuck_last_tick or 0)
end

local function unit_reset_stuck(unit)
  unit.stuck_last_tick = game.tick
end

local function unit_nudge(unit)
    local move_amount = 0.05
    if unit.vehicle and unit.vehicle.valid then
      if unit.navigator and unit.navigator.valid then
        -- removed
      else
        local save_pos_vehicle = unit.vehicle.position
        unit.vehicle.teleport({x = save_pos_vehicle.x, y = save_pos_vehicle.y + 10}) -- move out of the way
        local safe_vehicle = unit.vehicle.surface.find_non_colliding_position(unit_get_type(unit).buffer, save_pos_vehicle, 3, 0.1)
        if safe_vehicle then
            unit.vehicle.teleport(move_to(save_pos_vehicle, safe_vehicle, move_amount))
        else
            unit.vehicle.teleport(save_pos_vehicle)
        end
      end
    end
    unit.safe_target_position = nil
end

-- can now use driver.riding_state, but this might be better for small changes
local function unit_rotate_to_angle(target, angle, rotation_speed, turn_slows)
    if not rotation_speed then return end
    local da = angle - target.orientation
    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    da = util.max(util.min(da, rotation_speed), - rotation_speed)
    target.orientation = target.orientation + da
    if(turn_slows) then
        target.speed = target.speed * (1 - util.abs(da)*5)
    end
end

--[[
local function unit_delta_angle(angle, target_angle)
    local da = target_angle - angle
    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    return da
end
--]]

local function unit_delta_angle_abs(angle, target_angle)
    local da = target_angle - angle
    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    return util.abs(da)
end

local function unit_rotate_to_target_angle(unit)
    if unit.target_angle ~= nil then
        local da = unit.target_angle - unit.vehicle.orientation
        if da < -0.5 then
            da = da + 1
        elseif da > 0.5 then
            da = da - 1
        end
        da = math.max(math.min(da, unit_get_type(unit).rotation_speed), - unit_get_type(unit).rotation_speed)
        unit.vehicle.orientation = unit.vehicle.orientation + da
        unit.vehicle.speed = unit.vehicle.speed * (1 - math.abs(da)*2)
    end
end

local function unit_force_for_speed(base_force, speed)
    -- forces are reduced at high speed
    return (((speed / base_force)^2+1)^0.5-(speed / base_force)) * base_force
end

-- can now use driver.riding_state
local function unit_speed_to(unit, target_speed)
    -- the new drive method actually controls the vehicle
    local target_speed_change = target_speed - unit.vehicle.speed

    if (unit.vehicle.speed / target_speed) > 0.99 and (unit.vehicle.speed / target_speed) < 1.1 then
      unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.nothing, direction = defines.riding.direction.straight} -- nearly at the right speed so coast
      return
    end

    if target_speed_change > 0 and unit.vehicle.speed < 0 then
        unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.braking, direction = defines.riding.direction.straight}
    elseif target_speed_change > 0 then
        unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.accelerating, direction = defines.riding.direction.straight}
    elseif target_speed_change < 0 and unit.vehicle.speed > 0 then
        unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.braking, direction = defines.riding.direction.straight}
    elseif target_speed_change < 0 then
        unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.reversing, direction = defines.riding.direction.straight}
    else
        unit.vehicle.riding_state = {acceleration = defines.riding.acceleration.braking, direction = defines.riding.direction.straight}
    end
    return
    --[[
     -- the old method calculates the force based on the speed and then modifies the speed
    local unit_type = unit_get_type(unit)
    local force
    if target_speed_change > 0 and unit.vehicle.speed < 0 then
        force = unit_force_for_speed(unit_type.brake, math.abs(unit.vehicle.speed))
        force = math.min(target_speed_change, force, 0.1) -- cap acceleration
        unit.vehicle.speed = unit.vehicle.speed + force
    elseif target_speed_change > 0 then
        force = unit_force_for_speed(unit_type.acceleration, math.abs(unit.vehicle.speed))
        force = math.min(target_speed_change, force, 0.01) -- cap acceleration
        unit.vehicle.speed = unit.vehicle.speed + force
    elseif target_speed_change < 0 and unit.vehicle.speed > 0 then
        force = unit_force_for_speed(unit_type.brake, math.abs(unit.vehicle.speed))
        force = math.min(-target_speed_change, force, 0.1) -- cap acceleration
        force = math.min(-target_speed_change, force, 0.1) -- cap acceleration
        unit.vehicle.speed = unit.vehicle.speed - force
    elseif target_speed_change < 0 then
        force = unit_force_for_speed(unit_type.acceleration, math.abs(unit.vehicle.speed))
        force = math.min(-target_speed_change, force, 0.01) -- cap acceleration
        unit.vehicle.speed = unit.vehicle.speed - force
    end
    ]]--
end

local function unit_speed_to_target_speed(unit)
    if unit.target_speed ~= nil then
        unit_speed_to(unit, unit.target_speed)
    end
end

local function update_unit_type_ids(unit_type)
    for i, unit in ipairs(global.unit.unit_types[unit_type]) do
        unit.unit_type_id = i
    end
end

local function update_unit_types_ids()
    for unit_type_name in pairs(global.unit.unit_types) do
        update_unit_type_ids(unit_type_name)
    end
end

local function unit_manage_new(entity, signals)
    local existing_unit = unit_find_from_entity(entity)
    if existing_unit then return end -- unit already is managed
    for _, unit_type in pairs(global.unit_types) do
        if entity.name == unit_type.vehicle_whole or entity.name == unit_type.vehicle_solid or entity.name == unit_type.vehicle_ghost then
            local unit_id = global.unit.next_unit_id
            global.unit.next_unit_id = global.unit.next_unit_id + 1

            -- make new unit from template
            local unit = unit_template()
            unit.unit_id = unit_id
            unit.unit_type = unit_type.name
            unit.position_last = entity.position
            unit.position = entity.position
            unit.vehicle = entity

            unit.attack_last_tick = game.tick
            unit.target_last_tick = game.tick
            unit.order_last_tick = game.tick
            unit.move_last_tick = game.tick
            unit.move_to_last_tick = game.tick

            local data = unit.data
            if unit_type.is_miner then
                for _, resource in pairs(global.unit_mineable_resources) do
                    if resource ~= "raw-wood" and resource ~= "coal" then
                        signal_container_add(data, {type = "item", name=resource}, -1)
                    end
                end
                signal_container_add(data, {type = "item", name="raw-wood"}, 50)
                signal_container_add(data, {type = "item", name="coal"}, 100)
                signal_container_add(data, {type = "item", name="solid-fuel"}, 50)
            elseif unit.unit_type == "vehicle-warden" then
                signal_container_add(data, {type = "item", name="repair-pack"}, 100)
                signal_container_add(data, {type = "item", name="coal"}, 50)
                signal_container_add(data, {type = "item", name="solid-fuel"}, 50)
                signal_container_add(data, {type = "virtual", name="signal-minimum-fuel"}, 800)
            elseif unit_type.is_hauler then
                for _, resource in pairs(global.unit_mineable_resources) do
                    signal_container_add(data, {type = "item", name=resource}, 12000)
                end
                signal_container_add(data, {type = "item", name="raw-wood"}, 12000)
                signal_container_add(data, {type = "item", name="solid-fuel"}, 12000)
                signal_container_add(data, {type = "virtual", name="signal-minimum-fuel"}, 800)
            else
                signal_container_add(data, {type = "item", name="coal"}, 50)
                signal_container_add(data, {type = "item", name="solid-fuel"}, 50)
            end
            if game.item_prototypes["vehicle-fuel"] then
                signal_container_add(data, {type = "item", name="vehicle-fuel"}, 100)
            end

            -- dynamic ammo
            if unit_type.gun and unit_type.gun.attack_parameters and unit_type.gun.attack_parameters.ammo_category then
                local ammo_category = unit_type.gun.attack_parameters.ammo_category
                for _, item in pairs(game.item_prototypes) do
                    if item.type == "ammo" then
                        local ammo_type = item.get_ammo_type("vehicle")
                        if ammo_type and ammo_type.category == ammo_category then
                            signal_container_add(data, {type = "item", name=item.name}, 50)
                        end
                    end
                end
            end

            if signals then
                local signals_valid = false

                for _, signals_list in pairs(unit.data) do
                    for signal_name in pairs(signals_list) do
                        if signal_name ~= unit_type.name then
                            signals_valid = true
                            break
                        end
                    end
                end
                -- it is at least not nil not empty and no only containing deployer contents
                if signals_valid then
                    unit.data = signals
                end
            end

            global.unit.units[unit_id] = unit
            global.unit.unit_numbers[entity.unit_number] = unit_id
            if not global.unit.unit_types[unit.unit_type] then global.unit.unit_types[unit.unit_type] = {} end
            table.insert(global.unit.unit_types[unit.unit_type], unit)
            update_unit_type_ids(unit.unit_type)
            global.unit.entities_pending_manage[entity.unit_number] = nil
        end
    end
end


local function unit_unmanage(unit)
    if unit then
        if unit.vehicle and unit.vehicle.valid then
            unit_on_destroy_entity(unit.vehicle)
            unit.vehicle.die()
            unit.vehicle = nil
        end
        if unit.navigator then
            unit.navigator = destroy_entity(unit.navigator)
        end
        if unit.turret then
            unit.turret = destroy_entity(unit.turret)
        end
        if unit.attachment then
            unit.attachment = destroy_entity(unit.attachment)
        end
        if unit.driver then
            unit.driver = destroy_entity(unit.driver)
        end
        global.unit.units[unit.unit_id] = nil
        -- remove from unit type index
        local remove_index = 0
        for i, comp_unit in ipairs(global.unit.unit_types[unit.unit_type]) do
            if comp_unit == unit then
                remove_index = i
                break
            end
        end
        if remove_index > 0 then
            table.remove(global.unit.unit_types[unit.unit_type], remove_index)
            update_unit_type_ids(unit.unit_type)
        end
        unit.mode = "removed"
    end
end

local function unit_unmanage_by_entity(entity)
    local unit = unit_find_from_entity(entity)
    unit_unmanage(unit)
end

local function unit_on_entity_died(event)
    unit_unmanage_by_entity(event.entity)
end

local function unit_create_entity(unit, entity_type, surface, position, force)
    local entity = surface.create_entity{name=entity_type, position=position, force=force}
    if unit and entity.unit_number then
        global.unit.unit_numbers[entity.unit_number] = unit.unit_id
    end
    return entity
end

local function unit_create_entity_from_entity(unit, entity_type, source_entity, replace)
    --local source_entity_number = source_entity.unit_number
    local driver
    local passenger
    if source_entity.type == "car" and replace then
      driver = source_entity.get_driver()
      source_entity.set_driver(nil)
      passenger = source_entity.get_passenger()
      source_entity.set_passenger(nil)
      source_entity.active = false
    end
    local entity = unit_create_entity(unit, entity_type, source_entity.surface, source_entity.position, source_entity.force, replace)
    if source_entity.valid then
        entity.orientation = source_entity.orientation
        if replace then
            source_entity.teleport({0,0})
            if driver and driver.valid then entity.set_driver(driver) end
            if passenger and passenger.valid then entity.set_passenger(passenger) end
            entity.health = source_entity.health
            entity.speed = source_entity.speed
            entity.energy = source_entity.energy
            transfer_burner(source_entity, entity)
            transfer_inventory_filters(source_entity, entity, defines.inventory.car_trunk)
            --transfer_inventory(source_entity, entity, defines.inventory.fuel) -- doubls ammo if turret_ammo is also called?
            transfer_inventory(source_entity, entity, defines.inventory.car_trunk)
            transfer_inventory(source_entity, entity, defines.inventory.car_ammo)
            transfer_inventory(source_entity, entity, defines.inventory.turret_ammo)
            transfer_equipment_grid(source_entity, entity)
            raise_event("on_entity_replaced",
                { new_entity = entity,
                    new_entity_unit_number = entity.unit_number,
                    old_entity = source_entity,
                    old_entity_unit_number = source_entity.unit_number})
            destroy_entity(source_entity)
        end
    else
        global.unit.unit_numbers[entity.unit_number] = nil
    end
    return entity
end

local function unit_kill_surrounding_trees(unit)
    local tree_destroyed = false
    if unit.vehicle and unit.vehicle.valid then
        local unit_type = unit_get_type(unit)
        local range = unit_type.radius * 2
        local position = unit.position
        local trees = unit.vehicle.surface.find_entities_filtered{
            type="tree",
            area={{
                    x = position.x - range,
                    y = position.y - range},{
                    x = position.x + range,
                    y = position.y + range}},
        }
        for _, tree in pairs(trees) do
            if tree.health < 1000 then
                tree.die()
                tree_destroyed = true
            end
        end
    end
    return tree_destroyed
end

local function unit_update_mode(unit)
    --[[
    mode:
    passive = idle (can coast or be driven by player, when player is in manual mode), no ai 'driver' when not active_state
    vehicle = AI Direct Drive, optional direction, optional speed. Used for parking (speed = 0), has ai 'driver'
    vehicle_move_to = AI Direct Drive but to s specific location, has ai 'driver'
    vehicle_move_to_temp = vehicle_move_to but on a timer before attempting to switch to "unit", has ai 'driver'
    unit = guided by the navigator unit (biter pathfinding), has ai 'driver'

    stunned_until = if not inactive or drive: acts under vehicle mode (speed = 0) and has ai 'driver'
    ]]--


    -- this will complete any mode changes, it will not update things like last position
    local unit_type = unit_get_type(unit)
    if not (unit.vehicle and unit.vehicle.valid) then -- cannot return from loss of vehicle
        unit_unmanage(unit)
        return
    end
    if (unit_type.collides_with_ground or unit_type.is_flying) and (unit.mode == "unit" or unit.mode == "vehicle_move_to_temp") then
        unit.mode = "vehicle_move_to" -- navigator won't work in water
        unit.stuck = 0
        unit_reset_stuck(unit)
    end

    if unit.active_state == "auto_inactive" then
      if unit.vehicle.get_driver() == nil and unit.vehicle.get_passenger() == nil then
        unit.active_state = "auto_active"
      end
    end
    if unit_is_active(unit) == false then
        unit.mode = "passive"
    end

    if unit.mode == "passive" then
        if unit.vehicle.name ~= unit_type.vehicle_whole then
            unit.vehicle = unit_create_entity_from_entity(unit, unit_type.vehicle_whole, unit.vehicle, true)
        end
        if unit.navigator then
            unit.navigator = destroy_entity(unit.navigator)
        end
        if unit_is_active(unit) == false then
          if unit.driver then
              unit.driver = destroy_entity(unit.driver)
              if unit.vehicle.get_passenger() then
                 unit.vehicle.set_driver(unit.vehicle.get_passenger())
              end
          end
        else
          if not (unit.driver and unit.driver.valid) then
              unit.driver = unit_create_entity_from_entity(unit, unit_type.driver, unit.vehicle, false )
              if unit.vehicle.get_driver() then unit.vehicle.set_passenger(unit.vehicle.get_driver()) end
              unit.vehicle.set_driver(unit.driver)
          end
        end
        if unit.turret then
            unit.turret = destroy_entity(unit.turret)
        end
    elseif unit.mode == "vehicle" or unit.mode == "vehicle_move_to" or unit.mode == "vehicle_move_to_temp" then
        if unit.vehicle.name ~= unit_type.vehicle_solid then
            unit.vehicle = unit_create_entity_from_entity(unit, unit_type.vehicle_solid, unit.vehicle, true)
        end
        if unit.navigator then
            unit.navigator = destroy_entity(unit.navigator)
        end
        if not (unit.driver and unit.driver.valid) then
            unit.driver = unit_create_entity_from_entity(unit, unit_type.driver, unit.vehicle, false )
            if unit.vehicle.get_driver() then unit.vehicle.set_passenger(unit.vehicle.get_driver()) end
            unit.vehicle.set_driver(unit.driver)
        end
    elseif unit.mode == "unit" then
        local vehicle_type = unit_type.vehicle_ghost
        --[[local vehicle_type = unit_type.vehicle_solid
        -- only use the ghost when it would overlap the navigator
        if (not unit.navpath)
          or (unit.navpath and unit.navpath.path_complete == false and (not unit.navigator))
          or (unit.navigator and unit.navigator.valid and util.vectors_delta_length(unit.vehicle.position, unit.navigator.position) < 4) then
            vehicle_type = unit_type.vehicle_ghost
        end]]--
        if unit.vehicle.name ~= vehicle_type then
            unit.vehicle = unit_create_entity_from_entity(unit, vehicle_type, unit.vehicle, true)
        end
        if not (unit.driver and unit.driver.valid) then
            unit.driver = unit_create_entity_from_entity(unit, unit_type.driver, unit.vehicle, false )
            if unit.vehicle.get_driver() then unit.vehicle.set_passenger(unit.vehicle.get_driver()) end
            unit.vehicle.set_driver(unit.driver)
        end
    end
end

local function unit_set_mode(unit, new_mode)
  if new_mode == "unit" and unit_get_energy(unit) <= 0 then
    new_mode = "vehicle_move_to_temp"
  end
  if unit.mode ~= new_mode then
    local old_mode = unit.mode
    unit.mode = new_mode
    unit_update_mode(unit)
    raise_event('on_unit_change_mode', {unit = unit, new_mode=new_mode, old_mode=old_mode})
  end
end

local function unit_set_target_position(unit, position, mode)
  if mode == true then mode = "move_to" end
    --game.print("unit_set_target_position " .. unit.unit_type .. " to x " .. position.x .. " y " .. position.y .. mode)
    unit.follow_target = nil
    unit.target_angle = nil
    unit.target_speed = 0

    local unit_type = unit_get_type(unit)
    if mode == "move_to" or unit_type.is_flying then
        unit.target_position = position
        unit.safe_target_position = position
        unit.stuck = 0
        unit_reset_stuck(unit)
        unit_set_mode(unit, "vehicle_move_to")
        game.print("direct")
    elseif unit.target_position == nil
        or math.floor(unit.target_position.x) ~= math.floor(position.x)
        or math.floor(unit.target_position.y) ~= math.floor(position.y) then
        local distance = util.vectors_delta_length(unit.vehicle.position, position)
        if distance > navigator_minimum_range then
            unit.target_position = position
            unit.safe_target_position = position
            unit.navpath = nil
            unit.stuck = 0
            unit_reset_stuck(unit)
            unit_set_mode(unit, "unit")
        else
            unit.target_position = position
            unit.safe_target_position = position
            unit.stuck = 0
            unit_reset_stuck(unit)
            unit_set_mode(unit, "vehicle_move_to_temp")
        end
    else
        -- will not affect pathfinding, just update subtile change if any
        unit.target_position = position
    end
end

local function consume_fuel_or_equipment (unit)

    if unit.vehicle.grid and unit.vehicle.grid.available_in_batteries > 10000 then
        --Added by Undarl; basic battery fueling logic courtesy of Sirenfal
        ---Modified by the Nexela
        unit.vehicle.burner.currently_burning = high_fuel_item
        local energy_deficit = game.item_prototypes[high_fuel_item].fuel_value - unit.vehicle.burner.remaining_burning_fuel
        local batteries = table.filter(unit.vehicle.grid.equipment, function(v) return v.type == "battery-equipment" end)
        local num_batteries = #batteries
        while num_batteries > 0 and energy_deficit > 0 do
            local battery = batteries[num_batteries]
            local energy_used = math.min(battery.energy, energy_deficit)
            battery.energy = battery.energy - energy_used
            unit.vehicle.burner.remaining_burning_fuel = unit.vehicle.burner.remaining_burning_fuel + energy_used
            energy_deficit = energy_deficit - energy_used
            num_batteries = num_batteries - 1
        end
    else
        for _, inv_num in pairs(inv_nums) do
            local inventory = unit.vehicle.get_inventory(inv_num)
            if inventory then
                local contents = inventory.get_contents()
                local fuel_item = get_fuel.item(contents)
                if fuel_item then
                    if inv_num ~= defines.inventory.fuel then
                      if contents[fuel_item.name] > 1 then
                        -- move fuel to fuel inventory
                        unit.vehicle.burner.currently_burning = fuel_item.name
                        unit.vehicle.burner.remaining_burning_fuel = unit.vehicle.burner.remaining_burning_fuel + fuel_item.fuel_value
                        local fuel_inv = unit.vehicle.get_inventory(defines.inventory.fuel)
                        local inserted = fuel_inv.insert{name = fuel_item.name, count = contents[fuel_item.name] -1}
                        if inserted > 0 then
                          inventory.remove({name = fuel_item.name, count = inserted})
                        end
                      else
                        unit.vehicle.burner.currently_burning = fuel_item.name
                        unit.vehicle.burner.remaining_burning_fuel = unit.vehicle.burner.remaining_burning_fuel + fuel_item.fuel_value
                        inventory.remove({name=fuel_item.name, count=1})
                      end
                    else
                      -- burning from correct slot
                      unit.vehicle.burner.currently_burning = fuel_item.name
                      unit.vehicle.burner.remaining_burning_fuel = unit.vehicle.burner.remaining_burning_fuel + fuel_item.fuel_value
                      inventory.remove({name=fuel_item.name, count=1})
                      return true
                    end
                end
            end
        end
    end

end

--[[
replaced with on_entity_damaged
local function unit_on_damage_taken(unit)
    if unit.vehicle and unit.vehicle.valid then
      if unit.mode == "unit" then
        unit.navpath = nil -- drop navpath if crashing
      else
        local tree_destroyed = unit_kill_surrounding_trees(unit)
        unit_nudge(unit)
        -- reduce tree slow caused by reduced weight
        if tree_destroyed and unit.vehicle_velocity_last ~= nil and unit.vehicle.speed < unit.vehicle_velocity_last then
            unit.vehicle.speed = unit.vehicle.speed * 0.25 + unit.vehicle_velocity_last * 0.75
        else
          -- not a tree
          local unit_type = unit_get_type(unit)
          if (not (unit_type.is_flying or unit_type.collides_with_ground))
          and (unit.mode == "vehicle_move_to" or unit.mode == "vehicle_move_to_temp")
          and (unit.safe_target_position or unit.target_position)
          and util.vectors_delta_length((unit.safe_target_position or unit.target_position), unit.vehicle.position) > navigator_minimum_range then
              -- we may have crashed so direct might not be working
              -- go with pathfinder if possible
              unit.stuck = 0
              unit_reset_stuck(unit)
              unit_set_mode(unit, "unit")
          end
        end
      end
    end
end
]]--

--control-unit-combat
local function unit_load_ammo (unit) -- return true for has ammo
    local inv_ammo = unit.vehicle.get_inventory(defines.inventory.car_ammo)
    if inv_ammo.is_empty() then
      -- ammo is empty, try to add from inventory
      local inv_trunk = unit.vehicle.get_inventory(defines.inventory.car_trunk)
      if inv_trunk then
        for item_name, count in pairs(inv_trunk.get_contents()) do
          local stack = {name = item_name, count=count}
          if inv_ammo.can_insert(stack) then
            local inserted = inv_ammo.insert(stack)
            inv_trunk.remove({name=item_name, count=1})
            -- have inserted items so exit
            return true
          end
        end
      end
      return false
    end
    return true
end

local function unit_has_ammo (unit)
  return not unit.vehicle.get_inventory(defines.inventory.car_ammo).is_empty()
end

local function unit_fire(unit)
    unit.driver.shooting_state = {state = defines.shooting.shooting_enemies, position = unit.attack_target.position}
end

local function unit_update_gun(unit)
    local unit_type = unit_get_type(unit)
    if (not unit_type.gun) or (not unit.driver) then return end -- no weapon
     -- handles already loaded state
    if unit_load_ammo(unit) then
      if (not (unit.attack_target and unit.attack_target.valid))
        or util.vectors_delta_length(unit.vehicle.position, unit.attack_target.position) > unit_type.gun.attack_parameters.range then
          unit.attack_target = nil -- invalid or out of range target
      end
      if (not unit.attack_target) and (game.tick + unit.unit_id % unit_target_search_interval) then
          unit.attack_target = unit.vehicle.surface.find_nearest_enemy{
            position = unit.vehicle.position,
            max_distance = unit_type.gun.attack_parameters.range,
            force = unit.vehicle.force}
      end
      if unit.attack_target and unit.attack_target.valid then
          unit.target_last_tick = game.tick -- we have a valid target
          unit_fire(unit)
        else
          unit.driver.shooting_state = {state = defines.shooting.not_shooting}
      end
    end
end

local function inventories_total_fuel(inventories)
    local fuel = 0
    for _, inv in pairs(inventories) do
        local contents = inv.get_contents()
        for name, count in pairs(contents) do
            if global.fuel_items[name] then
                fuel = fuel + count * global.fuel_items[name].fuel_value
            end
        end
    end
    return fuel
end

local function count_inventories_items(inventories, item_name)
    local count = 0
    for _, inv in pairs(inventories) do
        count = count + inv.get_item_count(item_name)
    end
    return count
end

local function inventories_remove_items(inventories, item_Stack)
  --{name=item_name, count=inserted_count}
  for _, inv in pairs(inventories) do
    local removed = inv.remove(item_Stack)
    item_Stack.count = item_Stack.count - removed
    if item_Stack.count <= 0 then return end
  end
end

local function exchange_inventory(data)
    --[[
    data = {
        a = {
            entity = LuaEntity,
            data = signal_container.item,
            min_fuel_value = 0,
            is_hauler = bool
        },
        b = {
            entity = LuaEntity,
            data = signal_container.item,
            min_fuel_value = 0,
            is_hauler = bool
        }
    }
    --]]
    local response = {
        did_transfer = false,
        transfers = {}
    }
    if not (data.a and data.a.entity
        and data.b and data.b.entity and data.b.data and data.b.data.item ) then return response end
    local inv_a = {}
    local inv_b = {}
    local inventories = { -- by removal priority
      defines.inventory.burnt_result,
      defines.inventory.chest,
      defines.inventory.car_trunk,
      defines.inventory.car_ammo,
      defines.inventory.fuel}
    for _, inv_name in pairs(inventories) do
      --if inv_name ~= defines.inventory.fuel or not (data.a.is_hauler == true) then
        local inv = data.a.entity.get_inventory(inv_name)
        if inv then inv_a[inv_name] = inv end
      --end
      --if inv_name ~= defines.inventory.fuel or not (data.b.is_hauler == true) then
        local inv = data.b.entity.get_inventory(inv_name)
        if inv then inv_b[inv_name] = inv end
      --end
    end
    local itemdata_a = {}
    local itemdata_b = {}
    if data.a.data and data.a.data.item then itemdata_a = data.a.data.item end
    if data.b.data and data.b.data.item then itemdata_b = data.b.data.item end

    local entity_a_total_fuel, entity_b_total_fuel

    for signal_name, _ in pairs(itemdata_b) do
        local item_name = signal_name

        local a_accepts = itemdata_a[item_name] and itemdata_a[item_name].count or 0
        local b_target = itemdata_b[item_name].count

        local a_items = count_inventories_items(inv_a, item_name)
        local b_items = count_inventories_items(inv_b, item_name)

        --send_message("unit a (" .. unit.unit_id .. ") accepts "..a_accepts.." has " .. a_items .. " to unit b (" .. other_unit.unit_id .. ") targets "..b_target.." has " .. b_items)

        local transfer_b_a = b_items - b_target
        -- negative is b asking for items
        -- positive is b pushing items (always positive if other_signal_count.count is negative)

        if data.b.is_hauler and transfer_b_a < 0 then
            -- hauler signal represents capacity, not target
            -- only transfer from other to self
            transfer_b_a = 0
        end

        transfer_b_a = math.min(transfer_b_a, b_items) -- can't push more than B has
        transfer_b_a = math.min(transfer_b_a, math.max(0, a_accepts - a_items)) -- can't push more than a will accept
        transfer_b_a = math.max(transfer_b_a, -a_items) -- can't pull more than A has

        if global.fuel_items[item_name] then
            -- this item has fuel value
            local item_fuel_value = global.fuel_items[item_name].fuel_value
            if transfer_b_a > 0 then
              -- b is pushing
              if data.b.data.virtual and data.b.data.virtual["signal-minimum-fuel"]
                and data.b.data.virtual["signal-minimum-fuel"].count and data.b.data.virtual["signal-minimum-fuel"].count > 0 then
                  local min_fuel_value = data.b.data.virtual["signal-minimum-fuel"].count * 1000000
                  entity_b_total_fuel = inventories_total_fuel(inv_b)
                  local max_can_export = math.max(0, math.floor((entity_b_total_fuel - min_fuel_value) / item_fuel_value))
                  transfer_b_a = math.min(transfer_b_a, max_can_export)
              end
            elseif transfer_b_a < 0 then
              -- a is pushing
              if data.a.data.virtual and data.a.data.virtual["signal-minimum-fuel"]
                and data.a.data.virtual["signal-minimum-fuel"].count and data.a.data.virtual["signal-minimum-fuel"].count > 0 then
                local min_fuel_value = data.a.data.virtual["signal-minimum-fuel"].count * 1000000
                entity_a_total_fuel = inventories_total_fuel(inv_a)
                local max_can_export = math.max(0, math.floor((entity_a_total_fuel - min_fuel_value) / item_fuel_value))
                transfer_b_a = math.max(transfer_b_a, -max_can_export)
              end
            end
        end

        local pusher, pusher_inv, puller --, puller_indv

        local items_to_transfer = transfer_b_a
        local direction = 1
        if transfer_b_a > 0 then
            puller = data.a.entity
            --puller_inv = data.a.inventory
            pusher = data.b.entity
            pusher_inv = inv_b
        elseif transfer_b_a < 0 then
            items_to_transfer = -transfer_b_a
            direction = -1
            puller = data.b.entity
            --puller_inv = data.b.inventory
            pusher = data.a.entity
            pusher_inv = inv_a
        end


        if pusher and puller and items_to_transfer > 0 then
            local inserted_count = puller.insert({name=item_name, count=items_to_transfer})
            -- insert to entity not directly to inventory
            -- puts fuel and ammo in the right place.
            if inserted_count > 0 then
                inventories_remove_items(pusher_inv, {name=item_name, count=inserted_count})
                response.did_transfer = true
                response.transfers[item_name] = {name=item_name, count=inserted_count * direction}
                local projectile_name = item_name .. composite_suffix .. "projectile"
                if not game.entity_prototypes[projectile_name] then
                    projectile_name = "default-item-projectile"
                end
                pusher.surface.create_entity{
                    name = projectile_name,
                    position = pusher.position,
                    target = puller,
                    speed = math.random() * 0.2
                }
            end
        end
    end
    return response
end

local function unit_vehicle_exchange_inventory(unit)
    if (game.tick + unit.unit_id) % hauler_transfer_interval == 0 then
        -- once per second
        if not (unit.data and unit.data.item) then return end

        local unit_type = unit_get_type(unit)
        local transfer_range = unit_type.name == "vehicle-warden" and warden_transfer_range or hauler_transfer_range

        local test_vehicles = unit.vehicle.surface.find_entities_filtered{
            type="car",
            area={
              {
                x=unit.vehicle.position.x - transfer_range,
                y=unit.vehicle.position.y - transfer_range
              },{
                  x=unit.vehicle.position.x + transfer_range,
                  y=unit.vehicle.position.y + transfer_range
              }
            },
            force=unit.vehicle.force
        }

        local other_units = {}
        for _, test_vehicle in pairs(test_vehicles) do
            local other_unit = unit_find_from_entity(test_vehicle)
            if other_unit and other_unit.unit_id ~= unit.unit_id then
                other_units[other_unit.unit_id] = other_unit
            end
        end

        for _, other_unit in pairs(other_units) do
            if other_unit.vehicle.valid and other_unit.data and other_unit.data.item then

                local unit_type_a = unit_get_type(unit)
                local unit_type_b = unit_get_type(other_unit)
                exchange_inventory({
                        a = {
                            entity = unit.vehicle,
                            inventory = inv_a,
                            data = unit.data or {},
                            is_hauler = unit_type_a.is_hauler
                        },
                        b = {
                            entity = other_unit.vehicle,
                            data = other_unit.data or {},
                            is_hauler = unit_type_b.is_hauler
                        },
                    })

            end
        end

    end
end

local function path_indicator_clear(unit)
  if not unit.path_indicator then return end
  local path_indicator = unit.path_indicator
  for _, line in pairs(path_indicator.lines) do
    line.destroy()
  end
  for _, waypoint in pairs(path_indicator.waypoints) do
    waypoint.destroy()
  end
  if path_indicator.final then
    path_indicator.final.destroy()  path_indicator.final = nil
  end
  unit.path_indicator = nil
  return
end

local function path_indicator_template_navpath(navpath)
  return {
    waypoints = {},
    lines = {},
    path_start_x = navpath.path[1].x,
    path_start_y = navpath.path[1].y,
    path_target_x = navpath.target_position.x,
    path_target_y = navpath.target_position.y,
  }
end

local function path_indicator_template_direct()
  return {
    waypoints = {},
    lines = {},
    direct = true
  }
end

local function path_indicator_draw_direct(unit)
  if unit.show_path == nil or not unit.safe_target_position then
    path_indicator_clear(unit)
    return
  end

  if not (unit.path_indicator and unit.path_indicator.direct)  then
    path_indicator_clear(unit)
    unit.path_indicator = path_indicator_template_direct()
  end

  local path_indicator = unit.path_indicator

  if path_indicator.final and path_indicator.final.valid then
    path_indicator.final.teleport(unit.safe_target_position)
  else
    path_indicator.final = unit.vehicle.surface.create_entity{ name= "indicator-final-green", position= unit.safe_target_position}
  end

  if not (path_indicator.lines[1] and path_indicator.lines[1].valid) then
    path_indicator.lines[1] = unit.vehicle.surface.create_entity{ name="indicator-beam-green", position= unit.vehicle.position, source=unit.vehicle, target=path_indicator.final}
  end

end

local function path_indicator_draw_navpath(unit)
  if unit.show_path == nil or not unit.navpath then
    path_indicator_clear(unit)
    return
  end
  local navpath = unit.navpath

  if not unit.path_indicator then
    unit.path_indicator = path_indicator_template_navpath(navpath)
  end

  local navpath = unit.navpath

  if unit.path_indicator.path_start_x ~= navpath.path[1].x
    or unit.path_indicator.path_start_y ~= navpath.path[1].y
    or unit.path_indicator.path_target_x ~= navpath.target_position.x
    or unit.path_indicator.path_target_y ~= navpath.target_position.y
    then
      -- vis does not match path
      path_indicator_clear(unit)
      unit.path_indicator = path_indicator_template_navpath(navpath)
  end

  local path_indicator = unit.path_indicator
  local color = navpath.path_complete and "green" or "yellow"

  -- removed passed points
  for i = 1, navpath.current_index-1, 1 do
    if path_indicator.lines[i] then
      path_indicator.lines[i].destroy() path_indicator.lines[i] = nil
    end
    if path_indicator.waypoints[i] then
      path_indicator.waypoints[i].destroy() path_indicator.waypoints[i] = nil
    end
  end

  local limit = #navpath.path + 1
  for i = navpath.current_index, limit, 1 do
    local point = navpath.path[i]
    if i == (#navpath.path + 1) then point = unit.target_position or navpath.target_position end
    if not (path_indicator.waypoints[i] and path_indicator.waypoints[i].valid) then
      path_indicator.waypoints[i] = unit.vehicle.surface.create_entity{ name="indicator-waypoint-"..color, position= point}
    else
      path_indicator.waypoints[i].teleport(point)
    end
    if not (path_indicator.lines[i] and path_indicator.lines[i].valid) then
        local source = path_indicator.waypoints[i-1]
        local target = path_indicator.waypoints[i]
        if i == navpath.current_index then source = unit.vehicle end
        path_indicator.lines[i] = unit.vehicle.surface.create_entity{ name="indicator-beam-"..color, position= point, source=source, target=target}
    end
  end

  local final_point = unit.target_position or navpath.target_position
  if path_indicator.final and path_indicator.final.valid then
    path_indicator.final.teleport(final_point)
  else
    path_indicator.final = unit.vehicle.surface.create_entity{ name= "indicator-final-"..color, position= final_point}
  end


end

local function unit_update_state(unit)
    -- this will update things like last position so should only be called once per tick
    local unit_type = unit_get_type(unit)

    unit.position_last = unit.position
    unit.position = unit.vehicle.position

    -- fixing tree collisions
    if unit.tree_overkill then
      local speed_change = unit.vehicle.speed - unit.vehicle_velocity
      if speed_change < 0 then
          -- vehicle was slowed
          local tree_damage = unit_type.tree_damage -- 80 for tank
          local speed_loss = unit.tree_overkill / tree_damage
          unit.vehicle.speed = unit.vehicle.speed - speed_change * speed_loss
      end
      unit.tree_overkill = nil
    end

    unit.vehicle_velocity_last = unit.vehicle_velocity
    unit.vehicle_velocity = unit.vehicle.speed
    unit.speed = util.vectors_delta_length(unit.position, unit.position_last)

    if math.floor(unit.position.x) ~= math.floor(unit.position_last.x) or
    math.floor(unit.position.y) ~= math.floor(unit.position_last.y)
    then --if unit.speed > 0.0001 then
        unit.move_last_tick = game.tick
        unit_reset_stuck(unit)
    end

    --[[
    --not required with on_entity_damaged
    if unit.vehicle.health ~= unit.health then
        if unit.vehicle.health < unit.health then
            -- negate 0.1 from each damage instace (soft collisions)
            -- this is targeting impacts, may inadvertently nerf enemy dot attacks
            unit.vehicle.health = min(unit.vehicle.health + 0.01, unit.health)
            -- nudge unit to not get stuck in a wall
            unit_on_damage_taken(unit)
        end
        unit.health = unit.vehicle.health
    end
    ]]--
    unit.health = unit.vehicle.health

    if not unit_is_active(unit) then
      path_indicator_clear(unit)
      return
    end

    if unit.mode ~= "unit" then
        unit.navpath = nil
    end

    -- if following a moving target, update the target posotion info
    if unit.follow_target and unit.mode ~= "passive" and unit_get_energy(unit) > 0 and (game.tick + unit.unit_id) % 5 == 0 then
        -- Note:
        -- unit.follow_target.lock_type must be "unit" or "player"
        -- unit.follow_target.unit must be an aai vehicle-unit object
        -- unit.follow_target.player must be an player reference
        -- unit.follow_target.offset_absolute is an optional vector
        -- unit.follow_target.offset_rotated is an optional vector that gets rotated based on target orientation
        -- unit.follow_target.offset_distance is an optional float for distance to maintain, defaults to default_follow_distance, with optional orientation
        -- unit.follow_target.offset_orientation is an optional float, orientation for offset_distance

        local locked_entity
        if unit.follow_target.lock_type == "unit" then
          if unit.follow_target.unit and unit.follow_target.unit.vehicle and unit.follow_target.unit.vehicle.valid
            and unit.follow_target.unit.unit_id ~= unit.unit_id then
            locked_entity = unit.follow_target.unit.vehicle
          end
        elseif unit.follow_target.lock_type == "player" then
          if unit.follow_target.player and unit.follow_target.player.valid and unit.follow_target.player.connected then
            locked_entity = unit.follow_target.player.character
          end
        end
        if locked_entity and locked_entity.valid then
            local position = locked_entity.position
            if unit.follow_target.offset_absolute then
                position = util.vectors_add(position, unit.follow_target.offset_absolute)
            elseif unit.follow_target.offset_rotated then
                local orientation
                if unit.follow_target.lock_type == "unit" and locked_entity.type == "car" then
                  orientation = locked_entity.orientation
                elseif unit.follow_target.lock_type == "player" then
                  if unit.follow_target.player.vehicle then
                    orientation = unit.follow_target.player.vehicle.orientation
                  elseif locked_entity.walking_state then
                    orientation = util.direction_to_orientation(locked_entity.walking_state.direction)
                  end
                else
                  orientation = util.direction_to_orientation(locked_entity.direction)
                  --game.print(locked_entity.direction)
                end
                position = util.vectors_add(position, util.rotate_vector(orientation, unit.follow_target.offset_rotated))
            else
                local offset_distance = unit.follow_target.offset_distance or default_follow_distance
                if unit.follow_target.offset_orientation then
                    position = util.vectors_add(position, util.orientation_to_vector(unit.follow_target.offset_orientation, offset_distance))
                else
                    position = util.vectors_add(position, util.vector_set_length(util.vectors_delta(locked_entity.position, unit.vehicle.position), offset_distance))
                end
            end
            unit.target_position = position
            unit.safe_target_position = position
            if unit.mode == "vehicle" and util.vectors_delta_length(unit.vehicle.position, unit.target_position) > move_to_acceptable_range then
              unit.stuck = 0
              unit_reset_stuck(unit)
              unit_set_mode(unit, "vehicle_move_to_temp")
            end
        else
          -- lost track of target
          -- continue to last destination or stop?
          unit.follow_target = nil
          unit.target_angle = nil
          unit.target_speed = 0
          unit.target_position = nil
          unit.safe_target_position = nil
          unit_set_mode(unit, "vehicle")
        end
    end

    if unit.mode == "passive" then -- full manual control of base and turret
        unit.target_angle = nil
        unit.target_speed = 0
        unit.target_position = nil
        unit.safe_target_position = nil
        path_indicator_clear(unit)
    elseif unit.mode == "vehicle" then -- move based on target speed and angle, or act as a turret
        unit.safe_target_position = nil
        if unit_get_energy(unit) > 0 then
            unit_rotate_to_target_angle(unit)
            unit_speed_to_target_speed(unit)
            if unit.vehicle.speed == 0  then
                -- allow miner animation to kick in
                unit.target_speed = nil
            end
        end
        if unit.target_position and unit_get_energy(unit) > 0 then
            if util.vectors_delta_length(unit.vehicle.position, unit.target_position) > navigator_minimum_range then
                unit.stuck = 0
                unit_reset_stuck(unit)
                unit_set_mode(unit, "unit")
            end
        end
    elseif unit.mode == "vehicle_move_to" or unit.mode == "vehicle_move_to_temp" then -- head straight towards the target position

      if unit_get_energy(unit) > 0 then
        if not unit.target_position then
            unit.stuck = 0
            unit_reset_stuck(unit)
            unit_set_mode(unit, "vehicle")
        else

            if unit_stuck_time(unit) > 60 then
              if (game.tick + unit.unit_id) % 6 == 0 then
                unit_nudge(unit)
              end
              if unit_stuck_time(unit) > 120 and unit.mode == "vehicle_move_to_temp" then
                unit.stuck = 0
                unit_reset_stuck(unit)
                unit_set_mode(unit, "unit")
              end
            end

            if not unit.safe_target_position then
                local save_pos = unit.vehicle.position
                unit.vehicle.teleport({x = save_pos.x, y = save_pos.y + 10}) -- move out of the way
                unit.safe_target_position = unit.vehicle.surface.find_non_colliding_position(
                    unit_get_type(unit).vehicle_whole, -- name of type
                    unit.target_position, -- position
                    10, -- radius
                    0.25 -- precision
                )
                unit.vehicle.teleport(save_pos) -- move back
                if not unit.safe_target_position then unit.safe_target_position = unit.target_position end -- fallback
            end
            if unit.safe_target_position then
              path_indicator_draw_direct(unit)
              local distance = util.vectors_delta_length(unit.vehicle.position, unit.safe_target_position)
              if distance < move_to_acceptable_range then
                  unit.target_angle = nil
                  unit.target_speed = 0
                  unit.target_position = nil
                  unit.stuck = 0
                  unit_reset_stuck(unit)
                  unit_set_mode(unit, "vehicle")
              else
                if unit_get_energy(unit) > 0 then
                    local dx = unit.safe_target_position.x - unit.position.x
                    local dy = unit.safe_target_position.y - unit.position.y
                    unit.target_angle = vector_to_orientation_xy(dx, dy)
                    unit_rotate_to_target_angle(unit)
                    local turn_still_required = unit_delta_angle_abs(unit.vehicle.orientation, unit.target_angle)*360
                    local target_speed = (0.02 + distance / 50)
                    if turn_still_required > 90 then
                        target_speed = -0.001
                    elseif turn_still_required > 45 or turn_still_required/5 > distance then
                        target_speed = -0.001
                    end
                    unit.target_speed = target_speed
                    unit_speed_to_target_speed(unit)
                  end
              end
            end

        end
      end
    elseif unit.mode == "unit" then -- use a unit navigator for pathfinding

      if unit_get_energy(unit) <= 0 then
        unit.mode = "passive"
        unit.stuck = 0
        unit_reset_stuck(unit)
      else

        if not unit.target_position then
            unit.stuck = 0
            unit_reset_stuck(unit)
            unit_set_mode(unit, "vehicle")
        else

          local target_speed = 0

          if unit.navigator and unit.navigator.valid and unit.navigator.stickers then
            -- navigator should not be on fire
            for _, sticker in pairs(unit.navigator.stickers) do
                sticker.destroy()
            end
          end

          if unit_stuck_time(unit) > 360 then
            unit.navpath = nil
            unit_reset_stuck(unit)
            if math.random() < 0.5 then
              unit.mode = "vehicle_move_to_temp"
            end
          end

          if not unit.navpath then
              unit.safe_target_position = unit.vehicle.surface.find_non_colliding_position(
                  unit_type.buffer, -- name of type
                  unit.target_position, -- position
                  10, -- radius
                  0.25 -- precision
              ) or unit.target_position
              unit.navpath = {
                target_position = unit.safe_target_position,
                current_index = 1,
                path = {{x = math.floor(unit.vehicle.position.x), y = math.floor(unit.vehicle.position.y)}},
                path_complete = false,
              }
              if unit.navigator and unit.navigator.valid then
                unit.navigator.destroy()
              end
          end

          local distance_to_target = util.vectors_delta_length(unit.vehicle.position, unit.safe_target_position or unit.target_position)

          local navpath = unit.navpath
          if navpath.path_complete then
              if unit.navigator and unit.navigator.valid then
                unit.navigator = destroy_entity(unit.navigator)
                --game.print(game.tick .. " " .. unit.unit_id .. " path complete")
              end
          else
              -- navigator still running
              if not (unit.navigator and unit.navigator.valid) and (unit.vehicle.name == unit_type.vehicle_ghost) then

                local safe_pos = unit.vehicle.surface.find_non_colliding_position(
                    unit_type.navigator,
                    navpath.path[#navpath.path], -- last position
                    10, -- radius
                    0.25 -- precision
                )
                safe_pos = safe_pos or navpath.path[#navpath.path] -- might be nil if no safe place
                navpath.navigate_to_position = unit.safe_target_position or unit.target_position
                --unit.navigator = unit_create_entity_from_entity(unit, unit_type.navigator, unit.vehicle, false )
                unit.navigator = unit_create_entity(unit, unit_type.navigator, unit.vehicle.surface, safe_pos, unit.vehicle.force)
                unit.navigator.destructible = false
                --game.print(game.tick .. " " .. unit.unit_id .. " move to " .. navpath.navigate_to_position.x .. " " .. navpath.navigate_to_position.y)
                unit.navigator.set_command({
                      type= defines.command.go_to_location,
                      destination= navpath.navigate_to_position,
                      distraction= defines.distraction.none})
              end

              if not navpath.navigate_to_position then navpath.navigate_to_position = unit.target_position end
              if unit.navigator and unit.navigator.valid and unit.target_position then
                -- navigator is still running, manage navigator and add trail to path

                local navigator_distance_to_target = util.vectors_delta_length(unit.navigator.position, navpath.navigate_to_position)
                if navigator_distance_to_target < navigator_minimum_range then
                    -- units go in to wander mode in this range.
                    -- set the last point in the path to the target location and kill the navigator
                    table.insert(navpath.path, navpath.navigate_to_position)
                    navpath.path_complete = true
                    path_indicator_clear(unit)
                    unit.navigator = destroy_entity(unit.navigator)
                    --game.print(game.tick .. " " .. unit.unit_id .. " path complete")
                else
                    local nav_tile = util.position_to_tile(unit.navigator.position)
                    if navpath.path[#navpath.path].x ~= nav_tile.x or navpath.path[#navpath.path].y ~= nav_tile.y then
                        navpath.stuck = 0
                        --this tile is not the previous tile
                        for _, old_tile in ipairs(navpath.path) do
                            if old_tile.x == nav_tile.x and old_tile.y == nav_tile.y then
                                -- we've already been to this tile.
                                -- if we have not reached this point yet then just cut the loop,
                                -- otherwise kill the path and try again
                                if _ >= navpath.current_index then
                                    local to_end = #navpath.path
                                    for i = _, to_end, 1 do
                                        table.remove(navpath.path, i)
                                        --game.print("trimming from path: " .. i)
                                    end
                                    break
                                elseif util.vectors_delta_length(unit.navigator.position, navpath.path[1]) > 5 then
                                    -- don't end a parth that has only just begun
                                    --game.print(game.tick .. " " .. unit.unit_id .. " killing looped path")
                                    unit.navigator = destroy_entity(unit.navigator)
                                    unit.navpath = nil
                                    break
                                end
                            end
                        end
                        table.insert(navpath.path, nav_tile)
                        -- debug
                        --[[local area = {left_top = nav_tile, right_bottom = {x = nav_tile.x + 0.9, y = nav_tile.y + 0.9}}
                        remote.call("aai-zones", "apply_zone_to_area", {
                          surface = unit.vehicle.surface,
                          force = unit.vehicle.force,
                          area = area,
                          type = "zone-diagonal-left-black"
                        })]]--
                    else
                        navpath.max_timeout = (navpath.max_timeout or 0) + 1
                        if navpath.max_timeout > 120 + 20 * math.sqrt(5 + distance_to_target) then
                            -- the navigator might be in wander mode going in circles
                            -- be more accepting if the distances is larger
                            unit.navigator = destroy_entity(unit.navigator)
                            unit.navigator = nil
                            unit.navpath = nil
                            --game.print(game.tick .. " " .. unit.unit_id .. " path timeout")
                        else
                            navpath.stuck = (navpath.stuck or 0) + 1
                            if navpath.stuck > 60 * 5 then
                                navpath.stuck_fixes = (navpath.stuck_fixes) or 0 + 1
                                navpath.stuck = 0
                                if navpath.stuck_fixes == 1 then
                                    -- get moving - sometimes biters freeze in inactive chunks
                                    unit.navigator.set_command({
                                        type= defines.command.go_to_location,
                                        destination= unit.safe_target_position or unit.target_position,
                                        distraction= defines.distraction.none})
                                elseif navpath.stuck_fixes == 2 then
                                    -- try a new navigator from the last position
                                    unit.navigator = destroy_entity(unit.navigator)
                                    --game.print(game.tick .. " " .. unit.unit_id .. " try new navigator")
                                else
                                    -- this path is not working out, try again from the beginning
                                    unit.navigator = destroy_entity(unit.navigator)
                                    unit.navpath = nil
                                    --game.print(game.tick .. " " .. unit.unit_id .. " try new path")
                                end
                            end
                        end
                    end
                end
              end
          end

          path_indicator_draw_navpath(unit)

          if unit_get_energy(unit) > 0 then
            if navpath.path_complete and navpath.current_index == #navpath.path then
                -- at the end
                unit.stuck = 0
                unit_reset_stuck(unit)
                unit.navpath = nil
                unit_set_mode(unit, "vehicle_move_to_temp")
            else

              if navpath.current_index < #navpath.path then
                  -- has next tile
                  local next_tile = navpath.path[navpath.current_index + 1]
                  local waypoint_tolerance = 1.5;
                  if next_tile then
                    local distance = util.vectors_delta_length(unit.vehicle.position, util.tile_to_position(next_tile))
                    if (distance < 0.25) or (distance < waypoint_tolerance and #navpath.path > 3) then
                      navpath.current_index = navpath.current_index + 1
                    end
                  end
              end

              if navpath.current_index < #navpath.path then
                  target_speed = 0.01 + distance_to_target / 50
                  -- can go forward
                  local next_tile = navpath.path[navpath.current_index + 1]
                  local next_angle = orientation_from_to(unit.vehicle.position, util.tile_to_position(next_tile))
                  unit_rotate_to_angle(unit.vehicle, next_angle, unit_type.rotation_speed, true)
                  local turn_still_required = unit_delta_angle_abs(unit.vehicle.orientation, next_angle)
                  if math.abs(turn_still_required) > 90 / 360 then
                      target_speed = -0.01 -- reverse a tiny bit
                  elseif math.abs(turn_still_required) > 45 / 360 then
                      target_speed = math.min(target_speed, unit.vehicle.speed) * 0.95 -- slow down and turn
                  end
              end

              unit.vehicle.speed = unit.vehicle.speed * (1 - (unit_type.friction + 0.0001))-- ghost has no friction?

            end

          end

          unit_speed_to(unit, target_speed)

        end
      end
    end


    if unit_type.is_hauler then
        unit_vehicle_exchange_inventory(unit)
    end

    if unit.vehicle then -- update energy state, consume based on speed
        if math.abs(unit.vehicle.speed) > 0.01 then
            -- vehicles that slowly apporach a destination get stuck where the speed is non-0 but never progress to the next pixel.
            local energy_used = math.abs(unit.vehicle.speed) * unit_type.weight * 20 / (unit_type.effectivity or 1)-- * multiplier

            --if not unit.vehicle.passenger then -- this is disabled bcuase driver acceleration consumed fuel
              -- only consume fuel if there is no passenger, passenger acceleration already consumes fuel
            --  unit.vehicle.burner.remaining_burning_fuel = unit.vehicle.burner.remaining_burning_fuel - energy_used
            --end
            -- to do: alter based on electric vs burner power
            unit.vehicle.surface.pollute(unit.position, energy_used / 1500000)
        end

        if (not unit.vehicle.burner.currently_burning) or (unit.vehicle.burner.remaining_burning_fuel < unit.vehicle.burner.currently_burning.fuel_value * 0.02 + 1) then
            consume_fuel_or_equipment(unit)
        end

        -- turret, lamp, sound, pollution, scan, provoke
        if unit_get_energy(unit) > 0 then

            if unit.mode ~= "passive" then
              if unit_type.gun then
                  unit_update_gun(unit)
              end
            end

            if (game.tick + unit.unit_id * 133) % 300 == 0 then
                -- chart and provoke every 5 seconds

                local chart_range = 32 -- not required with driver
                unit.vehicle.force.chart(unit.vehicle.surface,
                          {{x = unit.vehicle.position.x - chart_range, y = unit.vehicle.position.y - chart_range},
                          {x = unit.vehicle.position.x + chart_range, y = unit.vehicle.position.y + chart_range}})

                local provoke_range = 64
                local enemies = unit.vehicle.surface.find_entities_filtered{
                    area={{x = unit.vehicle.position.x - provoke_range, y = unit.vehicle.position.y - provoke_range},
                    {x = unit.vehicle.position.x + provoke_range, y = unit.vehicle.position.y + provoke_range}},
                    type="unit",force=game.forces["enemy"]}

                local group
                for _, enemy in pairs(enemies) do
                    if not enemy.unit_group then
                        if not group then
                            group = unit.vehicle.surface.create_unit_group{position = unit.vehicle.position, force = game.forces["enemy"]}
                        end
                        group.add_member(enemy)
                    end
                end
                if group then
                    group.set_command({
                            type = defines.command.attack_area,
                            destination = unit.vehicle.position,
                            radius = 8})
                    group.start_moving()
                end

            end

        end
    end

end

local function unit_set_command(data)
    -- can be called remotely
    --data.unit_id or data.unit
    --data.target_speed
    --data.target_angle(0-1)
    --data.target_position (if sending to a tile try to send to the tile center (+0.5, +0.5)
    --data.target_position_direct: send to a subtile, igrnore pathfinding
    --data.follow_target_type = "player" or "unit"
    --data.follow_target_player = LuaPlayer
    --data.follow_target_unit_id = unit_id
    --data.follow_target_offset_rotated = position offset
    --data.follow_target_offset_absolute = position offset
    --data.follow_target_range = float
    --data.follow_target_orientation = float

    -- Note: for building follow target from command
    -- unit.follow_target.lock_type must be "unit" or "player"
    -- unit.follow_target.unit must be an aai vehicle-unit object
    -- unit.follow_target.player must be an player reference
    -- unit.follow_target.offset_absolute is an optional vector
    -- unit.follow_target.offset_rotated is an optional vector that gets rotated based on target orientation
    -- unit.follow_target.offset_distance is an optional float for distance to maintain, defaults to default_follow_distance, with optional orientation
    -- unit.follow_target.offset_orientation is an optional float, orientation for offset_distance
    local unit = data.unit

    if not unit and data.unit_id then
        unit = global.unit.units[data.unit_id]
    end

    if unit then
        if data.follow_target_type then
            local follow_target = {}
            if data.follow_target_type == "unit" and data.follow_target_unit_id then
                local follow_unit = unit_by_unit_id(data.follow_target_unit_id)
                if follow_unit and follow_unit.unit_id ~= unit.unit_id then
                    follow_target.lock_type = data.follow_target_type
                    follow_target.unit = follow_unit
                end
            end
            if data.follow_target_type == "player" and data.follow_target_player and data.follow_target_player.valid then
                follow_target.lock_type = data.follow_target_type
                follow_target.player = data.follow_target_player
            end
            if data.follow_target_type then

              if data.follow_target_offset_rotated then
                follow_target.offset_rotated = data.follow_target_offset_rotated
              elseif data.follow_target_offset_absolute then
                follow_target.offset_absolute = data.follow_target_offset_absolute
              else
                  follow_target.offset_distance = data.follow_target_range
                  follow_target.offset_orientation = data.follow_target_orientation
              end

              if unit.follow_target and unit.follow_target.entity == follow_target.entity
              and (unit.follow_target.unit and unit.follow_target.unit.unit_id or 0) == (follow_target.unit and follow_target.unit.unit_id or 0) then
                -- the same target as before, changing this will only change any offsets
                unit.follow_target = follow_target
              else
                unit.follow_target = follow_target
                unit.stuck = 0
                unit_reset_stuck(unit)
                unit.target_position = nil
                unit.safe_target_position = nil
                unit.target_speed = nil
                unit.target_angle = nil
                unit.nav = nil
                unit_set_mode(unit, "unit")
              end
            end
        else
            if data.target_position_direct then
                unit.order_last_tick = game.tick
                unit_set_target_position(unit, data.target_position_direct, "move_to_temp")
            elseif data.target_position then
                unit.order_last_tick = game.tick
                unit_set_target_position(unit, data.target_position, false)
            else
                if data.target_speed then
                    unit.follow_target = nil
                    unit.order_last_tick = game.tick
                    unit.target_speed = data.target_speed
                    unit.target_position = nil
                    unit.safe_target_position = nil
                    unit.stuck = 0
                    unit_reset_stuck(unit)
                    unit_set_mode(unit, "vehicle")
                end
                if data.target_angle then
                    unit.follow_target = nil
                    unit.order_last_tick = game.tick
                    unit.target_angle = data.target_angle % 1
                    unit.target_position = nil
                    unit.safe_target_position = nil
                    unit.stuck = 0
                    unit_reset_stuck(unit)
                    unit_set_mode(unit, "vehicle")
                end
            end
        end
    end
    raise_event('on_unit_given_order', {unit = unit, order=data})
end

-- Structs: vehicle-depot and vehicle-deployer
-- global.structure_unit_numbers[unit_number] = struct_id-- includes sub entities
-- global.structures[struct_id] = {type="", entitiy=main_entity, sub={sub_entities}} -- only main entity
-- global.next_struct_id = global.next_struct_id + 1

local function struct_create_or_revive(entity_type, surface, area, position, force) -- based on aai-programmable-structures
    -- position MUST be in area for revive return to work
    local found_ghost = false
    local ghosts = surface.find_entities_filtered{
        area=area,
        name="entity-ghost",
        force=force}
    for _, each_ghost in pairs(ghosts) do
        if each_ghost.valid and each_ghost.ghost_name == entity_type then
            if found_ghost then
                each_ghost.destroy()
            else
                each_ghost.revive()
                if not each_ghost.valid then
                    found_ghost = true
                else
                    each_ghost.destroy()
                end
            end
        end
    end

    if found_ghost then
        local entity = surface.find_entities_filtered{
            area=area,
            name=entity_type,
            force=force,
            limit=1
        }[1]
        if entity then
            entity.direction = defines.direction.south
            entity.teleport(position)
            return entity
        end
    else
        local reals = surface.find_entities_filtered{
            area=area,
            name=entity_type,
            limit=1
        }
        if #reals == 1 then
          return reals[1]
        end

        return surface.create_entity{
            name=entity_type,
            position=position,
            force=force,
            fast_replace = true
        }
    end
end

local function struct_sub_search_area_vehicle_deployer(position)
    return {{position.x - 4, position.y - 4}, {position.x + 4, position.y + 4}}
end

local function struct_construction_denial(entity, event)
    if not (entity and entity.valid) then return end
    -- check for illegal structure placement
    if entity.type ~= "entity-ghost" and entity.type ~= "car" then
        local area = {{
            entity.position.x - construction_denial_range,
            entity.position.y - construction_denial_range
        }, {
            entity.position.x + construction_denial_range,
            entity.position.y + construction_denial_range
        }}
        local enemies = entity.surface.find_entities_filtered{
          area= area,
          force="enemy"}
        for _, enemy in pairs(enemies) do
            if (enemy.type == "unit-spawner" or enemy.type == "turret") and util.vectors_delta_length(entity.position, enemy.position) < construction_denial_range then
                -- deny construction
                if entity.prototype.mineable_properties
                  and entity.prototype.mineable_properties.products
                  and entity.prototype.mineable_properties.products[1]
                  and entity.prototype.mineable_properties.products[1].type == "item" then
                    local stack = {name=entity.prototype.mineable_properties.products[1].name, amount=1}
                    if event and event.name == "on_dolly_moved" and event.start_pos and event.player_index then
                        entity.teleport(event.start_pos)
                        game.players[event.player_index].print{"construction_denied_by_enemy"}
                        return
                    elseif event
                      and event.name == defines.events.on_built_entity
                      and event.player_index
                      and game.players[event.player_index]
                      and game.players[event.player_index].connected
                      and game.players[event.player_index].can_insert(stack) then
                        game.players[event.player_index].print{"construction_denied_by_enemy"}
                        game.players[event.player_index].insert(stack)
                    else
                        entity.surface.create_entity{
                          name = "item-on-ground",
                          position = entity.position,
                          stack = stack}
                    end
                end
                if math.random() < 0.05 then
                  local spawn_type = math.random() < 0.25 and "small-spitter" or "small-biter"
                  entity.surface.create_entity{
                    name = spawn_type,
                    position = entity.position,
                    force="enemy"}
                end
                entity.destroy()
                return
            end
        end
    end
end

local function struct_manage_entity(entity, event)
  struct_construction_denial(entity, event)
  if not (entity and entity.valid) then return end

  if not global.structures then global.structures = {} end
  if not global.structure_unit_numbers then global.structure_unit_numbers = {} end
  if not global.next_struct_id then global.next_struct_id = 1 end

  if entity.name == "vehicle-depot-base" then
      local struct = {}
      struct.type = "vehicle-depot"
      struct.struct_id = global.next_struct_id
      global.next_struct_id = global.next_struct_id + 1
      global.structures[struct.struct_id] = struct

      struct.sub = {}

      struct.sub.base = entity
      entity.destructible = false
      global.structure_unit_numbers[entity.unit_number] = struct.struct_id
      --entity.active = false
      -- create chest
      local chest = struct_create_or_revive(
          "vehicle-depot-chest", -- name
          --"iron-chest", -- name
          entity.surface, -- surface
          {{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}}, -- ghost search area
          {x = entity.position.x, y = entity.position.y},-- position
          entity.force)
      struct.entity = chest
      global.structure_unit_numbers[chest.unit_number] = struct.struct_id

      -- create combinator
      local combinator = struct_create_or_revive(
          "vehicle-depot-combinator", -- name
          entity.surface, -- surface
          {{entity.position.x - 4.5, entity.position.y - 4.5}, {entity.position.x + 4.5, entity.position.y + 4.5}}, -- ghost search area
          {x = entity.position.x + 4, y = entity.position.y - 3},-- position
          entity.force) -- force
      combinator.destructible = false
      struct.sub.combinator = combinator
      global.structure_unit_numbers[combinator.unit_number] = struct.struct_id

  elseif entity.name == vehicle_deployer_type.struct_main then
      local struct = {}
      struct.type = "vehicle-deployer"
      struct.struct_id = global.next_struct_id
      global.next_struct_id = global.next_struct_id + 1
      global.structures[struct.struct_id] = struct

      struct.entity = entity
      struct.sub = {}

      global.structure_unit_numbers[entity.unit_number] = struct.struct_id

      local overlay_position = {x = entity.position.x, y = entity.position.y + vehicle_deployer_type.deployer_overlay_offset}
      struct.sub.overlay = struct_create_or_revive(
          vehicle_deployer_type.struct_overlay, -- name
          entity.surface, -- surface
          {{overlay_position.x - 1, overlay_position.y - 1}, {overlay_position.x + 1, overlay_position.y + 1}}, -- ghost search area
          overlay_position,-- position
          entity.force)
      struct.sub.overlay.destructible = false
      if(struct.sub.overlay.unit_number) then -- simple_entity
          global.structure_unit_numbers[struct.sub.overlay.unit_number] = struct.struct_id
      end

      if vehicle_deployer_type.struct_combinator then
        local place_position = {x = entity.position.x + vehicle_deployer_type.deployer_combinator_offset.x, y = entity.position.y + vehicle_deployer_type.deployer_combinator_offset.y}
          struct.sub.combinator = struct_create_or_revive(
              vehicle_deployer_type.struct_combinator,
              entity.surface,
              struct_sub_search_area_vehicle_deployer(place_position),
              place_position,
              entity.force)
          struct.sub.combinator.destructible = false
          global.structure_unit_numbers[struct.sub.combinator.unit_number] = struct.struct_id
      end

      if vehicle_deployer_type.struct_belt then
          struct.sub.belt = struct_create_or_revive(
              vehicle_deployer_type.struct_belt,
              entity.surface,
              struct_sub_search_area_vehicle_deployer(entity.position),
              {entity.position.x, entity.position.y + vehicle_deployer_type.deployer_belt_offset},
              entity.force)
          struct.sub.belt.destructible = false
          global.structure_unit_numbers[struct.sub.belt.unit_number] = struct.struct_id
      end


  end
end

local function struct_unmanage(struct)
    if not struct then return end
    if struct.sub then
        for _, subentity in pairs(struct.sub) do
            if subentity.valid then
                if global.structure_unit_numbers and subentity.unit_number then
                    global.structure_unit_numbers[subentity.unit_number] = nil
                end
                subentity.destroy()
            end
            struct.sub[_] = nil
        end
    end
    if struct.reserved_entity and struct.reserved_entity.valid then struct.reserved_entity.destroy() end
    if struct.entity and struct.entity.valid then
      if global.structure_unit_numbers then
          global.structure_unit_numbers[struct.entity.unit_number] = nil
      end
    end
    if global.structures then
        global.structures[struct.struct_id] = nil
    end
end

local function struct_unmanage_entity(entity)
    if not entity.valid then return end
    if global.structures then
      local struct_id = global.structure_unit_numbers[entity.unit_number]
      if struct_id then
        struct_unmanage(global.structures[struct_id])
      end
    end
end

local function struct_get_circuit_inputs(combinator)
    if combinator and combinator.valid then
        local inputs = {}
        local network = combinator.get_circuit_network(defines.wire_type.red)
        local network_found = false
        if network and network.signals then
            network_found = true
            for _, signal_count in pairs(network.signals) do
                signal_container_add(inputs, signal_count.signal, signal_count.count)
            end
        end
        network = combinator.get_circuit_network(defines.wire_type.green)
        if network and network.signals then
            network_found = true
            for _, signal_count in pairs(network.signals) do
                signal_container_add(inputs, signal_count.signal, signal_count.count)
            end
        end
        if not network_found then
            -- get straight from combinator
            local parameters = combinator.get_or_create_control_behavior().parameters.parameters
            for _, param in pairs(parameters) do
                if param.signal.name then
                    signal_container_add(inputs, param.signal, param.count)
                end
            end
        end
        return inputs
    end
end

local function vehicle_depot_exchange_inventory(depot)
    if (game.tick + depot.struct_id) % depot_transfer_interval == 0 then
        -- once per second
        -- get the effective unit data from the attached combinator or circuits
        local test_vehicles = depot.entity.surface.find_entities_filtered{
            type="car",
            area={
              {
                x=depot.entity.position.x-depot_transfer_range,
                y=depot.entity.position.y-depot_transfer_range
              },{
                x=depot.entity.position.x+depot_transfer_range,
                y=depot.entity.position.y+depot_transfer_range
              }
            },
            force=depot.entity.force}
        -- compansate for weird offset
        local detected = false
        local other_units = {}
        for _, test_vehicle in pairs(test_vehicles) do
            local other_unit = unit_find_from_entity(test_vehicle)
            if other_unit then
                detected = true
                other_units[other_unit.unit_id] = other_unit
            end
        end

        if not detected then return end
        -- don't check settings if no vehicles are detected, getting settings is expensive
        local settings = struct_get_circuit_inputs(depot.sub.combinator)

        for _, other_unit in pairs(other_units) do
            if other_unit.vehicle.valid and other_unit.data and other_unit.data.item then

                local unit_type_b = unit_get_type(other_unit)
                if unit_type_b.is_hauler then
                    exchange_inventory({
                            b = {
                                entity = depot.entity,
                                data = settings,
                                is_hauler = false
                            },
                            a = {
                                entity = other_unit.vehicle,
                                data = other_unit.data or {},
                                is_hauler = true
                            },
                        })
                else
                    exchange_inventory({
                            a = {
                                entity = depot.entity,
                                data = settings,
                                is_hauler = true
                            },
                            b = {
                                entity = other_unit.vehicle,
                                data = other_unit.data or {},
                                is_hauler = false
                            },
                        })
                end

            end
        end
    end
end

local function struct_process_vehicle_deployer(struct)
    if struct.entity and struct.entity.valid then
        local struct_type = vehicle_deployer_type
        if struct.deploy_entity then
            -- keep deploying the entity
            if(struct.deploy_entity.valid) then
                local y = struct.entity.position.y + struct_type.deploy_start_offset
                + (-struct_type.deploy_start_offset + struct_type.deploy_end_offset) * struct.deploy_time / struct_type.deploy_time
                struct.deploy_entity.teleport({struct.entity.position.x, y})
                struct.deploy_time = struct.deploy_time + 1
                if struct.deploy_time > struct_type.deploy_time then
                    raise_event("on_entity_deployed", {entity = struct.deploy_entity, signals=struct.deployment_signals})
                    struct.deploy_time = 0
                    struct.deploy_entity = nil
                    if(struct.reserved_entity) then
                        struct.reserved_entity.destroy()
                        struct.reserved_entity = nil
                    end
                end
            else
                struct.deploy_entity = nil
                struct.reserved_entity.destroy()
                struct.reserved_entity = nil
            end
        else
            -- deploy an entity if there is an item
            local inventory = struct.entity.get_inventory(defines.inventory.chest)
            for item_type in pairs(inventory.get_contents()) do
                local item_stack = inventory.find_item_stack(item_type)
                --send_message(item_stack.prototype.place_result.type)
                if(item_stack.prototype and item_stack.prototype.place_result and item_stack.prototype.place_result.type and item_stack.prototype.place_result.type == "car") then
                    if(struct.entity.surface.can_place_entity{
                            name=struct_type.struct_reserved,
                            position = {x= struct.entity.position.x, y= struct.entity.position.y+struct_type.deploy_end_offset},
                            direction=defines.direction.south
                        }) then
                        struct.reserved_entity = struct.entity.surface.create_entity{
                            name=struct_type.struct_reserved,
                            position = {x= struct.entity.position.x, y= struct.entity.position.y+struct_type.deploy_end_offset},
                            direction=defines.direction.south}
                        struct.reserved_entity.destructible = false
                        struct.deploy_entity = struct.entity.surface.create_entity{
                            name=item_stack.prototype.place_result.name,
                            position={x= struct.entity.position.x, y= struct.entity.position.y+struct_type.deploy_start_offset},
                            force=struct.entity.force,
                            direction=defines.direction.south}
                        struct.deployment_signals = struct_get_circuit_inputs(struct.sub.combinator) -- get signals
                        inventory.remove({name=item_type, count=1})
                        struct.deploy_time = 0
                        break
                    end--send_message("exit blocked")
                end--send_message("invalid item")
            end
        end
    end
end

local function struct_tick()
    if not global.structures then return end
    for struct_id, struct in pairs(global.structures) do
        if struct.type == "vehicle-deployer" then
            -- run the deployer
            struct_process_vehicle_deployer(struct)
        elseif struct.type == "vehicle-depot" then
            if (game.tick + struct_id) % 60 == 0 then
                if struct.entity.valid then
                    vehicle_depot_exchange_inventory(struct)
                else
                    struct_unmanage(struct)
                end
            end
        end
    end
end


-------------------------------------------------------------------------------
--[[GUI?]]--
-------------------------------------------------------------------------------

local function remote_show_gui(player)
    if player.gui.left.remote_selected_units == nil then
        update_unit_types_ids()
        local remote_selected_units = player.gui.left.add{
          type = "frame",
          name = "remote_selected_units",
          caption = {"aai-programmable-vehicles.text-remote-selected-units"},
          direction = "vertical"}
        local remote_selected_units_scroll = remote_selected_units.add{
          type = "scroll-pane",
          name = "remote_selected_units_scroll",
          direction = "vertical",
          style = "aai_vehicles_units-scroll-pane"}
        for _, selected_unit in pairs(global.player_selected_units[player.index]) do
            local unit = selected_unit.unit
            local unit_type = unit_get_type(unit)
            local prototype = game.entity_prototypes[unit_type.vehicle_whole]
            local item_name = prototype.items_to_place_this and next(prototype.items_to_place_this)

            -- remove, typeid, unit_id, data
            local unit_frame = remote_selected_units_scroll.add{
                type = "frame",
                name = unit.unit_id,
                direction = "horizontal",
                style = "aai_vehicles_unit-frame"
            }
            local unit_flow_1 = unit_frame
            unit_flow_1.add{
                type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                name = "unit_type_id",
                sprite = "virtual-signal/"..unit_type.signal.name,
                tooltip = {"aai-programmable-vehicles.unit-of-type", unit.unit_type_id}
            }
            unit_flow_1.add{
              type = "label", caption = unit.unit_type_id, name = "unit_type_id_value", style = "aai_vehicles_unit-number-label"
            }

            unit_flow_1.add{
                type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                name = "unit_id",
                sprite = "virtual-signal/signal-id",
                tooltip = {"aai-programmable-vehicles.unit-id", unit.unit_id}
            }
            unit_flow_1.add{
              type = "label", caption = unit.unit_id, name = "unit_id_value", style = "aai_vehicles_unit-number-label"
            }

            unit_flow_1.add{
                type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                name = "unit_data",
                sprite = "virtual-signal/chip",
                tooltip = {"aai-programmable-vehicles.edit-unitdata"}
            }

            if unit.active_state == "active" then
              unit_flow_1.add{
                  type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                  name = "unit_state_on",
                  sprite = "virtual-signal/active-state-on",
                  tooltip = {"aai-programmable-vehicles.ai-on"}
              }
            elseif unit.active_state == "inactive" then
              unit_flow_1.add{
                  type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                  name = "unit_state_off",
                  sprite = "virtual-signal/active-state-off",
                  tooltip = {"aai-programmable-vehicles.ai-off"}
              }
            elseif unit.active_state == "auto_inactive" then
              unit_flow_1.add{
                  type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                  name = "unit_state_auto",
                  sprite = "virtual-signal/active-state-auto",
                  tooltip = {"aai-programmable-vehicles.ai-auto-off"}
              }
            else
              unit_flow_1.add{
                  type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                  name = "unit_state_auto",
                  sprite = "virtual-signal/active-state-auto",
                  tooltip = {"aai-programmable-vehicles.ai-auto-on"}
              }
            end
        end
    end
end

local function remote_hide_gui(player)
    if player.gui.left.remote_selected_units ~= nil then
        player.gui.left.remote_selected_units.destroy()
    end
end

local function remote_deselect_unit(player, remove_unit_id)
    remove_unit_id = tonumber(remove_unit_id)
    remote_hide_gui(player)
    if not global.player_selected_units then
        global.player_selected_units = {}
    elseif global.player_selected_units[player.index] then
        local selected_units = global.player_selected_units[player.index]
        local selected_unit_count = 0
        for unit_id, selected_unit in pairs(selected_units) do
            if unit_id == remove_unit_id then
                if selected_unit.selection and selected_unit.selection.valid then
                    selected_unit.selection.destroy()
                    selected_unit.selection = nil
                end
                selected_unit.unit.show_path = nil
                path_indicator_clear(selected_unit.unit)
                selected_units[unit_id] = nil
            else
                selected_unit_count = selected_unit_count + 1
            end
        end
        if selected_unit_count > 0 then
            remote_show_gui(player)
        end
    end
end


local function remote_deselect_units(player)
    remote_hide_gui(player)
    if not global.player_selected_units then
        global.player_selected_units = {}
    elseif global.player_selected_units[player.index] then
        local selected_units = global.player_selected_units[player.index]
        for unit_id, selected_unit in pairs(selected_units) do
            if selected_unit.selection and selected_unit.selection.valid then
                selected_unit.selection.destroy()
                selected_unit.selection = nil
            end
            selected_unit.unit.show_path = nil
            path_indicator_clear(selected_unit.unit)
            selected_units[unit_id] = nil
        end
        global.player_selected_units[player.index] = nil
    end
end

local function add_tick_task(task)
    -- add a function to tick tasks
    -- task must return true or be removed
    if not global.tick_tasks then
      global.tick_tasks = {}
      global.tick_tasks_next_id = 1
    end
    task.task_id = global.tick_tasks_next_id
    global.tick_tasks_next_id = global.tick_tasks_next_id + 1
    global.tick_tasks[task.task_id] = task
end

local function set_unit_data_from_combinator(unit_id, combinator)
    local unit = unit_by_unit_id(unit_id)
    if unit and combinator and combinator.valid then
        local inputs = {}
        local parameters = combinator.get_or_create_control_behavior().parameters.parameters
        for _, param in pairs(parameters) do
            if param.signal.name then
                signal_container_add(inputs, param.signal, param.count)
            end
        end
        unit.data = inputs
    end
end

local function set_unit_data_to_combinator(unit_id, combinator)
    local unit = unit_by_unit_id(unit_id)
    if unit and combinator and combinator.valid then
        local signal_container = unit.data
        local parameters = {}
        local index = 1;
        for _, signals in pairs(signal_container) do
            for _, signal_count in pairs(signals) do
                parameters[index] = {index=index, signal=signal_count.signal, count= math.floor(signal_count.count)}
                index = index + 1
            end
        end
        combinator.get_control_behavior().parameters = {parameters = parameters}
  end
end

local function remote_select_units(player, units)

  remote_deselect_units(player)

  global.player_selected_units[player.index] = {}
  for _, unit in pairs(units) do
      global.player_selected_units[player.index][unit.unit_id] = {unit = unit, selection = nil}
  end
  if #units > 0 then
      remote_show_gui(player)
  end

end


local function remote_on_gui_click(event)
    local player_index = event.player_index
    if game.players[player_index].gui.left.remote_selected_units ~= nil then
        local player = game.players[player_index]
        local parent = event.element.parent
        local is_unit_click = false
        while parent and not is_unit_click do
            if parent.name == "remote_selected_units" then
                is_unit_click = true
                break
            else
                parent = parent.parent
            end
        end
        if is_unit_click then
            local element = event.element
            if element.type ~= "sprite-button" then
                element = element.parent
            end
            local parent = element.parent

            local unit_id = tonumber(element.parent.name)
            local unit = unit_by_unit_id(unit_id)
            if unit then
              if element.name == "unit_type_id" then
                  remote_deselect_unit(player, unit_id)
              elseif element.name == "unit_id" and unit then
                  remote_select_units(player, {unit})
              elseif element.name == "unit_data" then
                  remote_deselect_units(player)
                  player.clean_cursor()
                  local interface = player.surface.create_entity{
                    name = "remote-unit-data",
                    force = player.force,
                    position = player.position }
                  set_unit_data_to_combinator(unit_id, interface)
                  player.opened = interface
                  -- add task to contant poll list
                  add_tick_task({
                    name = "editing_unit_data",
                    player_index = player_index,
                    unit_id = unit_id,
                    interface = interface
                  })
              elseif element.name == "unit_state_on" then
                  unit.active_state = "inactive"
                  element.destroy()
                  parent.add{
                      type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                      name = "unit_state_off",
                      sprite = "virtual-signal/active-state-off",
                      tooltip = {"aai-programmable-vehicles.ai-off"}
                  }
              elseif element.name == "unit_state_off" then
                  element.destroy()
                  unit_set_active_state_auto(unit)
                  if unit.active_state == "auto_active" then
                    parent.add{
                        type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                        name = "unit_state_auto",
                        sprite = "virtual-signal/active-state-auto",
                        tooltip = {"aai-programmable-vehicles.ai-auto-on"}
                    }
                  else
                    parent.add{
                        type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                        name = "unit_state_auto",
                        sprite = "virtual-signal/active-state-auto",
                        tooltip = {"aai-programmable-vehicles.ai-auto-off"}
                    }
                  end
              elseif element.name == "unit_state_auto" then
                  unit.active_state = "active"
                  element.destroy()
                  parent.add{
                      type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                      name = "unit_state_on",
                      sprite = "virtual-signal/active-state-on",
                      tooltip = {"aai-programmable-vehicles.ai-on"}
                  }
              end
            end
        end
    end
end

local function remote_on_player_selected_area(event)
    local alt = event.name == defines.events.on_player_alt_selected_area
    if (event.item == "unit-remote-control") then
        local player = game.players[event.player_index]
        if alt then
            -- move_to
            if global.player_selected_units and global.player_selected_units[event.player_index] then
                local selected_units = {} -- make array
                for _, s in pairs(global.player_selected_units[event.player_index]) do
                  table.insert(selected_units, s)
                end
                if #selected_units == 0 then return end
                local follow_target = nil
                local follow_type = nil
                if math.abs(event.area.right_bottom.x - event.area.left_top.x) < follow_max_selection_box
                  and math.abs(event.area.right_bottom.y - event.area.left_top.y) < follow_max_selection_box then
                    -- this is a small selection, maybe a follow command?
                    local middle = { -- middle position
                        x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
                        y = (event.area.left_top.y + event.area.right_bottom.y) / 2
                    }
                    local target_entities = player.surface.find_entities_filtered{type="car",
                      area={
                        {middle.x -follow_max_selection_box/2, middle.y -follow_max_selection_box/2},
                        {middle.x +follow_max_selection_box/2, middle.y +follow_max_selection_box/2}}, limit=1}
                    if #target_entities == 1 then
                      -- follow this vehicle
                      local unit = unit_find_from_entity(target_entities[1])
                      if unit then
                        local in_group = false
                        for _, u in pairs(selected_units) do
                          if u.unit.unit_id == unit.unit_id then
                            in_group = true
                            break
                          end
                        end
                        if not in_group then
                          follow_target = unit
                          follow_type = "unit"
                        end
                      end
                    end
                    if not follow_target then
                      local target_players = player.surface.find_entities_filtered{type="player",
                        area={{middle.x -1, middle.y -1}, {middle.x +1, middle.y +1}}, limit=1}
                      if #target_players == 1 then
                        -- follow this player
                        follow_target = target_players[1].player
                        follow_type = "player"
                      end
                    end
                end
                if follow_target then
                    if #selected_units == 1 then
                        if follow_type == "player" then
                          unit_set_command({
                              unit = selected_units[1].unit,
                              follow_target_type = follow_type,
                              follow_target_player = follow_target
                              -- use default distance
                          })
                        elseif follow_type == "unit" then
                          unit_set_command({
                              unit = selected_units[1].unit,
                              follow_target_type = follow_type,
                              follow_target_unit_id = follow_target.unit_id
                              -- use default distance
                          })
                        end
                    else
                        -- distribute vehicles in a circle around the target.
                        local base_command
                        if follow_type == "player" then
                          base_command = {
                              follow_target_type = follow_type,
                              follow_target_player = follow_target
                          }
                        elseif follow_type == "unit" then
                          base_command = {
                              follow_target_type = follow_type,
                              follow_target_unit_id = follow_target.unit_id
                          }
                        end
                        base_command.follow_target_range = 4 + #selected_units / 2
                        local i = 0
                        for _, selected_unit in pairs(selected_units) do
                            if selected_unit.unit and selected_unit.unit.vehicle and selected_unit.unit.vehicle.valid then
                                i = i + 1
                                local command = table.deepcopy(base_command)
                                command.unit = selected_unit.unit
                                command.follow_target_orientation = i / #selected_units
                                unit_set_command(command)
                            end
                        end
                    end
                else
                  local massed_data = {}
                  for _, selected_unit in pairs(selected_units) do
                      if selected_unit.unit and selected_unit.unit.vehicle and selected_unit.unit.vehicle.valid then
                          local unit = selected_unit.unit
                          local unit_type = unit_get_type(unit)
                          local try_position = { -- random spaced in selected area
                              x = math.floor(event.area.left_top.x + (event.area.right_bottom.x - event.area.left_top.x) * (math.random(100)/100)),
                              y = math.floor(event.area.left_top.y + (event.area.right_bottom.y - event.area.left_top.y) * (math.random(100)/100))
                          }

                          if unit_type.is_miner
                            and util.vectors_delta_length(unit.vehicle.position, try_position) < 100
                            and #(unit.vehicle.surface.find_entities_filtered{type="tree",
                              area={{try_position.x -1.5, try_position.y -1.5}, {try_position.x +1.5, try_position.y +1.5}}}) > 0 then
                              -- miners should ignore trees but buffer does not
                              unit_set_command({
                                  unit = selected_unit.unit,
                                  target_position_direct = try_position
                              })
                          elseif #selected_units == 1 then
                            try_position = { -- middle position
                                x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
                                y = (event.area.left_top.y + event.area.right_bottom.y) / 2
                            }
                            unit_set_command({
                                    unit = unit,
                                    target_position = try_position
                                })
                          else
                              local safe_position = unit.vehicle.surface.find_non_colliding_position(unit_type.buffer, try_position, 20, 2)
                              safe_position = safe_position or try_position
                              massed_data[unit.unit_id] = {
                                  unit = unit,
                                  buffer = unit.vehicle.surface.create_entity{name = unit_type.buffer, position = safe_position}, -- reserve the space
                                  target_position = safe_position,
                              }
                          end

                      end
                  end
                  for _, move_data in pairs(massed_data) do
                      move_data.buffer.destroy()
                      unit_set_command({
                              unit = move_data.unit,
                              target_position = move_data.target_position
                          })
                  end
                end
                -- check to see if the selection contains inactive units
                -- check to see if the selection contains unpowered units
                local inactives = 0
                local unpowered = 0
                for _, selected_unit in pairs(selected_units) do
                  if selected_unit.unit then
                    if unit_is_active(selected_unit.unit) == false then
                      inactives = inactives + 1
                    end
                    if unit_get_energy(selected_unit.unit) <= 0 then
                      unpowered = unpowered + 1
                    end
                  end
                end
                if inactives > 0 then
                  player.print({"aai-programmable-vehicles.command-inactive-vehicles"})
                end
                if unpowered > 0 then
                  player.print({"aai-programmable-vehicles.command-unpowered-vehicles"})
                end
            end
        else
            -- select
            local area = event.area
            -- non-zero
            area.left_top.x = area.left_top.x - 0.01
            area.left_top.y = area.left_top.y - 0.01
            area.right_bottom.x = area.right_bottom.x + 0.01
            area.right_bottom.y = area.right_bottom.y + 0.01
            local select_entities = player.surface.find_entities_filtered{
                area = area,
                type = "car",
                force = player.force
            }
            local units = {}
            for _, entity in pairs(select_entities) do
                local unit = unit_find_from_entity(entity)
                if unit then
                    table.insert(units, unit)
                end
            end
            remote_select_units(player, units)
        end
    end
end


local function remote_on_player_cursor_stack_changed(event)
    local player = game.players[event.player_index]
    if not (player.cursor_stack.valid_for_read and player.cursor_stack.name == "unit-remote-control") then
        remote_deselect_units(player)
    end
end

local function remote_on_tick()
    if global.player_selected_units then
        for _, selected_units in pairs(global.player_selected_units) do
            for unit_id, selected_unit in pairs(selected_units) do
                if (selected_unit.unit and selected_unit.unit.vehicle) and selected_unit.unit.vehicle.valid then
                    if selected_unit.selection and selected_unit.selection.valid then
                        selected_unit.selection.teleport(selected_unit.unit.vehicle.position)
                    else
                        selected_unit.selection = selected_unit.unit.vehicle.surface.create_entity{
                            name = "unit-selection",
                            position = selected_unit.unit.vehicle.position,
                        }
                    end
                    selected_unit.unit.show_path = true
                else
                    if selected_unit.selection and selected_unit.selection.valid then
                        selected_unit.selection.destroy()
                        selected_unit.selection = nil
                    end
                    selected_unit.unit.show_path = nil
                    path_indicator_clear(selected_unit.unit)
                    selected_units[unit_id] = nil
                end
            end
        end
    end
end

local function unit_on_player_exit_vehicle(player)
  if (not (player and player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "unit-remote-control"))
    and not player.vehicle then
      remote_deselect_units(player)
  end
end

local function unit_on_player_enter_vehicle(player)
    local vehicle = player.vehicle
    -- if entering a ghost or solid version then replace with a whole version
    local unit = unit_find_from_entity(vehicle)
    -- TODO: show vehicle UI
    if unit then
      if unit.active_state == "auto_active" then
        unit.active_state = "auto_inactive"
        unit.mode = "passsive"
        unit_update_mode(unit)
      else
        if unit.mode ~= "passsive" then
          -- tell player how to take control
          local unit_type = unit_get_type(unit)
          if unit.vehicle and unit.vehicle.valid and unit.vehicle.get_passenger() and unit.vehicle.get_passenger().player then
            unit.vehicle.get_passenger().player.print({"aai-programmable-vehicles.enter-ai-vehicle"})
          end
        end
      end
      if (not global.player_selected_units)
        or (not global.player_selected_units[player.index])
        or #global.player_selected_units[player.index] < 1 then
          remote_select_units(player, {unit})
      end
    end
end

local function unit_manage_entity(entity, signals)
    for _, unit_type in pairs(global.unit_types) do
        if entity.name == unit_type.vehicle_whole then
            unit_manage_new(entity, signals)
        end
    end
end

local function unit_tick()

    for _, entity in pairs(global.unit.entities_pending_manage) do
        unit_manage_new(entity)
    end

    for _,unit in pairs(global.unit.units) do
        if not unit.vehicle or (unit.vehicle and not unit.vehicle.valid) then
            unit_unmanage(unit)
        end
    end

    for _,unit in pairs(global.unit.units) do
        if unit.vehicle and unit.vehicle.valid then
            unit_update_mode(unit)
            unit_update_state(unit)
        end
    end
end

-- control main

local function on_tick()

    -- run temporary tasks, must be valid or die
    if global.tick_tasks then
        for _, task in pairs(global.tick_tasks) do
            local valid = false
            if task.name == "editing_unit_data" then

                local player = game.players[task.player_index]
                local unit = unit_by_unit_id(task.unit_id)
                if player and player.connected and unit then
                    if task.interface and task.interface.valid then
                        set_unit_data_from_combinator(task.unit_id, task.interface)
                        if player.opened == task.interface then
                            valid = true
                        else
                            task.interface.destroy()
                        end
                    end
                else
                    if task.interface and task.interface.valid then
                        task.interface.destroy()
                    end
                end

            end
            if not valid then global.tick_tasks[task.task_id] = nil end
        end
    end

    unit_tick()
    struct_tick()
    remote_on_tick()

end

local function on_built_entity (event)
    unit_manage_entity(event.created_entity)
    struct_manage_entity(event.created_entity, event)
end

local function on_robot_built_entity (event)
    struct_manage_entity(event.created_entity, event)
end

local function on_entity_damaged (event)

  local vehicle = event.entity
  if event.entity.type ~= "car" then
    vehicle = nil
    if event.cause and event.cause.type == "car" then
      vehicle = event.cause
    end
  end
  if not vehicle then return end

  local unit = unit_find_from_entity(vehicle)

  if unit and unit.vehicle and unit.vehicle.valid then
    if unit.mode == "unit" then
      unit.navpath = nil -- drop navpath if crashing
    else
      local unit_type = unit_get_type(unit)
      if event.entity.type == "tree" then
        -- the vehicle will be slowed too much by hitting a tree
        -- can't modify speed here so record tree health and recover speed in stat update
        local tree_damage = unit_type.tree_damage
        local hp_remaining = event.entity.health - tree_damage
        if hp_remaining > 0 then
          event.entity.health = hp_remaining
        else
          unit.tree_overkill = -hp_remaining
          event.entity.die()
        end
      else
        -- not a tree
        unit_nudge(unit)
        if (not (unit_type.is_flying or unit_type.collides_with_ground))
        and (unit.mode == "vehicle_move_to" or unit.mode == "vehicle_move_to_temp")
        and (unit.safe_target_position or unit.target_position)
        and util.vectors_delta_length((unit.safe_target_position or unit.target_position), unit.vehicle.position) > navigator_minimum_range then
            -- we may have crashed so direct might not be working
            -- go with pathfinder if possible
            unit.stuck = 0
            unit_reset_stuck(unit)
            unit_set_mode(unit, "unit")
        end
      end
    end
  end
end

local function on_entity_died (event)
    unit_on_entity_died(event)
    struct_unmanage_entity(event.entity)
end

local function on_player_driving_changed_state(event)
    if event.player_index then
        local player = game.players[event.player_index]
        if player then
          if player.vehicle then
              unit_on_player_enter_vehicle(player)
          else
              unit_on_player_exit_vehicle(player)
          end
        end
    end
end

local function on_gui_click(event)
    remote_on_gui_click(event)
end

local function on_preplayer_mined_item(event)
    struct_unmanage_entity(event.entity)
end

local function on_robot_pre_mined(event)
    struct_unmanage_entity(event.entity)
end

-- implement custom events

local function on_entity_deployed(data) -- from structures remote
    unit_manage_entity(data.entity, data.signals)
end

local function on_dolly_moved(event)
    if event.moved_entity and event.moved_entity.valid then
        -- prevent turret creep
        event.name = "on_dolly_moved"
        struct_construction_denial(event.moved_entity, event)
    end
end

--player object as optional, when not present loop through all players
--insert could still fail to insert because of a full inventory, but at this point the player should have
--enough raw resources to make them
local function player_insert_items(event)
    local player = event and game.players[event.player_index]

    if player then
        if settings.startup["start-with-unit-remote-control"] and settings.startup["start-with-unit-remote-control"].value == true then
          for _, item in pairs(starting_items) do
              local inserted = 0
              if defines.inventory.player_quickbar and player.get_inventory(defines.inventory.player_quickbar) then
                local inv = player.get_inventory(defines.inventory.player_quickbar)
                inserted = inv.insert(item)
              end
              if inserted == 0 then
                player.insert(item)
              end
          end
        end
        player.color = {r=math.random()*255, g=math.random()*255, b=math.random()*255}
    else
        for _, p in pairs(game.players) do
            if settings.startup["start-with-unit-remote-control"] and settings.startup["start-with-unit-remote-control"].value == true then
              for _, item in pairs(starting_items) do
                  local inserted = 0
                  if defines.inventory.player_quickbar and p.get_inventory(defines.inventory.player_quickbar) then
                    local inv = p.get_inventory(defines.inventory.player_quickbar)
                    inserted = inv.insert(item)
                  end
                  if inserted == 0 then
                    p.insert(item)
                  end
              end
            end
            p.color = {r=math.random()*255, g=math.random()*255, b=math.random()*255}
        end
    end
end

-------------------------------------------------------------------------------
--[[EVENTS]]--
-------------------------------------------------------------------------------

script.on_event(defines.events.on_tick, on_tick)


script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_robot_built_entity)

script.on_event(defines.events.on_entity_damaged, on_entity_damaged)
script.on_event(defines.events.on_entity_died, on_entity_died)
script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)

script.on_event(defines.events.on_player_selected_area, remote_on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, remote_on_player_selected_area)

script.on_event(defines.events.on_player_cursor_stack_changed, remote_on_player_cursor_stack_changed)

script.on_event(defines.events.on_pre_player_mined_item, on_preplayer_mined_item)
script.on_event(defines.events.on_robot_pre_mined, on_robot_pre_mined)

script.on_event(defines.events.on_player_created, player_insert_items)
script.on_event(defines.events.on_gui_click, on_gui_click)


-------------------------------------------------------------------------------
--[[INIT]]--
-------------------------------------------------------------------------------
local function on_configuration_changed(data)
    global.fuel_items = get_fuel.build()
    --global.prototypes_require_load = true
    global.unit_types = global.unit_types or {}
    global.unit_types_by_signal = global.unit_types_by_signal or {}
    global.unit_mineable_resources = global.unit_mineable_resources or {}
    unit_load_prototypes()

    global.version = global.version or 0
    if data.mod_changes and data.mod_changes["aai-programmable-vehicles"] then
        if global.version ~= version then
            if global.version < 000108 then
                update_unit_types_ids()
            end
            if global.version < 000310 then
                -- depots are running 3 time more than required
                -- they are going per entity not per depot
                -- updated depots to new struct structure

                if global.vehicle_depot then
                  global.structures = global.structures or {}
                  global.structure_unit_numbers = global.structure_unit_numbers or {}
                  global.next_struct_id = global.next_struct_id or 1
                  for _, struct in pairs(global.vehicle_depot) do

                      struct.type = "vehicle-depot"
                      struct.struct_id = global.next_struct_id
                      global.next_struct_id = global.next_struct_id + 1
                      global.structures[struct.struct_id] = struct

                      if struct.entity and struct.entity.valid then
                        global.structure_unit_numbers[struct.entity.unit_number] = struct.struct_id
                      end

                      struct.sub = struct.sub or {}
                      if struct.sub.base and struct.sub.base.valid then
                        global.structure_unit_numbers[struct.sub.base.unit_number] = struct.struct_id
                      end
                      if struct.sub.base and struct.sub.base.valid then
                        global.structure_unit_numbers[struct.sub.base.unit_number] = struct.struct_id
                      end
                      if struct.sub.combinator and struct.sub.combinator.valid then
                        global.structure_unit_numbers[struct.sub.combinator.unit_number] = struct.struct_id
                      end

                  end
                  global.vehicle_depot = nil
                end


                -- find and manage deployers
                for _, surface in pairs(game.surfaces) do
                    for _, entity in pairs(surface.find_entities_filtered{name="vehicle-deployer"}) do
                        struct_manage_entity(entity)
                    end
                end
            end
            if global.version < 000324 then
                if global.unit and global.unit.units then
                    for _, unit in pairs(global.unit.units) do
                      if unit.data then
                        local unit_type = unit_get_type(unit)
                        if unit_type.is_hauler then
                            signal_container_add(unit.data, {type = "virtual", name="signal-minimum-fuel"}, 800)
                        end
                      end
                    end
                end
            end
            --unit_cleanup_entities()
            global.version = version
        end
    end

    -- enable any recipes that should be unlocked.
    -- mainly required for entity-update-externals as a migration file won't work
    for _, force in pairs(game.forces) do
      for _, tech in pairs(force.technologies) do
        if tech.researched then
          for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" and force.recipes[effect.recipe] then
              force.recipes[effect.recipe].enabled = true
            end
          end
        end
      end
    end

end
script.on_configuration_changed(on_configuration_changed)

local function on_init()
    if remote.interfaces["picker"] and remote.interfaces["picker"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("picker", "dolly_moved_entity_id"), on_dolly_moved)
    end

    global.fuel_items = get_fuel.build()

    global.unit = global.unit or {}
    -- delayed buffer of on_built_entity so that the script can handle assignment if responsible for creation
    global.unit.entities_pending_manage = global.unit.entities_pending_manage or {}
    -- convert a unit_number to a unit_id
    global.unit.unit_numbers = global.unit.unit_numbers or {}
    global.unit.next_unit_id = global.unit.next_unit_id or 1
    -- this is units by type, not a list of unit types
    global.unit.unit_types = global.unit.unit_types or {}
    global.unit_types = global.unit_types or {}
    global.unit_types_by_signal = global.unit_types_by_signal or {}
    global.unit_mineable_resources = global.unit_mineable_resources or {}

    unit_load_prototypes()
    for _, unit_type in pairs(global.unit_types) do
        -- array
        global.unit.unit_types[unit_type.name] = global.unit.unit_types[unit_type.name] or {}
    end
    global.unit.units = global.unit.units or {} -- by unit_id

    player_insert_items()
end
script.on_init(on_init)

local function on_load()
    if remote.interfaces["picker"] and remote.interfaces["picker"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("picker", "dolly_moved_entity_id"), on_dolly_moved)
    end
end
script.on_load(on_load)

-------------------------------------------------------------------------------
--[[REMOTE]]--
-------------------------------------------------------------------------------
remote.add_interface(
    "aai-programmable-vehicles",
    {
        write_global = function() game.write_file("AAI/vehicles.global.lua", serpent.block(global, {comment=false, sparse=true, nocode=true}), false) end,
        get_units = function() return global.unit.units end, -- returns table of units by unit id
        get_unit_count_by_type = unit_get_count_by_type,
        get_unit_by_signal = unit_find_from_signal, -- {signal = SignalID, count = count} returns unit
        get_unit_by_entity = unit_find_from_entity,
        on_entity_deployed = on_entity_deployed,
        --data.unit_id or data.unit
        --data.target_speed
        --data.target_angle(0-1)
        --data.target_position
        -- returns bool of unit found
        set_unit_command = unit_set_command,
        set_unit_data = unit_set_data,

    }
)
