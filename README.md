Goluwa is a framework made with LuaJIT that I use to make stuff/goluwa with. I try to make it so the code can be modified without the need to restart and have all assets loaded from the internet.

There are lots of sub projects included such as the GUI, a wrapper for running Löve games, tools for reading and mounting source engine assets, midi and sf2 parsers, some async socket library based on luasocket, etc.

I don't really have any big plans so I just code whatever I feel like coding. Because I'm interested in game engines and middleware for games Goluwa ends up being something that vaguely resembles a game engine. For these reasons I can't recommend using Goluwa to make a game or anything too serious.

LuaJIT's FFI library is used to bind to the following shared libraries:

* [OpenGL](http://www.opengl.org/) - graphics
* [SDL](https://www.libsdl.org/) - window and input handler (mainly for android)
* [OpenAL Soft](http://kcat.strangesoft.net/openal.html) - sound library
* [FreeType](http://www.freetype.org/) - font decoding
* [Libsndfile](http://www.mega-nerd.com/libsndfile/) - sound decoding
* [FreeImage](http://freeimage.sourceforge.net/) - image decoding
* [FFMpeg](http://ffmpeg.org/) - sound and image decoding
* [VTFLib](https://github.com/panzi/VTFLib) - image decoding (valves texture format)
* [PDCurses](http://www.projectpluto.com/win32a.htm) - console
* [Assimp](https://github.com/assimp/assimp) - model decoding
* [Bullet3](https://github.com/bulletphysics/bullet3) - physics engine
* [ENet](https://github.com/lsalzman/enet) - udp library targeted at games

The rest is then made in LuaJIT.

GUI:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-05_13-57-28.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_22-37-16.png)
Similar to derma/gwen in gmod. It's also compatible with gwen skins. The blue skin tries to be identical to zsnes. The zsnes skin is only used in the "main menu".

Source engine content:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-02/2015-02-06_05-33-37.jpg)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-14_18-12-58.png)

Here I'm loading de_overpass from CSGO and esther from dear esther. Goluwa will find steam from registry (different method on linux), mount the games vpk files and the required source games, read the BSP, VTF, VMT, MDL, etc files and load the assets. This is all very WIP but somewhat works.

Entity editor:
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-02/2015-02-02_01-14-06.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_22-34-03.png)
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