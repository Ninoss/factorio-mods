
fm.config = {}

local config_defaults = {
    dayOnly = true,
    altInfo = false,
    folderName = "TempNameChangeMe!",
    customSize = false,
    extraZoomIn = false,
    topLeftX = -1000,
    topLeftY = -1000,
    bottomRightX = 1000,
    bottomRightY = 1000,
    gridSize = 3, -- Medium
    extension = 1 -- jpg
}

function fm.config.applyDefaults(forced)
    for key, value in pairs(config_defaults) do
        if not fm.cfg.is_set(key) or not not forced then
            fm.cfg.set(key, value)
        end
    end
end
