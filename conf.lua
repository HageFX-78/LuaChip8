local Settings = require("settings")

-- Love2D Configuration File 
-- Loads before main.lua
function love.conf(t)
    t.window.title = "HaZuki"
    t.console = true

    t.window.width = Settings.SCREEN_WIDTH * Settings.SCREEN_SCALE
    t.window.height = Settings.SCREEN_HEIGHT * Settings.SCREEN_SCALE
end