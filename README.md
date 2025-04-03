# Lua Chip 8 Emulator

My personal first lua program made to learn about emulation and lua the programming language itself, implementations and design of code may be a mess as this is my first lua program.

Requires [Love2D](https://love2d.org) to run.


## Usage
- Roms can be placed in the `roms` folder and chaning the ROM_FILENAME value to the new file in `settings.lua`
- Other settings can also be adjusted in `settings.lua` such as `INSTRUCTIONS_PER_FRAME` or `FRAMES_PER_SECOND` according to different roms as it may vary

## Showcase Video
- [![Watch the video](https://img.youtube.com/vi/IkAhq2UsVIQ/maxresdefault.jpg)](https://youtu.be/IkAhq2UsVIQ)

## Notes
- Can load up most ROMS in the folder (Disclaimer:None of them are mine)
- Audio is not done yet
- Console window for LOVE2D can be enabled/disabled through changing the value in `conf.lua`


## Rom Tests
- [x] IBM logo test
- [x] Corax+ Opcode test
- [ ] Flags test - Several failed opcodes for "HAPPY path" `8xy5, 8xy6, 8xyE`
- [ ] Keypad test - Minor issue with Wait for key press `Not halting`

All features should work fine regardless of test results as most roms can be loaded, just not the most accurate implementation. 

## Addtional Controls
| Key | Description |
| --- | --- |
| ESC | End the program |
| B | Pause the emulator |
| N | Call Cpu:Cycle() |
| M | Turn on debug mode, which shows some information in the background |
| K | Increment the amount of instructions to run per cpu cycle by 1, default 10 |
| L | Decrement the amount of instructions to run per cpu cycle by 1, default 10 |
| O | Increment frames per second by 5, default 60 according to the default 60Hz |
| P | Decrement frames per second by 5, default 60 according to the default 60Hz |

## Planned Feature
- Rom loading through file selection perhaps

## References
- [Technical Manual](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)
- [Guide in Javascript](https://www.freecodecamp.org/news/creating-your-very-own-chip-8-emulator/)
- [Test suite for Chip 8](https://github.com/Timendus/chip8-test-suite?tab=readme-ov-file)
