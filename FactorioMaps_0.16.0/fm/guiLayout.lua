
if not fm.gui then error("Hey silly. don't include this directly!") end

--------------------------------
-- BUTTON CREATOR
--------------------------------
function fm.gui.makeSpriteButton(location, button)
        local button = location.add(button)
        local bstyle = button.style
        bstyle.top_padding = 0
        bstyle.left_padding = 0
        bstyle.right_padding = 0
        bstyle.bottom_padding = 0
        bstyle.minimal_height = 32
        bstyle.maximal_height = 32
        bstyle.minimal_width = 32
        bstyle.maximal_width = 32
end

--------------------------------
-- MAIN BUTTON
--------------------------------
function fm.gui.getMainButton(player_index_or_name)
    local player = game.players[player_index_or_name]
    if (not player or not player.valid) then --or not player.connected <- broken in 0.14 Single-player when adding the mod to a SP game. Works perfectly fine after that.
        return nil
    end
    if (player.gui.top.FactorioMaps_mainButton ~= nil) then
        return player.gui.top.FactorioMaps_mainButton
    end
    return nil
end

function fm.gui.showAllMainButton()
    for _, player in pairs(game.players) do
        fm.gui.showMainButton(player.index)
    end
end

function fm.gui.showMainButton(player_index_or_name)
    local player = game.players[player_index_or_name]
    if (not player or not player.valid) then --or not player.connected <- broken in 0.14 Single-player when adding the mod to a SP game. Works perfectly fine after that.
        return false
    end
    if (not fm.gui.getMainButton(player_index_or_name)) then
        fm.gui.makeSpriteButton(player.gui.top, {type = "sprite-button", name = "FactorioMaps_mainButton", sprite = "FactorioMaps_menu_sprite", style = "button"})
    end
end

function fm.gui.hideMainButton(player_index_or_name)
    local mainButton = fm.gui.getMainButton(player_index_or_name)
    if (mainButton) then
        mainButton.destroy()
    end
end

function fm.gui.hideAllMainButton()
    for _, player in pairs(game.players) do
        fm.gui.hideMainButton(player.index)
    end
end

--------------------------------
-- MAIN WINDOW
--------------------------------
function fm.gui.getMainWindow(player_index_or_name)
    local player = game.players[player_index_or_name]
    if (not player or not player.valid or not player.connected) then
        return nil
    end
    if (player.gui.left.FactorioMaps ~= nil) then
        return player.gui.left.FactorioMaps
    end
    return nil
end

function fm.gui.showMainWindow(player_index_or_name)
    local player = game.players[player_index_or_name]
    if (not player or not player.valid or not player.connected) then
        return
    end
    if (not fm.gui.getMainWindow(player_index_or_name)) then
        player.gui.left.add({type = "frame", name = "FactorioMaps", caption = {"label-main-window"}, direction = "horizontal"})
        fm.gui.showLeftPane(player_index_or_name)
    end
end

function fm.gui.hideMainWindow(player_index_or_name)
    local mainWindow = fm.gui.getMainWindow(player_index_or_name)
    if (mainWindow) then
        mainWindow.destroy()
    end
end

--------------------------------
-- MAIN WINDOW LEFT PANE
--------------------------------
function fm.gui.getLeftPane(player_index_or_name)
    local mainWindow = fm.gui.getMainWindow(player_index_or_name)
    if (mainWindow) then
        if (mainWindow.Left ~= nil) then
            return fm.gui.getMainWindow(player_index_or_name).Left
        end
    end
    return nil
end

function fm.gui.showLeftPane(player_index_or_name)
    if (not fm.gui.getMainWindow(player_index_or_name)) then
        fm.gui.showMainWindow(player_index_or_name)
        return
    end
    if (fm.gui.getLeftPane(player_index_or_name)) then
        return
    end
    local mainWindow = fm.gui.getMainWindow(player_index_or_name)
    local leftPane = mainWindow.add({type = "frame", name = "Left", caption = {"label-main-settings"}, direction = "vertical"})

    local topFlow = leftPane.add({type = "flow", name = "topFlow", direction = "horizontal"})
    local topLeftFlow = topFlow.add({type = "flow", name = "topLeftFlow", direction = "vertical"})
    topLeftFlow.add({type = "checkbox", name = "FactorioMaps_dayOnly", state = fm.cfg.get("dayOnly"), caption = {"label-day-only"}, tooltip = {"tooltip-day-only"}})
    topLeftFlow.add({type = "checkbox", name = "FactorioMaps_altInfo", state = fm.cfg.get("altInfo"), caption = {"label-alt-info"}, tooltip = {"tooltip-alt-info"}})
    local topRightFlow = topFlow.add({type = "flow", name = "topRightFlow", direction = "horizontal"})
    topRightFlow.add({type = "label", name = "filler", caption = "_____________"})
    topRightFlow.filler.style.font_color = {r = 48,g = 75, b = 74}
    topRightFlow.add({type = "button", name = "FactorioMaps_advancedButton", style = "button", caption = {"button-advanced-settings"}, tooltip = {"tooltip-advanced-settings"}})

    local folderFlow = leftPane.add({type = "flow", name = "folderFlow", direction = "horizontal"})
--    folderFlow.style.minimal_width = 250
--    folderFlow.style.maximal_width = 250
    folderFlow.add({type = "label", name = "label_folder-name", caption = {"label-folder-name"}, tooltip = {"tooltip-folder-name"}})
    folderFlow.add({type = "textfield", name = "FactorioMaps_folderName", text = fm.cfg.get("folderName"), tooltip = {"tooltip-folder-name"}})

    local bottomFlow = leftPane.add({type = "flow", name = "bottomFlow", direction = "horizontal"})
    bottomFlow.add({type = "button", name = "FactorioMaps_maxSize", style = "button", caption = {"button-max-size"}, tooltip = {"tooltip-max-size"}})
    bottomFlow.add({type = "button", name = "FactorioMaps_baseSize", style = "button", caption = {"button-base-size"}, tooltip = {"tooltip-base-size"}})
    bottomFlow.add({type = "label", name = "filler", caption = "_____________"})
    bottomFlow.filler.style.font_color = {r = 48,g = 75, b = 74}
    bottomFlow.add({type = "button", name = "FactorioMaps_generate", style = "button", caption = {"button-generate"}, tooltip = {"tooltip-generate"}})
end

function fm.gui.hideLeftPane(player_index_or_name)
    local leftPane = fm.gui.getLeftPane(player_index_or_name)
    if (leftPane) then
        leftPane.destroy()
    end
end

--------------------------------
-- MAIN WINDOW RIGHT PANE (ADVANCED SETTINGS)
--------------------------------
function fm.gui.getRightPane(player_index_or_name)
    local mainWindow = fm.gui.getMainWindow(player_index_or_name)
    if (mainWindow) then
        if (mainWindow.Right ~= nil) then
            return fm.gui.getMainWindow(player_index_or_name).Right
        end
    end
    return nil
end

function fm.gui.showRightPane(player_index_or_name)
    if (fm.gui.getRightPane(player_index_or_name)) then
        return
    end
    if (not fm.gui.getMainWindow(player_index_or_name)) then
        fm.gui.showMainWindow(player_index_or_name)
    end
    local mainWindow = fm.gui.getMainWindow(player_index_or_name)

    local rightPane = mainWindow.add({type = "frame", name = "Right", caption = {"label-advanced-settings"}, direction = "vertical"})
    local tbl = rightPane.add({type = "table", name = "topFlow", column_count = 5})
    tbl.add({type = "label"})
    tbl.add({type = "label"})
    tbl.add({type = "label"})
    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_viewReturn", sprite = "FactorioMaps_return_sprite", style = "button", tooltip = {"tooltip-top-left-return"}})
    tbl.add({type = "label"})

    tbl.add({type = "label", name = "label_top-left-xy", caption = {"label-top-left-xy"}, tooltip = {"tooltip-top-left-xy"}})
    local topLeftX = tbl.add({type = "textfield", name = "FactorioMaps_topLeftX", text = fm.cfg.get("topLeftX"), tooltip = {"tooltip-top-left-x"}})
    topLeftX.style.minimal_width = 50
    topLeftX.style.maximal_width = 50
    local topLeftY = tbl.add({type = "textfield", name = "FactorioMaps_topLeftY", text = fm.cfg.get("topLeftY"), tooltip = {"tooltip-top-left-y"}})
    topLeftY.style.minimal_width = 50
    topLeftY.style.maximal_width = 50
    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_topLeftView", sprite = "FactorioMaps_view_sprite", style = "button", tooltip = {"tooltip-top-left-view"}})
--    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_topLeftReturn", sprite = "FactorioMaps_return_sprite", style = "button", tooltip = {"tooltip-top-left-return"}})
    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_topLeftPlayer", sprite = "FactorioMaps_player_sprite", style = "button", tooltip = {"tooltip-top-left-player"}})

    tbl.add({type = "label", name = "label_bottom-right-xy", caption = {"label-bottom-right-xy"}, tooltip = {"tooltip-bottom-right-xy"}})
    local bottomRightX = tbl.add({type = "textfield", name = "FactorioMaps_bottomRightX", text = fm.cfg.get("bottomRightX"), tooltip = {"tooltip-bottom-right-x"}})
    bottomRightX.style.minimal_width = 50
    bottomRightX.style.maximal_width = 50
    local bottomRightY = tbl.add({type = "textfield", name = "FactorioMaps_bottomRightY", text = fm.cfg.get("bottomRightY"), tooltip = {"tooltip-bottom-right-y"}})
    bottomRightY.style.minimal_width = 50
    bottomRightY.style.maximal_width = 50
    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_bottomRightView", sprite = "FactorioMaps_view_sprite", style = "button", tooltip = {"tooltip-bottom-right-view"}})
--    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_bottomRightReturn", sprite = "FactorioMaps_return_sprite", style = "button", tooltip = {"tooltip-bottom-right-return"}})
    fm.gui.makeSpriteButton(tbl, {type = "sprite-button", name = "FactorioMaps_bottomRightPlayer", sprite = "FactorioMaps_player_sprite", style = "button", tooltip = {"tooltip-bottom-right-player"}})

    local middleFlow2 = rightPane.add({type = "flow", name = "middleFlow2", direction = "horizontal"})
    middleFlow2.add({type = "label", name = "label_gridSize", caption = {"label-grid-size"}, tooltip = {"tooltip-grid-size"}})
    local tbl = middleFlow2.add({type = "table", name = "table_gridSize", column_count = 1})
    global._radios.gridSize={}
    local i = 1
    for i = 1, 4, 1 do
        global._radios.gridSize[i] = tbl.add({type = "radiobutton", name = "FactorioMaps_radio_gridSize_" .. tostring(i), state = false, caption = {"radio-grid-size-" .. tostring(i)}, tooltip = {"tooltip-grid-size-radio-" .. tostring(i)}})
    end
    fm.gui.radio.gridSizeSelect(fm.cfg.get("gridSize"))

    middleFlow2.add({type = "label", name = "label_extension", caption = {"label-extension"}, tooltip = {"tooltip-extension"}})
    local tbl = middleFlow2.add({type = "table", name = "table_extension", column_count = 1})
    global._radios.extension={}
    for i = 1, 3, 1 do
        global._radios.extension[i] = tbl.add({type = "radiobutton", name = "FactorioMaps_radio_extension_" .. tostring(i), state = false, caption = {"radio-extension-" .. tostring(i)}, tooltip = {"tooltip-extension-radio-" .. tostring(i)}})
    end
    fm.gui.radio.extensionSelect(fm.cfg.get("extension"))

    local middleFlow3 = rightPane.add({type = "flow", name = "middleFlow3", direction = "horizontal"})

    local bottomFlow = rightPane.add({type = "flow", name = "bottomFlow", direction = "horizontal"})
    bottomFlow.add({type = "checkbox", name = "FactorioMaps_extraZoomIn", state = fm.cfg.get("extraZoomIn"), caption = {"label-extraZoomIn"}, tooltip = {"tooltip-extraZoomIn"}})

    rightPane.add({type = "label", name = "label_currentPlayerCoords", caption = {"label-current-player-coords", "nauvis", 0, 0}, tooltip = {"tooltip-current-player-coords"}})
end

function fm.gui.hideRightPane(player_index_or_name)
    local rightPane = fm.gui.getRightPane(player_index_or_name)
    if (rightPane) then
        rightPane.destroy()
    end
end
