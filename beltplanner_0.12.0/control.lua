require "astar"
require "gui"

default_steps_per_tick = 25

function player_settings(player_index)
    if not global.beltplanner_settings then global.beltplanner_settings = {} end
    local s = global.beltplanner_settings
    if not s[player_index] then
        s[player_index] =
        {
            underground_avoidance = "medium",
            underground_length = "short",
            corner_penalty = true,
            underground_entrance = true,
            underground_exit = true,
            steps_per_tick = default_steps_per_tick,
            belt_speed = "",
            continuous_build = false,
            avoid_belt_endings = true,
            avoid_resources = false,
            planner_type = "belt",
            reversed = false,
        }
    end
    return s[player_index]
end

script.on_init(function()
    --this also seems to run when the mod is added to an existing save
    global.beltplanner_start = {}
    global.beltplanner_state = {}
    global.finished_state = {}
end)

function update_0_2_to_0_3()
    global.beltplanner_running = {}
    if global.beltplanner_settings then
        for _, ps in pairs(global.beltplanner_settings) do
            ps.steps_per_tick = default_steps_per_tick
        end
    end
    return "0.3.0"
end

update_from_version = {
    ["0.1.0"] = function()
        --nothing to do anymore. this used to enable beltplanner-config which
        --doesn't exist in the current version.
        return "0.2.0"
    end,
    ["0.2.0"] = update_0_2_to_0_3,
    ["0.2.1"] = update_0_2_to_0_3,
    ["0.3.0"] = function()
        global.beltplanner_running = nil
        global.beltplanner_state = {}
        return "0.3.1"
    end,
    ["0.3.1"] = function()
        --belt_type definitions have changed, abort running path finding attempts.
        --not tested. will probably affect zero people.
        for player_index, state in pairs(global.beltplanner_state) do
            local p = game.players[player_index]
            p.gui.left.beltplanner_state.destroy()
        end
        global.beltplanner_state = {}
        script.on_event(defines.events.on_tick, nil)
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.underground_entrance = true
                ps.underground_exit = true
            end
        end
        return "0.4.0"
    end,
    ["0.4.0"] = function()
        global.finished_state = {}
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.continuous_build = false
            end
        end
        for _, force in pairs(game.forces) do
            if force.technologies["beltplanner"].researched then
                force.recipes["beltplanner"].enabled = true
            end
        end
        for player_index, state in pairs(global.beltplanner_state) do
            state.player.gui.left.beltplanner_state.destroy()
            create_running_gui(state)
        end
        for player_index, player in pairs(game.players) do
            if player.gui.center.beltplanner_config then
                player.gui.center.beltplanner_config.destroy()
                create_settings_gui(player)
            end
        end
        return "0.5.0"
    end,
    ["0.5.0"] = function()
        --nothing to do. just a reminder that it exists
        return "0.5.1"
    end,
    ["0.5.1"] = function()
        for _, state in pairs(global.beltplanner_state) do
            state.candidate_entity = "beltplanner"
        end
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.avoid_belt_endings = true
                ps.avoid_resources = false
            end
        end
        return "0.6.0"
    end,
    ["0.6.0"] = function()
        for _, state in pairs(global.beltplanner_state) do
            state.max_underground_length = max_underground_length_belt
        end
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.planner_type = "belt"
            end
        end
        return "0.7.0"
    end,
    ["0.7.0"] = function()
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.belt_speed = ""
            end
        end
        return "0.8.0"
    end,
    ["0.8.0"] = function()
        if global.beltplanner_settings then
            for _, ps in pairs(global.beltplanner_settings) do
                ps.reversed = false
            end
        end
        return "0.9.0"
    end,
    ["0.9.0"] = function()
        for index, start in pairs(global.beltplanner_start) do
            global.beltplanner_start[index] = {entity=start, position=start.position}
        end
        return "0.9.1"
    end,
    ["0.9.1"] = function()
        for player_index, state in pairs(global.beltplanner_state) do
            if not state.belt_endings then
                --this fixes functionality introduced in v0.6.0. oh well.
                state.belt_endings = position_table:new()
            end
        end
        return "0.10.0"
    end,
    ["0.10.0"] = function()
        --need to re-insert start marker entities into the beltplanner_start table
        --seems like stuff got rejiggled internally now that decorative entities aren't a thing anymore
        --and suddenly all the references are invalid...
        for _, start in pairs(global.beltplanner_start) do
            for _, surface in pairs(game.surfaces) do
                --didn't save the surface, wasn't needed previously...
                --being a bit optimistic here, there probably won't be multiple start markers
                --on the same position on different surfaces.
                local entity = surface.find_entity("beltplanner", {start.position.x+.5, start.position.y+.5})
                if entity then
                    start.entity = entity
                    break
                end
                --if it's not found, just hope for the best
            end
        end
        return "0.11.0"
    end,
    ["0.11.0"] = function()
        --nothing to do. wonder if any of the above is still useful.
        return "0.12.0"
    end,
}

script.on_configuration_changed(function(event)
    if event.mod_changes and event.mod_changes.beltplanner then
        local bp = event.mod_changes.beltplanner
        if not bp.old_version then return end
        local ver = bp.old_version
        while ver ~= "0.12.0" do
            ver = update_from_version[ver]()
        end
    end
end)

function start_path_finding(start, end_position, player)
    local ps = player_settings(player.index)

    if ps.avoid_resources then
        local pos = {math.floor(end_position.x), math.floor(end_position.y)}
        --start and end are on the same surface, we already made sure of that
        local end_res = start.surface.find_entities_filtered{type="resource",
            area={pos, {pos[1]+1, pos[2]+1}}}
        pos = {math.floor(start.position.x), math.floor(start.position.y)}
        local start_res = start.surface.find_entities_filtered{type="resource",
            area={pos, {pos[1]+1, pos[2]+1}}}
        if next(end_res) or next(start_res) then
            player.print({"marker-on-resource", {"checkbox-avoid-resources"}})
            player.cursor_stack.set_stack{name="beltplanner"}
            return
        end
    end

    if ps.settings_gui == player.opened then
        player.opened = nil
    end

    local state = path_state:new(start.position, end_position, player)
    global.beltplanner_state[player.index] = state
    script.on_event(defines.events.on_tick, path_tick)
    start.destroy()
    global.beltplanner_start[player.index] = nil
    create_running_gui(state)
end

script.on_event(defines.events.on_built_entity, function(event)
    local e = event.created_entity
    local p = game.players[event.player_index]

    if e.name ~= "beltplanner" then return end
    e.destructible = false

    if global.beltplanner_state[event.player_index] then
        assert(p.gui.top.beltplanner_gui.beltplanner_flow_running)
        p.print({"path-finder-running"})
        p.cursor_stack.set_stack{name="beltplanner"}
        e.destroy()
        return
    end

    if global.finished_state[event.player_index] then
        assert(p.gui.top.beltplanner_gui.beltplanner_flow_finished)
        p.cursor_stack.set_stack{name="beltplanner"}
        p.print({"already-finished"})
        e.destroy()
        return
    end

    local start = global.beltplanner_start[event.player_index]
    if start then
        assert(p.gui.top.beltplanner_gui.beltplanner_table_start)
        if start.entity.surface ~= e.surface then
            p.print({"cross-surface"})
            p.cursor_stack.set_stack{name="beltplanner"}
            e.destroy()
            return
        end

        start_path_finding(start.entity, e.position, p)
        e.destroy()
    else
        assert(not p.gui.top.beltplanner_gui)
        p.cursor_stack.set_stack{name="beltplanner"}
        global.beltplanner_start[event.player_index] = {entity=e, position=e.position} --position needs to be saved separately in case entity becomes invalid so it can be restored
        create_start_gui(p, e.position)

        --[[the last path piece that is replaced by the new start marker in continuous
            build mode gets saved here so it can be restored in case the start marker
            gets removed again. needs to be cleared when start marker is placed manually. --]]
        player_settings(p.index).removed_ghost = nil
    end
end)

function direction_name(dir)
    return ({[defines.direction.north] = "up",
             [defines.direction.east]  = "right",
             [defines.direction.south] = "down",
             [defines.direction.west]  = "left",})[dir]
end

function place_preview(state)
    state.previews = {}
    for _, v in pairs(state.path) do
        local name = "beltplanner-arrow-"
                    ..(not is_flat(v.belt_type) and "ground-" or "")
                    ..direction_name(v.direction)
        local preview = state.surface.create_entity{name=name, position=v.position}
        table.insert(state.previews, preview)
    end
end

function remove_preview(state)
    if not state.previews then return end
    for _, v in pairs(state.previews) do
        if v.valid then v.destroy() end
    end
end

function recreate_start_marker(state, position, last_end_position)
    state.ps.last_end_position = last_end_position
    local start = state.surface.create_entity{name="beltplanner", position=position}
    global.beltplanner_start[state.player.index] = {entity=start, position=position}
    state.player.gui.top.beltplanner_gui.destroy()
    create_start_gui(state.player, start.position, last_end_position)
end

function place_path(state)
    if state.ps.planner_type == "belt" then
        place_belts(state)
    else
        assert(state.ps.planner_type == "pipe")
        place_pipes(state)
    end
end

function place_belts(state)
    local name
    local underground_type
    local belt_speed = state.ps.belt_speed
    local reversed = state.ps.reversed
    local direction

    for k, v in pairs(state.path) do
        direction = reversed and util.oppositedirection(v.direction) or v.direction

        if reversed then
            --need to fix corners
            local next_belt = state.path[k+1]
            if next_belt and next_belt.direction ~= v.direction then
                --the current belt piece is a corner, so we need to turn it around
                direction = util.oppositedirection(next_belt.direction)
            end
        end

        if is_flat(v.belt_type) then
            name = belt_speed.."transport-belt"
            underground_type = nil
        elseif is_down(v.belt_type) then
            name = belt_speed.."underground-belt"
            underground_type = reversed and "output" or "input"
        else
            --assert(is_up(v.belt_type))
            name = belt_speed.."underground-belt"
            underground_type = reversed and "input" or "output"
        end
        state.surface.create_entity{name="entity-ghost",
                                    inner_name=name,
                                    expires=false,
                                    position=v.position,
                                    direction=direction,
                                    force=state.player.force,
                                    type=underground_type}
    end
end

function place_pipes(state)
    local name
    local direction
    for _, v in pairs(state.path) do
        if is_flat(v.belt_type) then
            name = "pipe"
            direction = nil
        elseif is_down(v.belt_type) then
            name = "pipe-to-ground"
            direction = util.oppositedirection(v.direction)
        else
            --assert(is_up(v.belt_type))
            name = "pipe-to-ground"
            direction = v.direction
        end
        state.surface.create_entity{name="entity-ghost",
                                    inner_name=name,
                                    expires=false,
                                    position=v.position,
                                    direction=direction,
                                    force=state.player.force}
    end
end

function path_tick(event)
    for player_index, state in pairs(global.beltplanner_state) do
        state:find_path()
        if state.path or state.open_set:empty() then
            if state.path then place_preview(state) end
            create_finished_gui(state)
            assert(not global.finished_state[player_index])
            global.finished_state[player_index] = state
            global.beltplanner_state[player_index] = nil
        elseif event.tick % 60 == 0 then
            update_running_gui(state)
        end
    end

    if not next(global.beltplanner_state) then
        script.on_event(defines.events.on_tick, nil)
    end
end

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local e = event.entity
    if e.name ~= "beltplanner" then return end
    for owner_index, start_marker in pairs(global.beltplanner_start) do
        if start_marker.entity == e then
            local owner = game.players[owner_index]
            if owner_index ~= event.player_index then
                owner.print({"marker-removed-by",
                             math.floor(e.position.x),
                             math.floor(e.position.y),
                             game.players[event.player_index].name})
            end
            global.beltplanner_start[owner_index] = nil
            player_settings(owner).last_dir = nil
            e.destroy()
            owner.gui.top.beltplanner_gui.destroy()
            --config gui might still be open, but that's okay
            return
        end
    end
    assert(false)
end)

script.on_event(defines.events.on_research_finished, function(event)
    local logistics_num = string.match(event.research.name, "^logistics%-(%d)$")
    if logistics_num ~= "2" and logistics_num ~= "3" then return end
    local speed = logistics_num == "2" and "fast" or "express"
    for player_index, player in pairs(event.research.force.players) do
        if global.finished_state[player_index] then
            player.gui.top.beltplanner_gui
                          .beltplanner_flow_finished
                          .beltplanner_flow_type.add{type="radiobutton",
                                                     name="beltplanner_radiobutton_speed_"..speed,
                                                     state=false,
                                                     caption={"radiobutton-"..speed}}
        end
    end
end)

script.on_event(defines.events.on_mod_item_opened, function(event)
    if event.item.name == "beltplanner" then
        local p = game.players[event.player_index]

        if global.beltplanner_state[event.player_index] then
            assert(p.gui.top.beltplanner_gui.beltplanner_flow_running)
            p.print({"path-finder-running"})
        else
            create_settings_gui(p)
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local ps = player_settings(event.player_index)

    if event.gui_type == defines.gui_type.custom
    and event.element ~= nil
    and event.element == ps.settings_gui then
        ps.settings_gui.destroy()
        ps.settings_gui = nil
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local ps = player_settings(event.player_index)
    local ui = event.element.parent

    local name = event.element.name
    if name == "beltplanner_radiobutton_planner_type_belt" then
        ps.planner_type = "belt"
        ui.beltplanner_radiobutton_planner_type_pipe.state = false
    elseif name == "beltplanner_radiobutton_planner_type_pipe" then
        ps.planner_type = "pipe"
        ui.beltplanner_radiobutton_planner_type_belt.state = false
    elseif name == "beltplanner_radiobutton_avoidance_negative" then
        ps.underground_avoidance = "negative"
        ui.beltplanner_radiobutton_avoidance_none.state = false
        ui.beltplanner_radiobutton_avoidance_medium.state = false
        ui.beltplanner_radiobutton_avoidance_high.state = false
    elseif name == "beltplanner_radiobutton_avoidance_none" then
        ps.underground_avoidance = "none"
        ui.beltplanner_radiobutton_avoidance_negative.state = false
        ui.beltplanner_radiobutton_avoidance_medium.state = false
        ui.beltplanner_radiobutton_avoidance_high.state = false
    elseif name == "beltplanner_radiobutton_avoidance_medium" then
        ps.underground_avoidance = "medium"
        ui.beltplanner_radiobutton_avoidance_negative.state = false
        ui.beltplanner_radiobutton_avoidance_none.state = false
        ui.beltplanner_radiobutton_avoidance_high.state = false
    elseif name == "beltplanner_radiobutton_avoidance_high" then
        ps.underground_avoidance = "high"
        ui.beltplanner_radiobutton_avoidance_negative.state = false
        ui.beltplanner_radiobutton_avoidance_none.state = false
        ui.beltplanner_radiobutton_avoidance_medium.state = false
    elseif name == "beltplanner_radiobutton_short" then
        ps.underground_length = "short"
        ui.beltplanner_radiobutton_long.state = false
    elseif name == "beltplanner_radiobutton_long" then
        ps.underground_length = "long"
        ui.beltplanner_radiobutton_short.state = false
    elseif name == "beltplanner_radiobutton_speed_basic" then
        ps.belt_speed = ""
        if ui.beltplanner_radiobutton_speed_fast then
            ui.beltplanner_radiobutton_speed_fast.state = false
        end
        if ui.beltplanner_radiobutton_speed_express then
            ui.beltplanner_radiobutton_speed_express.state = false
        end
    elseif name == "beltplanner_radiobutton_speed_fast" then
        ps.belt_speed = "fast-"
        ui.beltplanner_radiobutton_speed_basic.state = false
        if ui.beltplanner_radiobutton_speed_express then
            ui.beltplanner_radiobutton_speed_express.state = false
        end
    elseif name == "beltplanner_radiobutton_speed_express" then
        ps.belt_speed = "express-"
        ui.beltplanner_radiobutton_speed_basic.state = false
        ui.beltplanner_radiobutton_speed_fast.state = false
    elseif name == "beltplanner_checkbox_corner_penalty" then
        ps.corner_penalty = event.element.state
    elseif name == "beltplanner_checkbox_avoid_belt_endings" then
        ps.avoid_belt_endings = event.element.state
    elseif name == "beltplanner_checkbox_avoid_resources" then
        ps.avoid_resources = event.element.state
    elseif name == "beltplanner_checkbox_underground_entrance" then
        ps.underground_entrance = event.element.state
    elseif name == "beltplanner_checkbox_underground_exit" then
        ps.underground_exit = event.element.state
    elseif name == "beltplanner_checkbox_continuous" then
        if not next_start_pos(global.finished_state[event.player_index]) then
            p.print({"no-space-for-new-start"})
            event.element.state = false
        else
            ps.continuous_build = event.element.state
        end
    elseif name == "beltplanner_checkbox_reversed" then
        ps.reversed = event.element.state
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local ps = player_settings(event.player_index)
    local ui = event.element.parent
    local p = game.players[event.player_index]

    local name = event.element.name
    if name == "beltplanner_button_abort" then
        local state = global.beltplanner_state[event.player_index]
        if not p.cursor_stack.valid_for_read then
            p.cursor_stack.set_stack{name="beltplanner"}
        else
            p.insert{name="beltplanner"}
        end
        recreate_start_marker(state, state.start, state.goal)
        global.beltplanner_state[event.player_index] = nil
        if not next(global.beltplanner_state) then
            script.on_event(defines.events.on_tick, nil)
        end
    elseif name == "beltplanner_button_remove_start" then
        local start = global.beltplanner_start[event.player_index].entity
        if ps.removed_ghost then
            --recreate ghost that was removed when new start marker was placed in continuous mode
            start.surface.create_entity(ps.removed_ghost)
            ps.removed_ghost = nil
        end
        start.destroy()
        global.beltplanner_start[event.player_index] = nil
        ps.last_dir = nil
        p.gui.top.beltplanner_gui.destroy()
    elseif name == "beltplanner_button_use_last_end" then
        p.remove_item{name="beltplanner"}
        start_path_finding(global.beltplanner_start[event.player_index].entity, ps.last_end_position, p)
    elseif name == "beltplanner_button_settings" then
        if ps.settings_gui ~= nil and ps.settings_gui == p.opened then
            p.opened = nil
        else
            create_settings_gui(p)
        end
    elseif name == "beltplanner_button_create_ghosts" then
        local state = global.finished_state[event.player_index]
        local next_pos = next_start_pos(state)
        local cont_mode = ps.continuous_build and next_pos
        if cont_mode and not p.cursor_stack.valid_for_read then
            p.cursor_stack.set_stack{name="beltplanner"}
        else
            p.insert{name="beltplanner"}
        end
        remove_preview(state)
        if cont_mode then
            ps.last_dir = state.path[1].direction
            recreate_start_marker(state, next_pos)
            if state.path[1].position == next_pos then
                --last piece of previously placed belt is not an underground exit
                --so it can be replaced by the new start marker
                --we still save it so it can be restored in case the new start marker is removed
                ps.removed_ghost = {
                    name="entity-ghost",
                    inner_name=ps.planner_type == "belt" and (ps.belt_speed.."transport-belt") or "pipe",
                    position=next_pos,
                    direction=ps.reversed and util.oppositedirection(ps.last_dir) or ps.last_dir,
                    force=p.force,
                }
                state.path[1] = nil
            end
        else
            ps.last_dir = nil
        end
        place_path(state)
        global.finished_state[event.player_index] = nil
        if not cont_mode then p.gui.top.beltplanner_gui.destroy() end
    elseif name == "beltplanner_button_undo" then
        local state = global.finished_state[event.player_index]
        if not p.cursor_stack.valid_for_read then
            p.cursor_stack.set_stack{name="beltplanner"}
        else
            p.insert{name="beltplanner"}
        end
        remove_preview(state)
        recreate_start_marker(state, state.start, state.goal)
        global.finished_state[event.player_index] = nil
    elseif name == "beltplanner_button_cancel" then
        p.insert{name="beltplanner"}
        remove_preview(global.finished_state[event.player_index])
        global.finished_state[event.player_index] = nil
        ps.last_dir = nil
        p.gui.top.beltplanner_gui.destroy()
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    local e = event.element

    if (e.name == "beltplanner_textfield_steps" or e.name == "beltplanner_config_value_steps")
    and e.text ~= "" then

        local ps = player_settings(event.player_index)
        local steps = tonumber(e.text)

        if steps == nil then
            steps = ps.steps_per_tick
        elseif steps < 1 then
            steps = 1
        elseif steps > 500 then
            steps = 500
        end

        e.text = steps
        ps.steps_per_tick = steps
    end
end)

script.on_load(function()
    --on_load runs before on_configuration_changed, so need to deal with missing global.beltplanner_state
    if global.beltplanner_state and next(global.beltplanner_state) then
        for player_index, state in pairs(global.beltplanner_state) do
            if not state.open_set.element_index then
                --must be from an old version, will be cleaned up in on_configuration_changed
                return
            end
            --oh seriously? this is not getting saved?
            setmetatable(state, path_state)
            setmetatable(state.open_set, minheap)
            setmetatable(state.closed_set, position_table)
            setmetatable(state.came_from, position_table)
            if state.belt_endings then
                setmetatable(state.belt_endings, position_table)
            end
            setmetatable(state.open_set.element_index, position_table)
        end
        script.on_event(defines.events.on_tick, path_tick)
    end
end)
