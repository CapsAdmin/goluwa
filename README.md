#About
Goluwa is a framework coded in LuaJIT that I use to further develop Goluwa with and satisfy my programming hobby. I don't really have any long term plans so I just code whatever I feel like coding. I'm interested in game engines and middleware for games so Goluwa ends up being something that vaguely resembles a game engine. I constantly refactor and change the api so I wouldn't recommend using Goluwa to make a game or anything like that but I'd be happy if you find code to use or learn from.

I mainly use and develop this on Linux so windows support isn't high priority even though it should work there. It may also work on OSX but I can't test rendering as I'm limited to using mac in a vm.

I use [ffi-build](https://github.com/CapsAdmin/goluwa/tree/master/src/lua/build) to automatically build cdef and lua bindings for these libraries:

* [OpenGL](http://www.opengl.org/) - graphics
* [SDL](https://www.libsdl.org/) - window and input handler
* [OpenAL Soft](http://kcat.strangesoft.net/openal.html) - sound library
* [FreeType](http://www.freetype.org/) - font decoding
* [Libsndfile](http://www.mega-nerd.com/libsndfile/) - sound decoding
* [Freeimage](http://freeimage.sourceforge.net/) - image decoding
* [vtflib](https://github.com/panzi/VTFLib/) - source engine texture decoding
* [ncurses](https://www.gnu.org/software/ncurses/) - console when not using the ide
* [Assimp](https://github.com/assimp/assimp) - model decoding
* [Ode](http://www.ode.org/) - physics engine
* [ENet](https://github.com/lsalzman/enet) - client <=> server networking

#GUI
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/zsnes_load.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gui_skins.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/esheep_eorange.png)

A gui with automatic layout and skin compatibility with gwen/derma skins. The blue skin tries to be identical to zsnes which is only used in the main menu.

#Source engine assets
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

* BSP - mostly complete for what goluwa needs
* VTF - uses vtflib, mostly complete
* VMT - mostly complete
* MDL - no bones or animations
* VDF - same as vmt really

#Entity editor
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/amiga_ball_ssr.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gates.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/number_slider.gif)

Sort of similar to PAC3 (a character editor I made for Garry's Mod). All objects have properties and some of them can be marked for being serialized. If they are you can edit them with this editor and save / load the entity entire tree.

#Löve wrapper
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_mrrescue.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_sienna.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_sienna_3d.jpg)

This makes it so you can run löve games in goluwa. The first game is [Mr. Rescue](https://tangramgames.itch.io/mrrescue) and the second one is [Sienna](https://tangramgames.itch.io/sienna) (Both created by [Tangram Games](http://tangramgames.dk/)). As with almost everything in Goluwa it's WIP. Some games work and some games don't.

#GLua wrapper
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/glua.png)
Same as the Löve wrapper except for glua/garrysmod lua. This is nowhere near as complete though and mostly has vgui and 2d drawing functions implemented.

#Markup language
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/markup.png)

This is used by the GUI and chat. It has lots of tags to change colors, rotation, offsets, fonts etc.

#Other features
* All assets can be loaded from the internet using urls.
* Fonts can be loaded directly from google webfont, dafont and other places for prototyping.
* Lots of model and image formats supported for prototyping.
* Most code can be reloaded without the need to restart.
* Tight integration with zerobrane
