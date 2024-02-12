--chip8 emulator HaZuki
local Renderer = require("renderer")
local Input = require("input")
local Cpu = require("cpu")
local Audio = require("audio")
local Settings = require("settings")

local interval
local lastFrameTime


local DEBUG_MODE = false
local test = ""
local romDebug = ""
local cpuDebug = ""

function love.load()

    Renderer:init();
    Input:init();
    Cpu:init(Renderer, Input, Audio)


    interval = 1 / Settings.FRAMES_PER_SECOND
    lastFrameTime = love.timer.getTime()

    romDebug = Cpu:loadRom(Settings.ROM_NAME)
end

function love.update(deltaTime)
    if Cpu.romLoaded then
        -- Calculate the time since the last frame
        local currentTime = love.timer.getTime()
        local deltaTime = currentTime - lastFrameTime
        
        -- If the time since the last frame is less than the desired interval, sleep until the interval is reached
        if deltaTime < interval then
            love.timer.sleep(interval - deltaTime)
        end
        
        -- Update the last frame time
        lastFrameTime = love.timer.getTime()


        for x = 0 , Settings.INSTRUCITONS_PER_FRAME - 1 do
            cpuDebug = Cpu:Cycle()
        end
    end
end

-- Key board inputs
function love.keypressed(key, scancode, isrepeat)
    if Settings.DEBUG_MODE then
        if Input.KEYMAP[key] then
            print(string.format("0x%X", Input.KEYMAP[key]))
        end
    end

    local returnedKEy = Input:setKeyState(key, true)
    test = string.format("0x%X", returnedKEy)
end
function love.keyreleased(key)
    Input:setKeyState(key, false)
end

function love.draw()
    Renderer:render();

    love.graphics.setColor(0,1,1)

    if Settings.DEBUG_MODE then
        love.graphics.print("FPS: " .. love.timer.getFPS(), (Settings.SCREEN_WIDTH * Settings.SCREEN_SCALE) - 100, 5)
        love.graphics.print("Keyscan - " .. test .. " || " .. romDebug .. " || " .. cpuDebug, 5, 5)
    end
    

end



