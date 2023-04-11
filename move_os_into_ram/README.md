# Move XL OS ROM into RAM

I copied the code from [AtariArchives](https://www.atariarchives.org/mapping/appendix12.php#:~:text=Move%20XL%20OS%20ROM%20into%20RAM) and made it compatible with MADS.

Follow main [README](../README.md) to compile and run it

When you do it, OS (`$c000`-`$ffff` except `$d000`-`d7fff`) will be in RAM and therefore you can write there.

## Examples

Pause app and open debugger (Press `F8` in Altirra)

### Change screen background's color

1. Change `STA COLPM0,X` to `LDA COLPM0,X` on the address `$c16f` - use emulator's assembler or just change the 1st byte from `$9d` to `$bd`
2. Continue (`F8` again)
3. Write a color into HW `COLPF2` (`$d018`)

The color will be set as a background color in GR0 screen and VBI doesn't replace the color from the shadow `COLOR2` (`$2c6`).

<video src='./bg_color.mp4' width=180/>

### Modify character set

1. Continue (`F8` again)
2. Modify a character in character set (`$e000`)

The change appears on screen.

<video src='./char_set.mp4' width=180/>
