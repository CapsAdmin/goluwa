Goluwa is a framework coded entirely in LuaJIT that I use to satisfy my programming hobby and further develop Goluwa with. I don't really have any big plans so I just code whatever I feel like coding. I'm interested in game engines and middleware for games so Goluwa ends up being something that vaguely resembles a game engine. I constantly refactor and change the api so I wouldn't recommend using Goluwa to make a game or anything like that but I'd be happy if you find code to use or learn from.

I mainly use and develop this on Linux so windows support isn't high priority even though it should work there.

I use [ffibuild](https://github.com/CapsAdmin/ffibuild) to build ffi bindings for these libraries:

* [OpenGL](http://www.opengl.org/) - graphics
* [SDL](https://www.libsdl.org/) - window and input handler
* [OpenAL Soft](http://kcat.strangesoft.net/openal.html) - sound library
* [FreeType](http://www.freetype.org/) - font decoding
* [Libsndfile](http://www.mega-nerd.com/libsndfile/) - sound decoding
* [Freeimage](http://freeimage.sourceforge.net/) - image decoding
* [vtflib](https://github.com/panzi/VTFLib/) - source engine texture decoding
* [ncurses](https://www.gnu.org/software/ncurses/) - console
* [Assimp](https://github.com/assimp/assimp) - model decoding
* [Bullet3](https://github.com/bulletphysics/bullet3) - physics engine (needs a c wrapper)
* [ENet](https://github.com/lsalzman/enet) - networking library targeted at games

GUI:
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/zsnes_load.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gui_skins.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/esheep_eorange.png)

Similar to derma/gwen in gmod. It's also compatible with gwen skins. The blue skin tries to be identical to zsnes which is only used in the main menu.

Source engine content:
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/de_bank.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gm_construct.png)

Here I've loaded a dear esther and hl2 ep2 map. Goluwa will figure out where your steam libraries are, mount the game's vpk files and the required source games, read the BSP, VTF, VMT, MDL, etc files and load the assets. This is all very WIP but somewhat works.

Entity editor:
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/amiga_ball_ssr.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gates.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/number_slider.gif)

It's sort of similar to PAC3 (a character editor I made for Garry's Mod). All objects have properties and some of them can be marked for being storable. If they are you can edit them with this editor.

Löve wrapper:
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_mrrescue.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_sienna.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/love_sienna_3d.jpg)

So you can run games made in Löve for some reason. The first game is Mr. Rescue and the second one is Sienna (I didn't make them). As with almost everything in Goluwa it's WIP. Some games work and some games don't.

Markup language:
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/markup.png)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/black_hole_tag.gif)
![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/gravity_smileys.gif)

This is used by the GUI and chat. It has lots of tags to change colors, rotation, offsets, fonts etc.

Feature highlights:
* All assets can be loaded from the internet using urls.
* Fonts can be loaded from google webfont, dafont and other places.
* Lots of model and image formats supported for prototyping.
* Most code can be reloaded without the need to restart.
* Löve wrapper to run löve games.
* Source engine asset compatible. (So you can load source engine maps and models)
* GUI that is compatible with gwen skins and has an extensive layout system.
* GLua wrapper to run gmod scripts (mostly client stuff at the moment)
