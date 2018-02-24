require "util"

function create_settings_gui(player)
    local ps = player_settings(player.index)
    if ps.settings_gui then return end
    ps.settings_gui = player.gui.center.add{type="frame",
                                            name="beltplanner_config",
                                            direction="vertical",
                                            caption={"config-gui-caption"}}

    --need to stuff things into a flow even though the frame's direction already is vertical
    --otherwise multiple elements still get placed in the same row if they're small enough
    local config_flow = ps.settings_gui.add{type="flow",
                                            direction="vertical",
                                            name="beltplanner_config_flow"}

    local planner_type_flow = config_flow.add{type="flow", name="beltplanner_planner_type_flow"}
    planner_type_flow.add{type="label",
                          name="beltplanner_label_planner_type",
                          caption={"label-planner-type"}}
    planner_type_flow.add{type="radiobutton",
                          name="beltplanner_radiobutton_planner_type_belt",
                          state=(ps.planner_type == "belt"),
                          caption={"radiobutton-planner-type-belt"}}
    planner_type_flow.add{type="radiobutton",
                          name="beltplanner_radiobutton_planner_type_pipe",
                          state=(ps.planner_type == "pipe"),
                          caption={"radiobutton-planner-type-pipe"}}

    config_flow.add{type="radiobutton",
                    name="beltplanner_radiobutton_avoidance_negative",
                    state=(ps.underground_avoidance == "negative"),
                    caption={"radiobutton-avoidance-negative"}}
    config_flow.add{type="radiobutton",
                    name="beltplanner_radiobutton_avoidance_none",
                    state=(ps.underground_avoidance == "none"),
                    caption={"radiobutton-avoidance-none"}}
    config_flow.add{type="radiobutton",
                    name="beltplanner_radiobutton_avoidance_medium",
                    state=(ps.underground_avoidance == "medium"),
                    caption={"radiobutton-avoidance-medium"}}
    config_flow.add{type="radiobutton",
                    name="beltplanner_radiobutton_avoidance_high",
                    state=(ps.underground_avoidance == "high"),
                    caption={"radiobutton-avoidance-high"}}

    local length_flow = config_flow.add{type="flow", name="beltplanner_length_flow"}
    length_flow.add{type="label",
                    name="beltplanner_label_length_pre",
                    caption={"label-length-pre"}}
    length_flow.add{type="radiobutton",
                name="beltplanner_radiobutton_short",
                state=(ps.underground_length == "short"),
                caption={"radiobutton-length-short"}}
    length_flow.add{type="radiobutton",
                name="beltplanner_radiobutton_long",
                state=(ps.underground_length == "long"),
                caption={"radiobutton-length-long"}}
    length_flow.add{type="label",
                    name="beltplanner_label_length_post",
                    caption={"label-length-post"}}

    config_flow.add{type="checkbox",
                    name="beltplanner_checkbox_corner_penalty",
                    state=ps.corner_penalty,
                    caption={"checkbox-corner-penalty"}}
    config_flow.add{type="checkbox",
                    name="beltplanner_checkbox_avoid_belt_endings",
                    state=ps.avoid_belt_endings,
                    caption={"checkbox-avoid-belt-endings"}}
    config_flow.add{type="checkbox",
                    name="beltplanner_checkbox_avoid_resources",
                    state=ps.avoid_resources,
                    caption={"checkbox-avoid-resources"}}

    local accept_underground_flow = config_flow.add{type="flow",
                                                    name="beltplanner_accept_underground_flow"}
    accept_underground_flow.add{type="label",
                                name="beltplanner_label_accept_underground",
                                caption={"label-accept-underground"}}
    accept_underground_flow.add{type="checkbox",
                                name="beltplanner_checkbox_underground_entrance",
                                state=ps.underground_entrance,
                                caption={"checkbox-underground-entrance"}}
    accept_underground_flow.add{type="checkbox",
                                name="beltplanner_checkbox_underground_exit",
                                state=ps.underground_exit,
                                caption={"checkbox-underground-exit"}}

    local steps_flow = config_flow.add{type="flow", name="beltplanner_steps_flow"}
    steps_flow.add{type="label",
                    name="beltplanner_config_label_steps",
                    caption={"label-steps-per-tick"}}
    local steps_input = steps_flow.add{type="textfield",
                                       name="beltplanner_config_value_steps",
                                       text=tostring(ps.steps_per_tick)}
    steps_input.style.minimal_width = 50
    steps_input.style.maximal_width = 50

    player.opened = ps.settings_gui
end

function create_start_gui(player, start_position, last_end_position)
    local gui = player.gui.top.add{type="frame",
                                   name="beltplanner_gui",
                                   direction="vertical",
                                   caption={"gui-caption"}}
    local tab = gui.add{type="table",
                        name="beltplanner_table_start",
                        column_count=2}
    tab.add{type="label",
            name="beltplanner_label_start_position",
            caption={"label-start-position",
                      math.floor(start_position.x),
                      math.floor(start_position.y)}}
    tab.add{type="button",
            name="beltplanner_button_remove_start",
            caption={"button-remove-start"},
            style="no-padding"}

    if last_end_position then
        tab.add{type="button",
                name="beltplanner_button_use_last_end",
                caption={"button-use-last-end", last_end_position.x, last_end_position.y},
                style="no-padding"}
    else
        tab.add{type="label",
                name="beltplanner_label_select_end",
                caption={"label-select-end"}}
    end

    tab.add{type="button",
            name="beltplanner_button_settings",
            caption={"button-settings"},
            style="no-padding"}
end

function create_running_gui(state)
    local player = state.player
    local ps = player_settings(player.index)
    local gui = player.gui.top.beltplanner_gui
    if gui then
        gui.beltplanner_table_start.destroy()
    else
        --this happens when updating from an old version while pathfinder is running
        gui = player.gui.top.add{type="frame",
                                 name="beltplanner_gui",
                                 direction="vertical",
                                 caption={"gui-caption"}}
    end

    local flow = gui.add{type="flow",
                         name="beltplanner_flow_running",
                         direction="vertical"}
    flow.add{type="label",
             name="beltplanner_label_position_info",
             caption={"label-position-info",
                      state.start.x,
                      state.start.y,
                      state.goal.x,
                      state.goal.y,
                      state:h(state.start)}}
    flow.add{type="label",
             name="beltplanner_label_nodes_info",
             caption={"label-nodes-info",
                      state.open_set.size,
                      state.nodes_visited,
                      state.open_set.heap[1].value}}
    local steps_flow = flow.add{type="flow", name="beltplanner_flow_steps"}
    steps_flow.add{type="label",
                   name="beltplanner_label_steps_per_tick",
                   caption={"label-steps-per-tick"}}
    local steps_input = steps_flow.add{type="textfield",
                                       name="beltplanner_textfield_steps",
                                       text=tostring(ps.steps_per_tick)}
    steps_input.style.minimal_width = 50
    steps_input.style.maximal_width = 50
    steps_flow.add{type="button",
                   name="beltplanner_button_abort",
                   caption={"button-abort"},
                   style="no-padding"}
end

function update_running_gui(state)
    state.player.gui.top.beltplanner_gui.beltplanner_flow_running.beltplanner_label_nodes_info.caption =
        {"label-nodes-info", state.open_set.size, state.nodes_visited, state.open_set.heap[1].value}
end

function count_underground_sections(path)
    local n = 0
    for _, v in pairs(path) do
        if is_down(v.belt_type) then n = n + 1 end
    end
    return n
end

function next_start_pos(state)
    local last_belt = state.path[1]
    if is_up(last_belt.belt_type) then
        --need to advance the next start position by one tile so the
        --underground exit does not get removed again
        local tmp_pos = util.moveposition({last_belt.position.x,
                                           last_belt.position.y},
                                          last_belt.direction, 1)
        local next_pos = {x=tmp_pos[1], y=tmp_pos[2]}
        if state.surface.can_place_entity{name="beltplanner", position=next_pos} then
            return next_pos
        else
            return nil
        end
    else
        return last_belt.position
    end
end

function create_finished_gui(state)
    local player = state.player
    local ps = player_settings(player.index)
    local gui = player.gui.top.beltplanner_gui
    gui.beltplanner_flow_running.destroy()
    local flow = gui.add{type="flow",
                         name="beltplanner_flow_finished",
                         direction="vertical"}
    flow.add{type="label",
             name="beltplanner_label_position_info",
             caption={"label-position-info",
                      state.start.x,
                      state.start.y,
                      state.goal.x,
                      state.goal.y,
                      state:h(state.start)}}

    local underground_sections = state.path and count_underground_sections(state.path)

    flow.add{type="label",
             name="beltplanner_label_result_info",
             caption=(state.path and {"label-result-info",
                                      #state.path,
                                      underground_sections,
                                      (underground_sections == 1 and "" or "s")}
                                 or {"no-path-found"})}

    if state.path then
        if state.ps.planner_type == "belt" then
            local type_flow = flow.add{type="flow", name="beltplanner_flow_type"}
            type_flow.add{type="radiobutton",
                        name="beltplanner_radiobutton_speed_basic",
                        state=(ps.belt_speed==""),
                        caption={"radiobutton-basic"}}

            if state.player.force.technologies["logistics-2"].researched then
                type_flow.add{type="radiobutton",
                            name="beltplanner_radiobutton_speed_fast",
                            state=(ps.belt_speed=="fast-"),
                            caption={"radiobutton-fast"}}
            end

            if state.player.force.technologies["logistics-3"].researched then
                type_flow.add{type="radiobutton",
                            name="beltplanner_radiobutton_speed_express",
                            state=(ps.belt_speed=="express-"),
                            caption={"radiobutton-express"}}
            end

            flow.add{type="checkbox",
                     name="beltplanner_checkbox_reversed",
                     state=ps.reversed,
                     caption={"checkbox-reversed"}}
        end

        local continuous_checked
        if ps.continuous_build then
            local next_pos = next_start_pos(state)
            if next_pos then
                continuous_checked = true
            else
                continuous_checked = false
                state.player.print({"no-space-for-new-start"})
            end
        else
            continuous_checked = false
        end

        flow.add{type="checkbox",
                name="beltplanner_checkbox_continuous",
                state=continuous_checked,
                caption={"checkbox-continuous"}}
    end

    local button_flow = flow.add{type="flow", name="beltplanner_flow_button"}

    if state.path then
        button_flow.add{type="button",
                        name="beltplanner_button_create_ghosts",
                        caption={"button-create-ghosts"},
                        style="no-padding"}
    end

    button_flow.add{type="button",
                    name="beltplanner_button_undo",
                    caption={"button-undo"},
                    style="no-padding"}

    button_flow.add{type="button",
                    name="beltplanner_button_cancel",
                    caption={"button-cancel"},
                    style="no-padding"}
end
