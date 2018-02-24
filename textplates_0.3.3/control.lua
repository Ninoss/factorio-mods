
local textplates = require("plate-types")
local support_legacy = textplates.support_legacy

local default_symbol = "square"

local Plate_type
local Next_symbol

local MOD_NAME = "textplates"

--
-- utility
--

local strmatch = string.match
local lower = string.lower

local function symbol_from_char(char)
  return char and textplates.symbol_by_char[lower(char)] or default_symbol
end

local is_textplate = {}
for _, material in pairs(textplates.materials) do
    for _, size in pairs(textplates.sizes) do
        is_textplate["textplate-" .. size .. "-" .. material] = true
    end
end

local symbol_id = {}
for id, symbol in pairs(textplates.symbols) do
    symbol_id[symbol] = id
end

local is_legacy = {}
for _, material in pairs(textplates.materials) do
    for _, size in pairs(textplates.sizes) do
        for _, symbol in pairs(textplates.symbols) do
            is_legacy[size .. "-" .. material .. "-" .. symbol] = true
        end
    end
end

--
-- GUI
--

local function show_gui(player, item_prefix)

    local player_index = player.index
    local plate_type = Plate_type[player_index]

    -- same gui already present
    if plate_type and plate_type == item_prefix then
        return
    end

    if player.gui.left.textplates then
        player.gui.left.textplates.destroy()
    end

    -- add the desired plate type UI
    local plate_frame = player.gui.left.add{type = "frame", name = 'textplates', caption = {"textplates.ui-title"}, direction = "vertical"}
    local plates_table = plate_frame.add{type ="table", name = "textplates_table", column_count  = 6, style = "textplates-table"}

    for _, symbol in pairs(textplates.symbols) do
        if symbol ~= "blank" then
            local sprite = "item/" .. item_prefix.."-"..symbol
            local name = "textplates-symbol-" .. symbol
            local style = symbol == default_symbol and "textplates-button-active" or "textplates-button"
            plates_table.add{type = "sprite-button", name = name, sprite = sprite, style = style, tooltip = {"textplates." .. symbol}}
        end
    end

    local plates_input_label = plate_frame.add{type ="label", name = "textplates_input_label", caption={"textplates.input-label"}}
    local plates_input_flow = plate_frame.add{type ="flow", name = "plates_input_flow", direction="horizontal"}
    local plates_input = plates_input_flow.add{type ="textfield", name = "textplates_input"}
    -- you can actually click anywhere to exit
    local plates_input_button = plates_input_flow.add{type ="sprite-button", name = "textplates_input_button", tooltip={"textplates.confirm"},
      style="edit_label_button", sprite="utility/confirm_slot"}

    Plate_type[player_index] = item_prefix
    Next_symbol[player_index] = default_symbol
end

local function hide_gui(player)
    if player.gui.left.textplates then
        player.gui.left.textplates.destroy()
    end
    Plate_type[player.index] = nil
end


local function on_player_cursor_stack_changed(event)
    local player = game.players[event.player_index]
    if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and is_textplate[player.cursor_stack.name] then
        show_gui(player, player.cursor_stack.name)
    else
        hide_gui(player)
    end
end

local function on_gui_click(event)
  local element = event.element
  local name = element.name
  if not name then return end
  local ok, symbol = string.match(name, "^(textplates%-symbol%-)(.*)$")
  if not ok then
      return
  end

  local parent = element.parent
  local player_index = event.player_index
  local next_symbol = Next_symbol[player_index]

  parent["textplates-symbol-" .. next_symbol].style = "textplates-button"
  element.style = "textplates-button-active"

  Next_symbol[player_index] = symbol
  parent.parent.plates_input_flow.textplates_input.text = ""
end

local function prepare_next_symbol(player_index, cut)
    local player = game.players[player_index]
    local gui = player.gui.left.textplates

    local plate_type = Plate_type[player_index]
    local next_symbol = Next_symbol[player_index]

    local name = "textplates-symbol-" .. next_symbol
    gui.textplates_table[name].style = "textplates-button"

    local text = gui.plates_input_flow.textplates_input.text
    if cut then
        text = string.sub(text, 2)
        gui.plates_input_flow.textplates_input.text = text
    end
    local first_char = string.sub(text, 1, 1)

    next_symbol = symbol_from_char(first_char)

    gui.textplates_table['textplates-symbol-' .. next_symbol].style = "textplates-button-active"
    Next_symbol[player_index] = next_symbol
end

local function on_gui_text_changed(event)
    if event.element.name == "textplates_input" then
         prepare_next_symbol(event.player_index, false)
    end
end

local function replace_ghost(entity, plate_type, symbol)
    local surface = entity.surface
    local position = entity.position
    local force = entity.force
    local ttl = entity.time_to_live
    entity.destroy()

    local variation = symbol_id[symbol]

    local new_entity = surface.create_entity{
        name = "entity-ghost",
        inner_name = plate_type,
        position = position,
        --variation = variation - 1,
        variation = variation, -- ghosts are offset?
        force = force,
        expires = false,
    }
    new_entity.time_to_live = ttl

    if event then
        event.textplates_handled = true
        event.created_entity = new_entity
        local original_mod = event.mod
        event.mod = MOD_NAME

        script.raise_event(defines.events.on_built_entity, event)

        -- restore, is this needed?
        event.mod = original_mod
        event.textplates_handled = nil
        event.created_entity = entity
    end

    return new_entity
end

local function on_build_ghost(player_index, plate_type, entity, event)
    replace_ghost(entity, plate_type, Next_symbol[player_index], event)
    prepare_next_symbol(player_index, true)
end

function handle_legacy_ghost(entity, event)
    local ghost_name = entity.ghost_name
    local size, material, symbol = strmatch(ghost_name, '^(%a*)%-(%a*)%-(.*)$')

    if not (size and material and symbol) then return end

    local plate_type = 'textplate-' .. size .. '-' .. material

    if not is_textplate[plate_type] then return end
    if not symbol_id[symbol] then return end

    if symbol == "blank" then
        -- get the symbol stored in the constant combinator
        local signal = entity.get_control_behavior().get_signal(1)

        if signal and signal.signal and signal.signal.type == 'item' then
            local size, material, signal_symbol = strmatch(signal.signal.name, '^(%a*)%-(%a*)%-(.*)$')
            local signal_plate_type = 'textplate-' .. size .. '-' .. material
            if signal_plate_type == plate_type and symbol_id[signal_symbol] then
                symbol = signal_symbol
            end
        end
    end

    replace_ghost(entity, plate_type, symbol, event)
end

local function on_built_entity (event)
    -- skip calls by ourself or ght-bluebuild
    if event.mod and (event.mod == MOD_NAME or event.mod == "ght-bluebuild") then return end

    local player_index = event.player_index
    local entity = event.created_entity
    if not (player_index and entity and entity.valid) then return end
    local player = game.players[player_index]
    local plate_type = Plate_type[player_index]

    if entity.name == "entity-ghost" and plate_type and entity.ghost_name == plate_type then
        return on_build_ghost(player_index, plate_type, entity, event)
    end

    if support_legacy then
        if entity.name == "entity-ghost" then
            return handle_legacy_ghost(entity, event)
        end
    end

    if not is_textplate[entity.name] then
        return
    end

    local next_symbol = Next_symbol[player_index]
    entity.graphics_variation = symbol_id[next_symbol]
    prepare_next_symbol(player_index, true)
end

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_built_entity, on_built_entity)

script.on_init(function()
    global.next_symbol = {}
    global.plate_type = {}

    Plate_type = global.plate_type
    Next_symbol = global.next_symbol
end)

local function convert_legacy_1()
    for _, surface in pairs(game.surfaces) do
        -- replace ghosts
        local ghosts = surface.find_entities_filtered{name = 'entity-ghost'}
        for _, ghost in pairs(ghosts) do
            handle_legacy_ghost(ghost)
        end

        local plates = surface.find_entities_filtered{type = "simple-entity-with-force"}
        for _, plate in pairs(plates) do
            if is_legacy[plate.name] then
                local size, material, symbol = strmatch(plate.name, '^(%a*)%-(%a*)%-(.*)$')
                if symbol ~= "blank" then
                    local force = plate.force
                    local position = plate.position
                    local variation = symbol_id[symbol]

                    plate.destroy()

                    surface.create_entity{
                        name = "textplate-" .. size .. "-" .. material,
                        position = position,
                        force = force,
                        --variation = variation - 1, -- -1 causes offset?
                        variation = variation,
                    }
                end
            end
        end
    end
end

script.on_configuration_changed(function()
    -- clear global
    for k,v in pairs(global) do
        global[k] = nil
    end

    global.next_symbol = {}
    global.plate_type = {}

    Plate_type = global.plate_type
    Next_symbol = global.next_symbol

    if support_legacy and not global.converted_legacy then
        convert_legacy_1()
        global.converted_legacy = 1
    end
end)

script.on_load(function()
    Plate_type = global.plate_type
    Next_symbol = global.next_symbol
end)
