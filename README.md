Goluwa is an experimental game engine/framework/personal toolbox written in LuaJIT targeted at games. It includes high level libraries to render graphics, play audio, handle input, networking and much more. 3D is the main interest but 2D is also important.

The coding style is inspired by Source Engine, Garry's Mod and CryEngine. [UFO](https://github.com/malkia/ufo) gave me the initial idea and motivation.

I can't guarantee that Goluwa will run out of box if you download it at the moment. There is a BitSync version that I could invite you to if you're interested but that means you'll have to contact me.

My goal with this isn't very clear. I don't have any grand business plans or anything. I like to implement new features and refactor old features. I just like programming so if anything I hope I'll never finish this project.

LuaJit's FFI api is used to bind to the following shared libraries:

* [OpenGL](http://www.opengl.org/) - graphics
* [GLFW](https://github.com/glfw/glfw) - window and input handler
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
* SteamFriends - extension to the steam library to deal with steam friends communication

In theoery everything should work without using any of these libraries. The only actual requirement is [LFS](https://github.com/keplerproject/luafilesystem) and LuaJIT 2+

There is also a WIP Love2D wrapper which is used for fun and unit testing 2D graphics.
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_22-34-03.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_22-37-16.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-05_13-59-49.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-11/2014-11-18_22-38-33.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-01/2015-01-05_13-57-28.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-20-26.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-21-03.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-28-32.png)
