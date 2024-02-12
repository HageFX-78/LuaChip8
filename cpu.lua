require("instructions")

local Cpu = {}

local MEM_SIZE = 4096
local STACK_COUNT = 16

local memory = {} -- 4096 bytes of memory
local stack = {} -- 16 16-bit values

local V -- 16 8-bit registers
local I -- 16-bit register

local DT -- Delay timer register
local ST -- Sound timer register

-- Pseudo registers
local PC -- Program counter 16bit
local SP -- Stack pointer 8bit

local paused = false

local SPRITES = {
    0xF0, 0x90, 0x90, 0x90, 0xF0,   -- 0
    0x20, 0x60, 0x20, 0x20, 0x70,   -- 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0,   -- 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0,   -- 3
    0x90, 0x90, 0xF0, 0x10, 0x10,   -- 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0,   -- 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0,   -- 6
    0xF0, 0x10, 0x20, 0x40, 0x40,   -- 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0,   -- 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0,   -- 9
    0xF0, 0x90, 0xF0, 0x90, 0x90,   -- A
    0xE0, 0x90, 0xE0, 0x90, 0xE0,   -- B
    0xF0, 0x80, 0x80, 0x80, 0xF0,   -- C
    0xE0, 0x90, 0x90, 0x90, 0xE0,   -- D
    0xF0, 0x80, 0xF0, 0x80, 0xF0,   -- E
    0xF0, 0x80, 0xF0, 0x80, 0x80    -- F
}

local Renderer
local Input
local Audio

local romLoaded = false


function Cpu:init(rd, inp, ad)
    self.Renderer = rd
    self.Input = inp
    self.Audio = ad

    self.memory = {} -- 4096 bytes of memory
    for x = 0, MEM_SIZE - 1 do
        if x < #SPRITES then
            self.memory[x] = SPRITES[x + 1] -- Preset size default index is 1 so offseted
        else
            self.memory[x] = 0x0000
        end
    end

    self.stack = {} -- 16 16-bit values
    for x = 0, STACK_COUNT - 1 do
        self.stack[x] = 0x0000
    end

    self.V = {} -- V0 to VF 16 8-bit registers
    for x = 0, 15 do
        self.V[x] = 0x00
    end
    self.I = 0x0000 -- 16-bit register

    self.DT = 0 -- Delay timer register
    self.ST = 0 -- Sound timer register

    -- Pseudo registers
    self.PC = 0x200 -- Program counter 16bit, starts at 0x200 for Chip8
    self.SP = 0x0000 -- Stack pointer 8bit

    self.paused = false
    self.romLoaded = false

    print("Initialized CPU")
end

function Cpu:loadRom(filename)
    -- Load the rom into memory
    local file = love.filesystem.newFile("roms/"..filename)
    local status = file:open("r")

    if not status then
        error("Failed to open ROM file: " .. filename)
    end

    local romData = file:read() -- Read the entire content of the file
    file:close()

    -- Size check
    if #romData > (4096 - 512) then -- 512 bytes reserved for the interpreter, 0x000 to 0x1FF
        error("ROM file size exceeds available memory")
    end

    for x = 1, #romData do
        self.memory[0x200 + (x - 1)] = string.byte(romData, x)-- String array data starts at 1
        --print(string.format( "0x%X", self.memory[0x200 + (x - 1)]))
    end
    

    self.romLoaded = true
    self.paused = false
    -- Debug
    print("Loaded ROM: " .. filename)
    return  "Rom: "..filename
end

function Cpu:Cycle()
    if self.paused then
        return "Paused"
    end

    if Cpu.PC >= 4096 then
        error("Program counter out of bounds")
    end

    if self.memory[self.PC] == 0x00 and self.memory[self.PC + 1] == 0x00 then
        print("-- Reached End of Program")
        --return
    end
    
    local opcode = bit.bor(bit.lshift(self.memory[self.PC], 8), self.memory[self.PC + 1])
    Cpu:executeInstruction(opcode)

    -- Audio
    if self.DT >  0 then
        self.DT = self.DT - 1
    end
    if self.ST > 0 then
        self.ST = self.ST - 1
    end

    return string.format("PC: %x, Opcode: %x", self.PC, opcode)
end

local nnn
local n
local x
local y
local kk

function Cpu:executeInstruction(opcode)
    self.PC = self.PC + 2

    self.nnn = bit.band(opcode, 0x0FFF) -- lowest 12 bits of instruction
    self.n = bit.band(opcode, 0x000F) -- lowest 4 bits of instruction / also known as nibble
    self.x = bit.rshift(bit.band(opcode, 0x0F00), 8) -- isolate and shift right to get 0x00 value
    self.y = bit.rshift(bit.band(opcode, 0x00F0), 4) -- isolate and shift right to get 00x0 value
    self.kk = bit.band(opcode, 0x00FF) -- lowest 8 bits of instruction / also known as byte

    
    if Instruction[bit.band(opcode, 0xF000)] then
        Instruction[bit.band(opcode, 0xF000)](self, opcode)
    else
        error("Unknown opcode: " .. string.format("%x", opcode))
    end
    return string.format("Opcode: %x, x: %x, y: %x, kk: %x", opcode, self.x, self.y, self.kk)
end

return Cpu