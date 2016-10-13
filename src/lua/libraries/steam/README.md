#Source engine compatibility
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/de_bank.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gm_construct.png)

Goluwa is able to load source engine from your steam installation.
In these screenshots I've loaded de_bank and gm_construct. Goluwa does these steps to load the maps:

* figure out where steam is installled
* read `/config/config.vdf` to figure out where the libraries are
* for each installed game read gameinfo.txt which tells you what to mount and how
* mount vpk archives and directories
* load the bsp map

The following source engine formats are supported:

* [VPK](../libraries/filesystem/files/vpk.lua) - should be complete
* [BSP](bsp.lua) - mostly complete for what goluwa needs
* [VTF](../../build/vtflib/libVTFLib.lua) - uses vtflib, mostly complete
* [VMT](vmt.lua) - mostly complete
* [MDL](mdl.lua) - no bones or animations
* [VDF](steam.lua) - same as vmt really
