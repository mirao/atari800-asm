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
$ cd joystick
# Assemble
$ mads joystick.asm
# Open binary in emulator
$ Altirra64.exe joystick.obx
$ atari800 joystick.obx
# Or assemble and open in emulator in one step
$ mads joystick.asm && (Altirra64.exe joystick.obx &)
```
