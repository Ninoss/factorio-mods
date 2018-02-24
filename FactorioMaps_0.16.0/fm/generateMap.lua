
require "stdlib/area/area"

function fm.generateMap(data)
    -- delete folder (if it already exists)
    local basePath = "FactorioMaps/" .. data.folderName
    game.remove_path(basePath)

    local inGameTotalWidth = math.ceil(math.abs(data.topLeft.x) + math.abs(data.bottomRight.x))
    local inGameTotalHeight = math.ceil(math.abs(data.topLeft.y) + math.abs(data.bottomRight.y))
    local inGameCenter = Area.center({data.topLeft, data.bottomRight})

    --Resolution to use for grid sections
    local gridSizes = {256, 512, 1024, 2048}
    local gridSize = gridSizes[data.gridSizeIndex]

    -- These are the number of tiles per grid section
    -- gridPixelSize[x] = gridSize[x] / 32 -- 32 is a hardcoded Factorio value for pixels per tile.
    local gridPixelSizes = {8, 16, 32, 64}
    local gridPixelSize = gridPixelSizes[data.gridSizeIndex]

    local minZoomLevel = data.gridSizeIndex
    local maxZoomLevel = 0 -- default

    local resolutionArray = {8,16,32,64,128,256,512,1024,2048,4096,8192} -- resolution for each zoom level, lvl 0 is always 8x8 (256x256 pixels)

    local tmpCounter = 0 -- in google maps, max zoom out level is 0, so start with 0
    for _, resolution in pairs(resolutionArray) do
        if(inGameTotalWidth < resolution and inGameTotalHeight < resolution) then
            maxZoomLevel = tmpCounter
            break
        end
        tmpCounter = tmpCounter + 1
    end

    if maxZoomLevel > 0 and data.extraZoomIn ~= true then maxZoomLevel = maxZoomLevel - 1 end
    if maxZoomLevel < minZoomLevel then maxZoomLevel = minZoomLevel end

    --Setup the results table for feeding into generateIndex
    data.index = {}
    data.index.inGameCenter = inGameCenter
    data.index.maxZoomLevel = maxZoomLevel
    data.index.minZoomLevel = minZoomLevel
    data.index.gridSize = gridSize
    data.index.gridPixelSize = gridPixelSize

    --Temp variables used in loops
    local currentZoomLevel = 0;
    if data.extraZoomIn ~= true then
        currentZoomLevel = 1 / 2 ^ (maxZoomLevel + 1 - minZoomLevel) -- counter for measuring zoom, 1/1, 1/2,1/4,1/8 etc
    else
        currentZoomLevel = 1 / 2 ^ (maxZoomLevel - minZoomLevel) -- counter for measuring zoom, 1/1, 1/2,1/4,1/8 etc
    end
    local extension = ""
    local pathText = ""
    local positionText = ""
    local resolutionText = ""
    local screenshotSize = gridPixelSize / currentZoomLevel
    local numHScreenshots = math.ceil(inGameTotalWidth / screenshotSize)
    local numVScreenshots =  math.ceil(inGameTotalHeight / screenshotSize)

    --Aligns the center of the Google map with the center of the coords we are making a map of.
    local screenshotWidth = screenshotSize * numHScreenshots
    local screenshotHeight = screenshotSize * numVScreenshots
    local screenshotCenter = {x = screenshotWidth / 2, y = screenshotHeight / 2}
    local screenshotTopLeftX = inGameCenter.x - screenshotCenter.x
    local screenshotTopLeftY = inGameCenter.y - screenshotCenter.y

    if data.dayOnly then
        fm.helpers.makeDay(data.surfaceName)
    end
    for z = minZoomLevel, maxZoomLevel, 1 do  -- max and min zoomlevels
        for y = 0, numVScreenshots - 1 do
            for x = 0, numHScreenshots - 1 do
                if((data.extension == 2 and z == maxZoomLevel) or data.extension == 3) then
                    extension = "png"
                else
                    extension = "jpg"
                end
                positionTable = {screenshotTopLeftX + (1 / (2 * currentZoomLevel)) * gridPixelSize + x * (1 / currentZoomLevel) * gridPixelSize, screenshotTopLeftY + (1 / (2 * currentZoomLevel)) * gridPixelSize + y * (1 / currentZoomLevel) * gridPixelSize}
                pathText = basePath .. "/Images/" .. z .. "_" .. x .. "_" .. y .. "." .. extension
                game.take_screenshot({by_player=game.players[data.player_index], position = positionTable, resolution = {gridSize, gridSize}, zoom = currentZoomLevel, path = pathText, show_entity_info = data.altInfo})
            end
        end

        currentZoomLevel = currentZoomLevel * 2
        numHScreenshots = numHScreenshots * 2
        numVScreenshots = numVScreenshots * 2
    end
end
