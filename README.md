Goluwa is an experimental game engine/framework/personal toolbox written in LuaJIT targeted at games. It includes high level libraries to render graphics, play audio, handle input, networking and much more. 3D is the main interest but 2D is also important.

The coding style is inspired by Source Engine, Garry's Mod and CryEngine. UFO (https://github.com/malkia/ufo) gave me the initial idea and motivation.

I can't guarantee that Goluwa will run out of box if you download it at the moment. There is a BitSync version that I could invite you to if you're interested but that means you'll have to contact me.

My goal with this isn't very clear. I don't have any grand business plans or anything. I like to implement new features and refactor old features. I just like programming so if anything I hope I'll never finish this project.

LuaJit's FFI api is used to bind to the following shared libraries:

* OpenGL - graphics
* GLFW - window and input handler
* OpenAL Soft - sound library
* FreeType - font decoding
* Libsndfile - sound decoding
* FreeImage - image decoding
* FFMpeg - sound and image decoding
* VTFLib - image decoding (valves texture format)
* PDCurses - console
* Assimp - model decoding
* Bullet3 - physics engine
* ENet - udp library targeted at games
* SteamFriends - extension to the steam library to deal with steam friends communication

Everything should work fine (at least in theory) without using any of these libraries. The only actual requirement is LFS (Lua File System) and LuaJIT 2+

There is also a WIP Love2D wrapper which is used for fun and unit testing 2D graphics.
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-08/2014-08-16_01-53-14.jpg)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-06/2014-06-02_16-00-59.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2014-06/2014-06-04_17-21-33.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-19-30.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-20-26.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-21-03.png)
![ScreenShot](https://dl.dropbox.com/u/244444/ShareX/2014-05/2014-05-02_04-28-32.png)
