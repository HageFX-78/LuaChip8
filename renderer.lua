local Renderer = {}
local screen = {}

local Settings = require("settings")

local width = 0
local height = 0
local scale = 0

function Renderer:init()
    --application = {}
    width = Settings.SCREEN_WIDTH
    height = Settings.SCREEN_HEIGHT
    scale = Settings.SCREEN_SCALE

    for x = 0, width - 1 do
        screen[x] = {}
        for y = 0, height - 1 do
            screen[x][y] = 0 -- Initialize all pixels to off
        end
    end

    print("Initialized Renderer")
end


function Renderer:setPixel(x, y)

    if x >= width then
        x = x - width - 1
    elseif x < 0 then
        x = x + width - 1
    end

    if y >= height then
        y = y - height - 1
    elseif y < 0 then
        y = y + height - 1
    end

    screen[x][y] = screen[x][y] == 1 and 0 or 1 --Ternary operation to toggle pixel state

    return screen[x][y]
end
function Renderer:getPixel(x, y)
    return screen[x][y]
end

function Renderer:clear()
    for x = 0, width - 1 do
        for y = 0, height - 1 do
            screen[x][y] = 0 -- Initialize all pixels to off
        end
    end
end

function Renderer:render()
    for x = 0, width - 1  do
        for y = 0, height - 1 do
            if screen[x][y] > 0 then
                love.graphics.setColor(1,1,1)
            else
                love.graphics.setColor(0,0,0)
            end
            love.graphics.rectangle("fill", x * scale, y * scale, scale, scale)
        end            
    end
end

function Renderer:getWidth()
    return width
end
function Renderer:getHeight()
    return height
end
return Renderer