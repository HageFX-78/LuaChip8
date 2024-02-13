-- GLobal list of instructions that is included in cpu.lua
-- Referenced from http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#3.1


Instruction = {} -- Might change to local in the future

Instruction[0x0000] = function (cpu, opcode)
    if cpu.nnn == 0x0E0 then -- CLS - Clear the display
        cpu.Renderer:clear()
    elseif cpu.nnn == 0x0EE then -- RET - Return from a subroutine
        cpu.PC = cpu.stack[cpu.SP]
        cpu.SP = cpu.SP - 1
    end
end 

Instruction[0x1000] = function (cpu, opcode) -- 1nnn - JP addr - Jump to location nnn
    cpu.PC = cpu.nnn
end

Instruction[0x2000] = function (cpu, opcode) -- 2nnn - CALL addr - Call subroutine at nnn
    cpu.SP = cpu.SP + 1
    cpu.stack[cpu.SP] = cpu.PC
    cpu.PC = cpu.nnn
end

Instruction[0x3000] = function (cpu, opcode)  -- 3xkk - SE Vx, byte - Skip next instruction if Vx = kk
    if cpu.V[cpu.x] == cpu.kk then
        cpu.PC = cpu.PC + 2
    end
end

Instruction[0x4000] = function (cpu, opcode) -- 4xkk - SNE Vx, byte - Skip next instruction if Vx != kk
    if cpu.V[cpu.x] ~= cpu.kk then
        cpu.PC = cpu.PC + 2
    end
end

Instruction[0x5000] = function (cpu, opcode)
    if cpu.V[cpu.x] == cpu.V[cpu.y] then -- 5xy0 - SE Vx, Vy - Skip next instruction if Vx = Vy
        cpu.PC = cpu.PC + 2
    end
end

Instruction[0x6000] = function (cpu, opcode) -- 6xkk - LD Vx, byte - Set Vx = kk
    cpu.V[cpu.x] = cpu.kk
end

Instruction[0x7000] = function (cpu, opcode) -- 7xkk - ADD Vx, byte - Set Vx = Vx + kk
    cpu.V[cpu.x] = bit.band(cpu.V[cpu.x] + cpu.kk, 0xFF)
end

Instruction[0x8000] = function (cpu, opcode)
    if cpu.n == 0x0 then -- 8xy0 - LD Vx, Vy - Set Vx = Vy
        cpu.V[cpu.x] = cpu.V[cpu.y]

    elseif cpu.n == 0x1 then -- 8xy1 - OR Vx, Vy - Set Vx = Vx OR Vy
        cpu.V[cpu.x] = bit.bor(cpu.V[cpu.x], cpu.V[cpu.y])

    elseif cpu.n == 0x2 then -- 8xy2 - AND Vx, Vy - Set Vx = Vx AND Vy
        cpu.V[cpu.x] = bit.band(cpu.V[cpu.x], cpu.V[cpu.y])

    elseif cpu.n == 0x3 then -- 8xy3 - XOR Vx, Vy - Set Vx = Vx XOR Vy
        cpu.V[cpu.x] = bit.bxor(cpu.V[cpu.x], cpu.V[cpu.y])

    elseif cpu.n == 0x4 then -- 8xy4 - ADD Vx, Vy - Set Vx = Vx + Vy, set VF = carry
        local sum = cpu.V[cpu.x] + cpu.V[cpu.y]
        
        cpu.V[cpu.x] = bit.band(sum, 0xFF) -- only last 8 bits  is kept

        cpu.V[0xF] = sum > 0xFF and 1 or 0

    elseif cpu.n == 0x5 then -- 8xy5 - SUB Vx, Vy - Set Vx = Vx - Vy, set VF = NOT borrow
        local ogX = cpu.V[cpu.x]

        cpu.V[cpu.x] = bit.band(cpu.V[cpu.x] - cpu.V[cpu.y], 0xFF)
        cpu.V[0xF] = ogX > cpu.V[cpu.y] and 1 or 0

    elseif cpu.n == 0x6 then -- 8xy6 - SHR Vx {, Vy} - Set Vx = Vx SHR 1
        local ogX = cpu.V[cpu.x]
        cpu.V[cpu.x] = math.floor(cpu.V[cpu.x] / 2)

        cpu.V[0xF] = bit.band(ogX, 0x1) and 1 or 0

    elseif cpu.n == 0x7 then -- 8xy7 - SUBN Vx, Vy - Set Vx = Vy - Vx, set VF = NOT borrow
        
        cpu.V[cpu.x] = bit.band(cpu.V[cpu.y] - cpu.V[cpu.x], 0xFF)

        cpu.V[0xF] = cpu.V[cpu.y] > cpu.V[cpu.x] and 1 or 0

    elseif cpu.n == 0xE then -- 8xyE - SHL Vx {, Vy} - Set Vx = Vx SHL 1
        
        cpu.V[cpu.x] = bit.band(cpu.V[cpu.x] * 2, 0xFF)

        cpu.V[0xF] = bit.band(bit.rshift(cpu.V[cpu.x], 7), 0x1) and 1 or 0
    end
end

Instruction[0x9000] = function (cpu, opcode) -- 9xy0 - SNE Vx, Vy - Skip next instruction if Vx != Vy
    if cpu.V[cpu.x] ~= cpu.V[cpu.y] then
        cpu.PC = cpu.PC + 2
    end
end

Instruction[0xA000] = function (cpu, opcode) -- Annn - LD I, addr - Set I = nnn
    cpu.I = cpu.nnn
end

Instruction[0xB000] = function (cpu, opcode) -- Bnnn - JP V0, addr - Jump to location nnn + V0
    cpu.PC = cpu.nnn + cpu.V[0]
end

Instruction[0xC000] = function (cpu, opcode) -- Cxkk - RND Vx, byte - Set Vx = random byte AND kk
    cpu.V[cpu.x] = bit.band(math.random(0, 255), cpu.kk)
end

Instruction[0xD000] = function (cpu, opcode) -- Dxyn - DRW Vx, Vy, nibble - Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision
    
    local x = cpu.V[cpu.x]
    local y = cpu.V[cpu.y]
    local width = 8
    local height = cpu.n
    local pixel

    cpu.V[0xF] = 0 -- Reset collision flag

    for yline = 0, height - 1 do
        pixel = cpu.memory[cpu.I + yline]
        for xline = 0, width - 1  do
            if bit.band(pixel, 0x80) > 0 then
                local currentPixelX = (x + xline) % cpu.Renderer:getWidth() -- Wrap around X coordinate for each pixel
                local currentPixelY = (y + yline) % cpu.Renderer:getHeight() -- Wrap around Y coordinate for each pixel

                if cpu.Renderer:getPixel(currentPixelX, currentPixelY) == 1 then
                    cpu.V[0xF] = 1
                end
                cpu.Renderer:setPixel(currentPixelX, currentPixelY)
            end
            pixel = bit.lshift(pixel, 1)
        end
    end
end

Instruction[0xE000] = function (cpu, opcode)
    if cpu.kk == 0x9E then -- Ex9E - SKP Vx - Skip next instruction if key with the value of Vx is pressed
        if cpu.Input:isKeyDown(cpu.V[cpu.x]) then
            cpu.PC = cpu.PC + 2
        end
    elseif cpu.kk == 0xA1 then -- ExA1 - SKNP Vx - Skip next instruction if key with the value of Vx is not pressed
        if not cpu.Input:isKeyDown(cpu.V[cpu.x]) then
            cpu.PC = cpu.PC + 2
        end
    end
end

Instruction[0xF000] = function (cpu, opcode)
    if cpu.kk == 0x07 then -- Fx07 - LD Vx, DT - Set Vx = delay timer value
        cpu.V[cpu.x] = cpu.DT
        
    elseif cpu.kk == 0x0A then -- Fx0A - LD Vx, K - Wait for a key press, store the value of the key in Vx

        -- Not the best implmentation but works for now
        cpu.paused = true
        cpu.Input:setWaitingForKeyPress(true)

    elseif cpu.kk == 0x15 then -- Fx15 - LD DT, Vx - Set delay timer = Vx
        cpu.DT = cpu.V[cpu.x]

    elseif cpu.kk == 0x18 then -- Fx18 - LD ST, Vx - Set sound timer = Vx
        cpu.ST = cpu.V[cpu.x]

    elseif cpu.kk == 0x1E then -- Fx1E - ADD I, Vx - Set I = I + Vx
        cpu.I = cpu.I + cpu.V[cpu.x]

    elseif cpu.kk == 0x29 then -- Fx29 - LD F, Vx - Set I = location of sprite for digit Vx
        cpu.I = cpu.V[cpu.x] * 5 -- each sprite has 5 bytes, index 0 will result in the first prite regardless

    elseif cpu.kk == 0x33 then -- Fx33 - LD B, Vx - Store BCD representation of Vx in memory locations I, I+1, and I+2
        local value = cpu.V[cpu.x]
        cpu.memory[cpu.I] = math.floor(value / 100)
        cpu.memory[cpu.I + 1] = math.floor((value % 100) / 10)
        cpu.memory[cpu.I + 2] = value % 10

    elseif cpu.kk == 0x55 then -- Fx55 - LD [I], Vx - Store registers V0 through Vx in memory starting at location I
        for i = 0, cpu.x do
            cpu.memory[cpu.I + i] = cpu.V[i]
        end

    elseif cpu.kk == 0x65 then -- Fx65 - LD Vx, [I] - Read registers V0 through Vx from memory starting at location I
        for i = 0, cpu.x do
            cpu.V[i] = cpu.memory[cpu.I + i]
        end
    end

end
--return instruction