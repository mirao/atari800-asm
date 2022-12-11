## CPU 6502 assembler demos for Atari 800XL/XE

Based on [Assembly Language Programming for the Atari Computers](https://ksquiggle.neocities.org/alp.htm) by Mark Chasin
### Requirements
* [Mad Assembler](https://github.com/tebe6502/Mad-Assembler/releases)
* Atari emulator, e.g.
    * [Altirra](https://www.virtualdub.org/altirra.html)
    * [Atari800](https://github.com/atari800/atari800/releases)

### Instructions
* Open a folder with a demo
* Assemble and run in emulator

#### Example
```bash
$ cd pm_graphics

# Assemble
$ mads pm_graphics.asm

# Open a binary in Altirra emulator
$ Altirra64.exe pm_graphics.obx
# Open a binary in Atari800 emulator
$ atari800 pm_graphics.obx

# Or assemble and open a binary in Altirra emulator in one step
$ mads pm_graphics.asm && (Altirra64.exe pm_graphics.obx &)
```

### Debugging
* Install [VSCode](https://code.visualstudio.com/) and the extension [MADS](https://marketplace.visualstudio.com/items?itemName=mirao.mads) for highlighting of edited code
* Debug code in Altirra
    * Add the command `.sourcemode on` to `startup.atdbg` in your Altirra home folder
    * Run this command

        ```bash
        $ mads -tlu pm_graphics.asm && (Altirra64.exe /debug /debugbrkrun /si pm_graphics.obx &)
        ```
