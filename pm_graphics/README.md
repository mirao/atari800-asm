# Using of joystick in player/missile graphics

Follow main [README](../README.md)

![P/M Graphics](./pm_graphics.gif)

## Known issue

In Altirra/Atari800 emulators, let's have emulated a joystick with the key `Left Ctrl` for trigger and the keys `Left`, `Right`, `Up`, `Down` for stick.

Now if you **press and hold** `Left Ctrl` and concurrently **press** `Left Arrow` + `Down Arrow` or `Right Arrow` + `Down Arrow`, then a player move is done only down and not to the left or right on some keyboards. Also sometimes a trigger is suddenly released itself when pressing such combination of keys.

Tested with the devices

* affected:
  * keyboard Dell KM5221W
* not affected:
  * keyboard Genius LuxePad 9100
  * keyboard on NTB Lenovo Yoga Slim 7 14ARE05
  * gamepad Wireless Steam Controller
