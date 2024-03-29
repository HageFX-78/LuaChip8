-- Input handler
local Input = {}

Input.KEYMAP = {
    ['1'] = 0x1,
    ['2'] = 0x2,
    ['3'] = 0x3,
    ['4'] = 0xC,
    ['q'] = 0x4,
    ['w'] = 0x5,
    ['e'] = 0x6,
    ['r'] = 0xD,
    ['a'] = 0x7,
    ['s'] = 0x8,
    ['d'] = 0x9,
    ['f'] = 0xE,
    ['z'] = 0xA,
    ['x'] = 0x0,
    ['c'] = 0xB,
    ['v'] = 0xF
}

local keysPressed = {}
local waitingForKeyPress = false

function Input:init()
    keysPressed = {}
    for x = 0x0, 15 do
        keysPressed[x] = false
    end
    print("Initialized Input")
end


function Input:setKeyState(key, state)
    if Input.KEYMAP[key] then
        keysPressed[Input.KEYMAP[key]] = state
        return Input.KEYMAP[key]  -- Return the corresponding keycode hex format
    else
        return 0  -- Return nil if key is not in the keymap
    end
end

function Input:isKeyDown(key)-- Check if a key is still down, static function, keycode format = 0x1
    return keysPressed[key]
end

function Input:getKeysPressed()
    return keysPressed
end

function Input:isWaitingForKeyPress()
    return waitingForKeyPress
end
function Input:setWaitingForKeyPress(state)
    waitingForKeyPress = state
end

return Input