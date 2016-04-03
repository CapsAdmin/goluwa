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
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/goluwa_screenshots/test17.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/goluwa_screenshots/test18.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-02/2015-02-20_01-14-09.png)

Similar to derma/gwen in gmod. It's also compatible with gwen skins. The blue skin tries to be identical to zsnes which is only used in the main menu.

Source engine content:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/goluwa_screenshots/test20.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/goluwa_screenshots/test21.png)

Here I've loaded a dear esther and hl2 ep2 map. Goluwa will figure out where your steam libraries are, mount the game's vpk files and the required source games, read the BSP, VTF, VMT, MDL, etc files and load the assets. This is all very WIP but somewhat works.

Entity editor:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/goluwa_screenshots/test23.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-02/2015-02-01_18-13-43.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_23-03-29.gif)

It's sort of similar to PAC3 (a character editor I made for Garry's Mod). All objects have properties and some of them can be marked for being storable. If they are you can edit them with this editor.

Löve wrapper:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-05_23-48-56.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-05_23-49-53.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-06_13-41-38.jpg)

So you can run games made in Löve for some reason. The first game is Mr. Rescue and the second one is Sienna (I didn't make them). As with almost everything in Goluwa it's WIP. Some games work and some games don't.

Markup language:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-05/2014-05-02_04-21-03.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_23-48-43.gif)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_23-40-58.gif)

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
