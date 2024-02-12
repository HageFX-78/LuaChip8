# Lua Chip 8 Emulator

My personal first lua program made to learn about emulation and lua the programming language itself, implementations and design of code may be a mess as this is my first lua program.

Requires [Love2D](https://love2d.org) to run.


Usage
- Roms can be placed in the `roms` folder and chaning the ROM_FILENAME value to the new file in `settings.lua`
- Other settings can also be adjusted in `settings.lua` such as `INSTRUCTIONS_PER_FRAME` or `FRAMES_PER_SECOND` according to different roms as it may vary

Notes
- Can load up most ROMS in the folder (Disclaimer:None of them are mine)
- Audio is not done yet
- Flag test is not completed
- Wait for key press instruction is not fixed

References
- [Technical Manual](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)
- [Guide in Javascript](https://www.freecodecamp.org/news/creating-your-very-own-chip-8-emulator/)
- [Test suite for Chip 8](https://github.com/Timendus/chip8-test-suite?tab=readme-ov-file)
